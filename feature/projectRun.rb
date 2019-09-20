#!/usr/bin/ruby
require_relative './XcodeProject'

command = ARGV[0]
json_path = ARGV[1]

file = File.read(json_path)
json = JSON.parse(file)

code = json["code"]
target_name = json["targetName"]
project_path = json["projectPath"]

if command == "new"
  puts '[Script] create new target'
  puts json
  XcodeProject.new_target(project_path, code, target_name, json)

elsif command == "edit"
  puts '[Script] edit existed target'
  XcodeProject.new_target(project_path, code, target_name, json)
  
else
  puts 'ruby run...'

end

exit 0
