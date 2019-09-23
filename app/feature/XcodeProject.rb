require 'xcodeproj'
require 'json'
require 'plist'
require 'fileutils'
require_relative './ButlerHeaderFile'
require_relative './ImageAsset'

module XcodeProject
  # return xcodeproj file name in directory
  def XcodeProject.find_xcodeproj(dir)
    file_name = Dir.entries(dir).find { |entry| entry.index('xcodeproj') }
    return File.join(dir, file_name)
  end

  # insert "target xxx do\n end" into podfile
  def XcodeProject.podfile_add_target(project_path, target_name)
    lines = []
    File.open("#{project_path}/Podfile", "r") { |podfile|
      lines =  IO.readlines(podfile)
    }
    content = ""
    lines.each do |line|
      content += line
      if line.index("abstract_target")
        content += "target '#{target_name}' do\nend\n"
      end
    end
    File.open("#{project_path}/Podfile", "w") { |podfile|
      podfile.syswrite(content)
    }
  end

  # import header file in pch
  def XcodeProject.pch_add_header_file(pch_file_path, pre_process_macro, header_file_name)
    lines = []
    File.open(pch_file_path, "r") { |f|
      lines = IO.readlines(f)
    }
    content = ""
    lines.each { |line|
      if line.index("#elif REMAIN")
        content += %Q{#elif #{pre_process_macro}\n#import "#{header_file_name}.h"\n}
      end
      content += line
    }
    File.open(pch_file_path, "w") { |f|
      f.syswrite(content)
    }
  end

  # create_target method do follow things for you
  # 1. create target from template
  # 2. copy build phase and build setttins from template, igonre template's private build files, 
  #    in addition, method will add a target's pre-preocess macro 
  # 3. make directory for new target
  # 4. copy plist from template, modify target private items
  # 5. make project config header file which contains project's configs, such as http address,
  #    jpush key, umeng key and etc.
  # 6. make private image assets for target, and make icon asset and launch asset.
  # 7. add target into Podfile
  # 8. put target's private header file into project's pch file
  def XcodeProject.new_target(project_path, code, target_name, configuration, template_name="ButlerForRemain")
    xcodeproj_path = File.join(project_path, find_xcodeproj(project_path))
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
            puts '------- ignore ' + file.display_name
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
    icon_paths = configuration["icons"]
    launch_paths = configuration["launchs"]
    top_assets_path = "#{target_group_path}/assetsFor#{code.capitalize}.xcassets"
    ImageAsset.new_assets_group(top_assets_path)
    ImageAsset.new_icon(icon_paths, top_assets_path)
    ImageAsset.new_launch(launch_paths, top_assets_path)

    # plist
    dest_plist_path = "#{target_group_path}/#{code.capitalize}-info.plist"
    src_build_settings = src_target.build_settings("Distribution")
    src_plist_path = src_build_settings["INFOPLIST_FILE"].gsub('$(SRCROOT)', project_path)
    plist_hash = Plist.parse_xml(src_plist_path)

    plist_hash["CFBundleDisplayName"] = configuration["displayName"]
    plist_hash["CFBundleShortVersionString"] = configuration["version"]
    plist_hash["CFBundleVersion"] = configuration["build"]

    File.open(dest_plist_path, "w") { |f|
      f.syswrite(plist_hash.to_plist)
    }

    # header file
    header_file_hash = Hash.new
    ButlerHeaderFile.keys.each do |key|
      header_file_hash[key] = configuration[key]
    end
    header_file_path = "#{target_group_path}/SCAppConfigFor#{code.capitalize}Butler.h"
    ButlerHeaderFile.write_to_file(header_file_hash, header_file_path)

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
      build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = configuration["bundleId"]
      preprocess_defs = ["$(inherited)", "#{target_name.upcase}=1"]
      if config.name == 'Release'
        preprocess_defs.push("Release=1")
      elsif config.name == 'Distribution'
        preprocess_defs.push("Distribution=1")
      end
      build_settings["GCC_PREPROCESSOR_DEFINITIONS"] = preprocess_defs
    end

    puts '[Scirpt] Edit podfile'
    podfile_add_target(project_path, target_name)

    puts '[Scirpt] Edit pch'
    pch_path = target.build_settings('Distribution')["GCC_PREFIX_HEADER"]
    pch_add_header_file("#{project_path}/#{pch_path}", code.upcase, "SCAppConfigFor#{code.capitalize}Butler")

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
    if configuration["displayName"]
      plist["CFBundleDisplayName"] = configuration["displayName"]
    end
    if configuration["version"]
      plist["CFBundleShortVersionString"] = configuration["version"]
    end
    if configuration["build"]
      plist["CFBundleVersion"] = configuration["build"]
    end
    File.open(plist_path, "w") { |f|
      f.syswrite(plist.to_plist)
    }

    target_private_group = "#{project_path}/Butler/ButlerFor#{code.capitalize}"
    
    # header file
    puts 'begin edit header file'
    header_file_path = "#{target_private_group}/SCAppConfigFor#{code.capitalize}Butler.h"
    unless File.exist?(header_file_path)
      raise "#{header_file_path} not exist"
    end
    header_file = ButlerHeaderFile.load(header_file_path)
    ButlerHeaderFile.keys.map { |key|
      if configuration[key]
        header_file[key] = configuration[key]
      end
    }
    ButlerHeaderFile.write_to_file(header_file, header_file_path)

    # image
    puts 'begin handle image files'
    images = configuration["images"]
    if images
      assets_name = Dir.entries(target_private_group).find { |f| f.index('.xcassets') }
      assets_path = File.join(target_private_group, assets_name)
      puts assets_path
      if images["icons"]
        ImageAsset.new_icon(images["icons"], assets_path)
      end
      if images["launchs"]
        ImageAsset.new_icon(images["launchs"], assets_path)
      end
    end

    puts 'edit project complete'
  end

  def XcodeProject.fetch_target_info(proj_path, code, target_name)
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

    private_group = File.join(proj_path, 'Butler', "ButlerFor#{code.capitalize}")
    header_file_name = Dir.entries(private_group).find { |e| e.index(".h") }
    header_file_path = File.join(private_group, header_file_name)
    headerfile = ButlerHeaderFile.load(header_file_path)
    ButlerHeaderFile.keys.each do |field|
      info[field] = headerfile[field]
    end

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

    File.open('./appInfo.json', 'w') { |f|
      f.syswrite(info.to_json)
    }
  end

end