#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
main_target = project.targets.find { |t| t.name == 'FinanceMate' }
test_target = project.targets.find { |t| t.name == 'FinanceMateTests' }

if !main_target || !test_target
  puts "❌ Could not find required targets"
  exit 1
end

# Find the production ViewModels group by looking for the one that contains DashboardViewModel
production_group = nil
project.main_group.recursive_children.each do |group|
  if group.is_a?(Xcodeproj::Project::Object::PBXGroup) && group.path == 'ViewModels'
    # Check if this is the production ViewModels by looking for DashboardViewModel
    if group.files.find { |f| f.path == 'DashboardViewModel.swift' }
      production_group = group
      puts "✓ Found production ViewModels group"
      break
    end
  end
end

if !production_group
  puts "❌ Could not find production ViewModels group"
  exit 1
end

# Find the test ViewModels group
test_group = nil
project.main_group.recursive_children.each do |group|
  if group.is_a?(Xcodeproj::Project::Object::PBXGroup) && group.path == 'ViewModels'
    # Check if this is the test ViewModels by looking for DashboardViewModelTests
    if group.files.find { |f| f.path == 'DashboardViewModelTests.swift' }
      test_group = group
      puts "✓ Found test ViewModels group"
      break
    end
  end
end

if !test_group
  puts "❌ Could not find test ViewModels group"
  exit 1
end

# Add ViewModels to production target
viewmodel_files = [
  'LineItemViewModel.swift',
  'SplitAllocationViewModel.swift',
  'SettingsViewModel.swift'
]

viewmodel_files.each do |filename|
  file_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/ViewModels/#{filename}"
  
  # Check if file already exists in project
  existing_ref = production_group.files.find { |f| f.path == filename }
  
  if existing_ref
    puts "✓ #{filename} already in project, adding to target"
    # Add to build phase if not already there
    unless main_target.source_build_phase.files.find { |f| f.file_ref && f.file_ref.path == filename }
      main_target.source_build_phase.add_file_reference(existing_ref)
    end
  else
    # Add new file reference
    file_ref = production_group.new_reference(file_path)
    file_ref.name = filename
    main_target.source_build_phase.add_file_reference(file_ref)
    puts "✅ Added #{filename} to project and target"
  end
end

# Add test files to test target
test_files = [
  'LineItemViewModelTests.swift',
  'SplitAllocationViewModelTests.swift'
]

test_files.each do |filename|
  file_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateTests/ViewModels/#{filename}"
  
  # Check if file already exists in project
  existing_ref = test_group.files.find { |f| f.path == filename }
  
  if existing_ref
    puts "✓ #{filename} already in project, adding to test target"
    # Add to build phase if not already there
    unless test_target.source_build_phase.files.find { |f| f.file_ref && f.file_ref.path == filename }
      test_target.source_build_phase.add_file_reference(existing_ref)
    end
  else
    # Add new file reference
    file_ref = test_group.new_reference(file_path)
    file_ref.name = filename
    test_target.source_build_phase.add_file_reference(file_ref)
    puts "✅ Added #{filename} to test project and target"
  end
end

# Save the project
project.save

puts "\n✅ Successfully patched Xcode project!"
puts "   - Added 3 ViewModels to FinanceMate target"
puts "   - Added 2 test files to FinanceMateTests target"
puts "   - Project saved successfully"