#!/usr/bin/env ruby
# Fix FinanceMate Xcode project to include ONLY MVP files
# This script removes all stale file references and adds only the 11 actual MVP files

require 'xcodeproj'

project_path = '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the FinanceMate target
target = project.targets.find { |t| t.name == 'FinanceMate' }
raise "FinanceMate target not found!" unless target

puts " Cleaning up FinanceMate target..."

# Remove ALL existing file references from compile sources
target.source_build_phase.files.clear
puts " Cleared all existing file references"

# Define the 11 MVP files that actually exist
mvp_files = [
  'FinanceMate/App/FinanceMateApp.swift',
  'FinanceMate/Configuration/ProductionConfig.swift',
  'FinanceMate/Models/PersistenceController.swift',
  'FinanceMate/Models/Transaction.swift',
  'FinanceMate/Services/GmailAPI.swift',
  'FinanceMate/Services/KeychainHelper.swift',
  'FinanceMate/ViewModels/GmailViewModel.swift',
  'FinanceMate/Views/ContentView.swift',
  'FinanceMate/Views/DashboardView.swift',
  'FinanceMate/Views/GmailView.swift',
  'FinanceMate/Views/TransactionsView.swift'
]

# Remove all existing groups to start fresh
main_group = project.main_group['FinanceMate']
if main_group
  main_group.clear
end

puts "\n Creating clean group structure..."

# Create proper group structure
groups = {
  'App' => [],
  'Configuration' => [],
  'Models' => [],
  'Services' => [],
  'ViewModels' => [],
  'Views' => []
}

# Categorize files by directory
mvp_files.each do |file_path|
  parts = file_path.split('/')
  group_name = parts[1]  # App, Models, Services, etc.
  file_name = parts[2]

  groups[group_name] << file_path if groups.key?(group_name)
end

# Add files to project with proper groups
groups.each do |group_name, files|
  next if files.empty?

  group = main_group.new_group(group_name, group_name)

  files.each do |file_path|
    file_name = File.basename(file_path)
    file_ref = group.new_file(file_path)
    target.add_file_references([file_ref])
    puts "   Added: #{file_path}"
  end
end

# Also add Info.plist and entitlements (not compiled but needed)
plist_ref = main_group.new_file('FinanceMate/Info.plist')
entitlements_ref = main_group.new_file('FinanceMate/FinanceMate.entitlements')

puts "\n Saving project..."
project.save

puts "\n SUCCESS! Project cleaned and rebuilt with 11 MVP files only"
puts "\nNext step: Run 'xcodebuild -scheme FinanceMate build' to verify"
