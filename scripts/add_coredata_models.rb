#!/usr/bin/env ruby

require 'xcodeproj'

# Script to add Core Data model files to Xcode project targets
project_path = '_macOS/FinanceMate.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Files to add to both Production and Sandbox targets
files_to_add = [
  'FinanceMate/Models/LineItem+CoreDataClass.swift',
  'FinanceMate/Models/LineItem+CoreDataProperties.swift', 
  'FinanceMate/Models/SplitAllocation+CoreDataClass.swift',
  'FinanceMate/Models/SplitAllocation+CoreDataProperties.swift'
]

# Find the main groups
models_group = project.main_group.find_subpath('FinanceMate/Models', true)

# Find targets
finance_mate_target = project.targets.find { |target| target.name == 'FinanceMate' }
finance_mate_tests_target = project.targets.find { |target| target.name == 'FinanceMateTests' }

puts "Adding Core Data model files to Xcode project..."

files_to_add.each do |file_path|
  full_path = "_macOS/#{file_path}"
  
  if File.exist?(full_path)
    # Add file reference to project
    file_ref = models_group.new_reference(File.basename(file_path))
    file_ref.path = File.basename(file_path)
    file_ref.source_tree = '<group>'
    
    # Add to FinanceMate target (Production)
    if finance_mate_target
      finance_mate_target.add_file_references([file_ref])
      puts "✅ Added #{File.basename(file_path)} to FinanceMate target"
    end
    
    # Add to FinanceMateTests target for testing
    if finance_mate_tests_target && !file_path.include?('Properties')
      finance_mate_tests_target.add_file_references([file_ref])
      puts "✅ Added #{File.basename(file_path)} to FinanceMateTests target"
    end
  else
    puts "❌ File not found: #{full_path}"
  end
end

# Save the project
project.save

puts "\n🎯 Core Data model files added successfully!"
puts "📝 Manual step required:"
puts "   Open Xcode and verify the files are in the correct targets"
puts "   Ensure 'FinanceMate' target contains all 4 files"
puts "   Ensure 'FinanceMateTests' target contains the Class files"