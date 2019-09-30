require 'xcodeproj'
require 'json'
require 'plist'
require 'fileutils'
require_relative './HeadFile'
require_relative './ImageAsset'

module XcodeProject
  # return xcodeproj file name in directory
  def XcodeProject.find_xcodeproj(dir)
    file_name = Dir.entries(dir).find { |entry| entry.index('xcodeproj') }
    return File.join(dir, file_name)
  end

  # insert "target xxx do\n end" into podfile
  def XcodeProject.podfile_add_target(project_path, target_name)
    podfile_path = File.join(project_path, 'Podfile')
    content = ""
    IO.foreach(podfile_path) do |line|
      content += line
      if line.index("abstract_target")
        content += "target '#{target_name}' do\nend\n"
      end
    end
    IO.write(podfile_path, content)
  end

  # import header file in pch
  def XcodeProject.config_add_headfile(pch_file_path, pre_process_macro, headfile_name)
    index = 0
    content = ""
    IO.foreach(pch_file_path) do |line|
      content += line
      if index == 1
        content += %Q{#ifdef #{pre_process_macro}\n#import "#{headfile_name}.h"\n#endif\n}
      end
      index += 1   
    end
    IO.write(pch_file_path, content)
  end

  # create_target method do follow things for you
  # 1. create target from template
  # 2. copy build phase and build setttins from template, igonre template's private build files, 
  #    in addition, method will add a target's pre-preocess macro 
  # 3. make directory for new target, create plist file and headerfile which contains project's 
  #    configs, such as http address, jpush key, umeng key and etc. In addition, create imagset.
  # 4. edit Podfile file
  def XcodeProject.new_target(project_path, code, target_name, configuration, template_name="ButlerForRemain")
    xcodeproj_path = find_xcodeproj(project_path)
    project = Xcodeproj::Project.open(xcodeproj_path)
    target = project.targets.find { |item| item.name == target_name }
    if target
      raise '[Script] target already exist'
    end

    # make native target
    puts '[Scirpt] create native target'
    src_target = project.targets.find { |item| item.name == template_name }
    target = project.new_target(src_target.symbol_type, target_name, src_target.platform_name, src_target.deployment_target)
    target.product_name = target_name

    # copy build source from template
    puts '[Scirpt] copy build phase'
    src_target.build_phases.each do |src|
      klass = src.class
      dest = target.build_phases.find { |phase| phase.instance_of? klass }
      unless dest
        dest ||= project.new(klass)
        target.build_phases << dest
      end
      dest.files.map { |item| item.remove_from_project }
      
      src.files.each do |file|
        # 过滤私有文件
        if file.file_ref.hierarchy_path.index("/Butler/ButlerForRemain")
          puts '-------- ignore ' + file.display_name
          next
        end
        if dest.instance_of? Xcodeproj::Project::Object::PBXFrameworksBuildPhase
          if file.display_name.index('libPods-CommonPods')
            puts '-------- ignore ' + file.display_name
            next
          end
        end
        dest.add_file_reference(file.file_ref, true)
      end
    end

    # copy build settings from source target
    puts '[Scirpt] copy build setting'
    src_target.build_configurations.each do |config|
      dest_config = target.build_configurations.find { |dest| dest.name == config.name }
      dest_config.build_settings.update(config.build_settings)
    end

    # group
    puts '[Scirpt] create private files'
    target_group_path = "#{project_path}/Butler/ButlerFor#{code.capitalize}"
    Dir.mkdir(target_group_path)
    group = project.main_group.find_subpath("Butler").new_group(nil, "ButlerFor#{code.capitalize}")

    # image resource
    icon_paths = configuration["images"]["AppIcon"]
    launch_paths = configuration["images"]["LaunchImage"]
    top_assets_path = "#{target_group_path}/assetsFor#{code.capitalize}.xcassets"
    ImageAsset.new_assets_group(top_assets_path)
    ImageAsset.new_icon(icon_paths, top_assets_path)
    ImageAsset.new_launch(launch_paths, top_assets_path)

    # plist
    dest_plist_path = "#{target_group_path}/#{code.capitalize}-info.plist"
    src_build_settings = src_target.build_settings("Distribution")
    src_plist_path = src_build_settings["INFOPLIST_FILE"].gsub('$(SRCROOT)', project_path)
    plist_hash = Plist.parse_xml(src_plist_path)

    plist_hash["CFBundleDisplayName"] = configuration["CFBundleDisplayName"]
    plist_hash["CFBundleShortVersionString"] = configuration["CFBundleShortVersionString"]
    plist_hash["CFBundleVersion"] = configuration["CFBundleVersion"]
    IO.write(dest_plist_path, plist_hash.to_plist)

    # header file
    distribution_hash = Hash.new
    ignore_fields = HeadFile.project_fields()
    configuration.each do |key, value|
      puts key
      unless ignore_fields.include? key
        distribution_hash[key] = value
      end
    end
    headfile_hash = Hash["DISTRIBUTION" => distribution_hash]
    headfile_path = "#{target_group_path}/SCAppConfigFor#{code.capitalize}Butler.h"
    HeadFile.dump(headfile_path, headfile_hash)

    # new ref and build file in pbxproj
    group.new_reference("SCAppConfigFor#{code.capitalize}Butler.h")
    assets_ref = group.new_reference("assetsFor#{code.capitalize}.xcassets")
    plist_ref = group.new_reference("#{code.capitalize}-info.plist")
    target.add_resources([plist_ref, assets_ref])

    # build settings
    puts '[Scirpt] build setting config'
    target.build_configurations.each do |config|
      build_settings = config.build_settings
      build_settings["INFOPLIST_FILE"] = dest_plist_path.gsub(project_path, '$(SRCROOT)')
      build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = configuration["PRODUCT_BUNDLE_IDENTIFIER"]
      preprocess_defs = ["$(inherited)", "#{code.upcase}=1"]
      if config.name == 'Release'
        preprocess_defs.push("RELEASE=1")
      elsif config.name == 'Distribution'
        preprocess_defs.push("DISTRIBUTION=1")
      end
      build_settings["GCC_PREPROCESSOR_DEFINITIONS"] = preprocess_defs
    end

    puts '[Scirpt] Edit podfile'
    podfile_add_target(project_path, target_name)

    puts '[Scirpt] Edit CommonConfig'
    config_path = File.join(project_path, 'Butler', 'SCCommonConfig.h')
    config_add_headfile(config_path, code.upcase, "SCAppConfigFor#{code.capitalize}Butler")

    project.save

    # 执行pod install
    puts '[Scirpt] excute pod install'
    Dir.chdir(project_path)
    exec 'pod install'

  end

  # allow you to edit project's config, such as http address, project version, build version, etc.
  def XcodeProject.edit_target(project_path, code, target_name, configuration)
    xcodeproj_path = File.join(project_path, find_xcodeproj(project_path))
    project = Xcodeproj::Project.open(xcodeproj_path)
    target = project.targets.find { |item| item.name == target_name }
    unless target
      raise "[Script] target #{target_name} not exist"
      exit 1
    end

    # plist
    puts 'begin edit plist file'
    build_settings = target.build_settings("Distribution")
    plist_path = build_settings["INFOPLIST_FILE"].gsub('$(SRCROOT)', project_path)
    plist = Plist.parse_xml(plist_path)
    if configuration["CFBundleDisplayName"]
      plist["CFBundleDisplayName"] = configuration["CFBundleDisplayName"]
    end
    if configuration["CFBundleShortVersionString"]
      plist["CFBundleShortVersionString"] = configuration["CFBundleShortVersionString"]
    end
    if configuration["CFBundleVersion"]
      plist["CFBundleVersion"] = configuration["CFBundleVersion"]
    end
    IO.write(plist_path, plist.to_plist)

    private_group = "#{project_path}/Butler/ButlerFor#{code.capitalize}"
    
    # header file
    puts 'begin edit header file'
    headfile_path = "#{private_group}/SCAppConfigFor#{code.capitalize}Butler.h"
    unless File.exist?(headfile_path)
      raise "#{headfile_path} not exist"
      exit 1
    end
    headfile = HeadFile.load(headfile_path)
    distribution_config = headerfile["DISTRIBUTION"]
    configuration.map { |key, value|
      distribution_config[key] = value
    }
    HeadFile.dump(headfile_path, headfile)

    # image
    puts 'begin handle image files'
    images = configuration["images"]
    if images
      assets_name = Dir.entries(private_group).find { |f| f.index('.xcassets') }
      assets_path = File.join(private_group, assets_name)
      if images["icons"]
        ImageAsset.new_icon(images["icons"], assets_path)
      end
      if images["launchs"]
        ImageAsset.new_icon(images["launchs"], assets_path)
      end
    end

    puts 'edit project complete'
  end

  def XcodeProject.fetch_target_info(proj_path, private_group_name, target_name)
    info = Hash.new

    proj = Xcodeproj::Project.open(find_xcodeproj(proj_path))
    target = proj.targets.find { |target| target.display_name == target_name }
    build_settings = target.build_settings('Distribution')
    
    plist_path = build_settings["INFOPLIST_FILE"].gsub('$(SRCROOT)', proj_path)
    info_plist = Plist.parse_xml(plist_path)
    puts plist_path
    fields =['CFBundleDisplayName', 'CFBundleShortVersionString', 'CFBundleVersion']
    fields.each do |field|
      info[field] = info_plist[field]
    end

    private_group = File.join(proj_path, 'Butler', private_group_name)
    headfile_name = Dir.entries(private_group).find { |e| e.index(".h") }
    headfile_path = File.join(private_group, headfile_name)
    headerfile = HeadFile.load(headfile_path)
    info = info.merge(headerfile["DISTRIBUTION"])

    assets_info = Hash.new
    xcassets = File.join(private_group, Dir.entries(private_group).find { |e| e.index("xcassets") })
    Dir.entries(xcassets).each do |entry|
      filename = entry.split('.').first
      extname = entry.split('.').last
      absolute_path = File.join(xcassets, entry)
      if ['appiconset', 'launchimage', 'imageset'].include? extname
        path = File.join(absolute_path, Dir.entries(absolute_path).find { |f| f.index('png') })
        assets_info[filename] = path
      end
    end
    info['images'] = assets_info
    
    IO.write('./appInfo.json', info.to_json)
  end

end