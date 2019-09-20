require 'image_size'
require 'fileutils'

$SRCROOT = File.expand_path('..', __FILE__)

module ImageAsset
  def ImageAsset.new_icon(icons, dest_dir)
    icon_assets_path = "#{dest_dir}/AppIcon.appiconset"

    if File.exist?(icon_assets_path)
      FileUtils.remove_dir(icon_assets_path)
    end

    Dir::mkdir(icon_assets_path)

    FileUtils.cp("#{$SRCROOT}/Sources/Icon_Contents.json", File.join(icon_assets_path, 'Contents.json'))

    # contents.json中文件名称固定，需要根据尺寸重命名。
    icons.each { |absolute_path|
      if File.file?(absolute_path)
        size = ImageSize.path(absolute_path)
        if size.width == 40
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_20@2x.png")
        elsif size.width == 60
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_20@3x.png")
        elsif size.width == 29*2
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_29@2x.png")
        elsif size.width == 29*3
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_29@3x.png")
        elsif size.width == 40*2
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_40@2x.png")
        elsif size.width == 40*3
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_40@3x.png")
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_60@2x.png")
        elsif size.width == 60*3
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon_60@3x.png")
        elsif size.width == 1024
          FileUtils.cp(absolute_path, "#{icon_assets_path}/icon.png")
        end
      end
    }
  end

  def ImageAsset.new_launch(image_paths, dest_dir)
    launch_assets_path = "#{dest_dir}/LaunchImage.launchimage"

    if File.exist?(launch_assets_path)
      FileUtils.remove_dir(launch_assets_path)
    end

    Dir.mkdir(launch_assets_path)

    FileUtils.cp("#{$SRCROOT}/Sources/LaunchImage_Contents.json", "#{launch_assets_path}/Contents.json")

    # contents.json中文件名称固定，需要根据尺寸重命名。
    image_paths.each { |absolute_path|
      if File.file?(absolute_path)
        size = ImageSize.path(absolute_path)
        if size.width == 1242 and size.height == 2688
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页1242.2688@3x.png")
        elsif size.width == 828 and size.height == 1792
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页828.1792@2x.png")
        elsif size.width == 1125 and size.height == 2436
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页1125.2436@3x.png")
        elsif size.width == 1242 and size.height == 2208
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页1242.2208@3x.png")
        elsif size.width == 750 and size.height == 1334
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页750.1334@2x.png")
        elsif size.width == 640 and size.height == 960
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页640.960@2x.png")
        elsif size.width == 640 and size.height == 1136
          FileUtils.cp(absolute_path, "#{launch_assets_path}/启动页640.1136@2x.png")
        end
      end
    }
  end

  def ImageAsset.new_assets_group(path)
    unless File.exist?(path)
      Dir.mkdir(path)
    end
    contents_path = File.join(path, "Contents.json")
    File.open(contents_path, "w") { |f|
      f.syswrite(%Q{{\n  "info" : {\n    "version" : 1,\n    "author" : "xcode"\n  }\n}})
    }
  end

  def ImageAsset.new_image_assets(name, file_paths)
    puts $SRCROOT
  end

end