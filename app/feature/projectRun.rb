#!/usr/bin/ruby
require_relative './XcodeProject'

command = ARGV[0]
json_path = ARGV[1]

file = File.read(json_path)
json = JSON.parse(file)

code = json["code"]
target_name = json["targetName"]
project_path = json["projectPath"]

puts 'ruby run'
if command == "new"
  puts '[Script] create new target'
  puts json
  XcodeProject.new_target(project_path, code, target_name, json)

elsif command == "edit"
  puts '[Script] edit existed target'
  XcodeProject.edit_target(project_path, code, target_name, json)
  
elsif command == "info"
  puts '[Script] get project info'
  XcodeProject.fetch_target_info(project_path, code, target_name)
  
else
  puts 'ruby run...'
end

exit 0
