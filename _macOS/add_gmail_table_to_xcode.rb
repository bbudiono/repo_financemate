#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = 'FinanceMate.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Files to add
files_to_add = [
  'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift'
]

# Get the Views/Gmail group (or create it)
views_group = project.main_group.find_subpath('FinanceMate/Views', true)
gmail_group = views_group.find_subpath('Gmail', true)

files_to_add.each do |file_path|
  # Check if file already exists in project
  existing = gmail_group.files.find { |f| f.path == File.basename(file_path) }

  unless existing
    puts "Adding #{file_path} to Xcode project..."

    # Add file reference to group
    file_ref = gmail_group.new_reference(file_path)

    # Add to target's compile sources
    target.add_file_references([file_ref])

    puts " Added #{file_path}"
  else
    puts "️  #{file_path} already in project"
  end
end

# Save the project
project.save

puts "\n Xcode project updated successfully!"
puts "Files added to FinanceMate/Views/Gmail group"
