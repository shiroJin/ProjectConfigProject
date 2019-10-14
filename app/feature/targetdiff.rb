#!/usr/bin/ruby
require 'xcodeproj'

class Slot
  attr_accessor :display_name, :value, :file_ref
  def initialize
    @display_name = ""
    @value = 0
    @file_ref = nil
  end
end

# input
proj_path = Dir.entries(Dir.getwd).find { |f| f.index('xcodeproj') }
raise "this's no xcodeproj" unless proj_path
target1_name, target2_name = ARGV[0], ARGV[1]
raise "parameter missing" unless target1_name and target2_name

proj = Xcodeproj::Project.open(proj_path)
target1 = proj.targets.find { |t| t.display_name == target1_name }
target2 = proj.targets.find { |t| t.display_name == target2_name }

raise "target going missing" unless target1 and target2

# build resources
target1_resource = target1.build_phases.find { |p| p.instance_of? Xcodeproj::Project::Object::PBXResourcesBuildPhase }
target2_resource = target2.build_phases.find { |p| p.instance_of? Xcodeproj::Project::Object::PBXResourcesBuildPhase }

hash = Hash.new
target1_resource.files.map { |file|
  slot = hash[file.file_ref.uuid]
  unless slot
    slot = Slot.new
    slot.display_name = file.display_name
    hash[file.file_ref.uuid] = slot
  end
  slot.value += 1
}

target2_resource.files.map { |file|
  slot = hash[file.file_ref.uuid]
  unless slot
    slot = Slot.new
    slot.display_name = file.display_name
    hash[file.file_ref.uuid] = slot
  end
  slot.value += 2
}

result1, result2 = Array.new, Array.new
hash.map{ |key,value|
  if value.value == 1
    result1<<value.display_name
  elsif value.value == 2
    result2<<value.display_name
  end
}

puts "build resource diff:"
puts ">>>>>#{target1_name}\n#{result1.sort}\n=====#{target2_name}\n#{result2.sort}\n<<<<<"

# build files
source_1 = target1.build_phases.find { |p| p.instance_of? Xcodeproj::Project::Object::PBXSourcesBuildPhase }
source_2 = target2.build_phases.find { |p| p.instance_of? Xcodeproj::Project::Object::PBXSourcesBuildPhase }
source_hash = Hash.new
source_1.files.map { |file|
  slot = source_hash[file.file_ref.uuid]
  unless slot
    slot = Slot.new
    slot.display_name = file.display_name
    source_hash[file.file_ref.uuid] = slot
  end
  slot.value += 1
}

source_2.files.map { |file|
  slot = source_hash[file.file_ref.uuid]
  unless slot
    slot = Slot.new
    slot.display_name = file.display_name
    source_hash[file.file_ref.uuid] = slot
  end
  slot.value += 2
}

result1, result2 = Array.new, Array.new
source_hash.map{ |key,value|
  if value.value == 1
    result1<<value.display_name
  elsif value.value == 2
    result2<<value.display_name
  end
}
puts "build source diff:"
puts ">>>>>#{target1_name}\n#{result1.sort}\n=====#{target2_name}\n#{result2.sort}\n<<<<<"

def sync_target
  ignore_file
end