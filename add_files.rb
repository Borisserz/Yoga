require 'xcodeproj'
project_path = '/Users/borisserzhanovich/projects/Yoga1/Yoga1.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Yoga1' }

files_to_add = [
  'Yoga1/AppStateManager.swift',
  'Yoga1/AuthManager.swift',
  'Yoga1/MainTabView.swift',
  'Yoga1/OnboardingFlowView.swift',
  'Yoga1/MoreTabView.swift'
]

files_to_add.each do |file_path|
  group = project.main_group.find_subpath('Yoga1', true)
  
  # Only add if it's not already in the group
  unless group.files.any? { |f| f.path == File.basename(file_path) }
    file_ref = group.new_file(File.basename(file_path))
    target.add_file_references([file_ref])
    puts "Added #{file_path} to Xcode project."
  else
    puts "#{file_path} is already in the project."
  end
end

project.save
puts "Successfully saved project!"
