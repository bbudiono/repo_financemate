#!/usr/bin/env ruby
# Fix Xcode project file references after nuclear reset
# This script removes stale references and keeps only the MVP files

require 'xcodeproj'

# Path to the Xcode project
project_path = 'FinanceMate.xcodeproj'

# Open the project
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'FinanceMate' }

unless target
  puts "Error: Could not find FinanceMate target"
  exit 1
end

# MVP files that should exist
mvp_files = {
  'FinanceMateApp.swift' => 'App',
  'ProductionConfig.swift' => 'Configuration',
  'PersistenceController.swift' => 'Models',
  'Transaction.swift' => 'Models',
  'GmailAPI.swift' => 'Services',
  'KeychainHelper.swift' => 'Services',
  'GmailViewModel.swift' => 'ViewModels',
  'ContentView.swift' => 'Views',
  'DashboardView.swift' => 'Views',
  'GmailView.swift' => 'Views',
  'TransactionsView.swift' => 'Views'
}

# Count statistics
removed_count = 0
added_count = 0
existing_count = 0

puts "Analyzing project structure..."

# Get the main group
main_group = project.main_group.find_subpath('FinanceMate', true)

unless main_group
  puts "Error: Could not find FinanceMate group"
  exit 1
end

# Remove all existing file references from compile sources
puts "\nRemoving stale build phase references..."
target.source_build_phase.files.clear
removed_count = target.source_build_phase.files.count

# Remove all files from groups
puts "Cleaning file groups..."
main_group.clear

# Create group structure
app_group = main_group.new_group('App')
config_group = main_group.new_group('Configuration')
models_group = main_group.new_group('Models')
services_group = main_group.new_group('Services')
viewmodels_group = main_group.new_group('ViewModels')
views_group = main_group.new_group('Views')

group_map = {
  'App' => app_group,
  'Configuration' => config_group,
  'Models' => models_group,
  'Services' => services_group,
  'ViewModels' => viewmodels_group,
  'Views' => views_group
}

# Add MVP files
puts "\nAdding MVP file references..."
mvp_files.each do |filename, group_name|
  file_path = "FinanceMate/#{group_name}/#{filename}"

  # Check if file exists
  unless File.exist?(file_path)
    puts "  WARNING: File does not exist: #{file_path}"
    next
  end

  # Get the appropriate group
  group = group_map[group_name]

  # Add file reference
  file_ref = group.new_file(file_path)

  # Add to build phase
  target.add_file_references([file_ref])

  added_count += 1
  puts "  Added: #{filename} (#{group_name})"
end

# Save the project
puts "\nSaving project..."
project.save

puts "\n" + "="*60
puts "SUMMARY"
puts "="*60
puts "Stale references removed: #{removed_count}"
puts "MVP references added: #{added_count}"
puts "\nNext step: Test the build with:"
puts "  cd _macOS && xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate"
