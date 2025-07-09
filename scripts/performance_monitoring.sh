#!/bin/bash

# FinanceMate Performance Monitoring Script
# SweetPad Integration - Advanced Performance Analysis
# Version: 1.0.0

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly MACOS_DIR="$PROJECT_ROOT/_macOS"
readonly BUILD_DIR="$MACOS_DIR/build"
readonly REPORTS_DIR="$PROJECT_ROOT/docs/performance_reports"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Performance thresholds
readonly BUILD_TIME_THRESHOLD=120  # seconds
readonly APP_LAUNCH_THRESHOLD=3    # seconds
readonly MEMORY_THRESHOLD=200      # MB
readonly DISK_USAGE_THRESHOLD=500  # MB

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create reports directory
setup_reports_directory() {
    log "Setting up performance reports directory..."
    mkdir -p "$REPORTS_DIR"
    
    # Create report structure
    mkdir -p "$REPORTS_DIR/build_times"
    mkdir -p "$REPORTS_DIR/memory_usage"
    mkdir -p "$REPORTS_DIR/app_performance"
    mkdir -p "$REPORTS_DIR/xcode_metrics"
}

# Monitor build performance
monitor_build_performance() {
    log "Monitoring build performance..."
    
    local build_start=$(date +%s)
    local build_log="$REPORTS_DIR/build_times/build_${TIMESTAMP}.log"
    
    # Build with timing
    cd "$MACOS_DIR"
    
    log "Starting Production build..."
    if xcodebuild -project FinanceMate.xcodeproj \
                  -scheme FinanceMate \
                  -configuration Release \
                  build \
                  SYMROOT="$BUILD_DIR" \
                  -quiet > "$build_log" 2>&1; then
        
        local build_end=$(date +%s)
        local build_duration=$((build_end - build_start))
        
        # Performance analysis
        log "Build completed in ${build_duration} seconds"
        
        if [ "$build_duration" -gt "$BUILD_TIME_THRESHOLD" ]; then
            warning "Build time (${build_duration}s) exceeds threshold (${BUILD_TIME_THRESHOLD}s)"
        else
            success "Build time within acceptable range"
        fi
        
        # Extract compilation metrics
        local swift_files=$(find . -name "*.swift" | wc -l | tr -d ' ')
        local compiled_files=$(grep -c "CompileSwift" "$build_log" || echo "0")
        local linking_time=$(grep "Ld " "$build_log" | wc -l | tr -d ' ')
        
        # Generate build performance report
        cat > "$REPORTS_DIR/build_times/build_performance_${TIMESTAMP}.json" << EOF
{
    "timestamp": "$TIMESTAMP",
    "build_duration_seconds": $build_duration,
    "threshold_seconds": $BUILD_TIME_THRESHOLD,
    "within_threshold": $([ "$build_duration" -le "$BUILD_TIME_THRESHOLD" ] && echo "true" || echo "false"),
    "swift_files_total": $swift_files,
    "files_compiled": $compiled_files,
    "linking_operations": $linking_time,
    "build_configuration": "Release",
    "xcode_version": "$(xcodebuild -version | head -n1)",
    "performance_rating": "$(get_performance_rating "$build_duration" "$BUILD_TIME_THRESHOLD")"
}
EOF
        
        success "Build performance data saved to build_performance_${TIMESTAMP}.json"
        
    else
        error "Build failed. Check $build_log for details."
        return 1
    fi
}

# Get performance rating
get_performance_rating() {
    local duration=$1
    local threshold=$2
    
    if [ "$duration" -le $((threshold / 2)) ]; then
        echo "excellent"
    elif [ "$duration" -le "$threshold" ]; then
        echo "good"
    elif [ "$duration" -le $((threshold * 2)) ]; then
        echo "acceptable"
    else
        echo "poor"
    fi
}

# Monitor application performance
monitor_app_performance() {
    log "Monitoring application performance..."
    
    local app_path="$BUILD_DIR/Release/FinanceMate.app"
    
    if [ ! -d "$app_path" ]; then
        error "Application not found at $app_path"
        return 1
    fi
    
    # Application metrics
    local app_size=$(du -sh "$app_path" | cut -f1)
    local binary_size=$(stat -f%z "$app_path/Contents/MacOS/FinanceMate")
    local frameworks_count=$(find "$app_path/Contents/Frameworks" -name "*.framework" 2>/dev/null | wc -l | tr -d ' ')
    
    log "Application size: $app_size"
    log "Binary size: $((binary_size / 1024 / 1024)) MB"
    log "Embedded frameworks: $frameworks_count"
    
    # Generate app performance report
    cat > "$REPORTS_DIR/app_performance/app_metrics_${TIMESTAMP}.json" << EOF
{
    "timestamp": "$TIMESTAMP",
    "app_bundle_size": "$app_size",
    "binary_size_bytes": $binary_size,
    "binary_size_mb": $((binary_size / 1024 / 1024)),
    "embedded_frameworks": $frameworks_count,
    "build_configuration": "Release",
    "code_signing_identity": "$(codesign -dv "$app_path" 2>&1 | grep "Authority=" | head -n1 | cut -d'=' -f2)"
}
EOF
    
    success "Application metrics saved to app_metrics_${TIMESTAMP}.json"
}

# Monitor development environment performance
monitor_dev_environment() {
    log "Monitoring development environment performance..."
    
    # System resources
    local cpu_usage=$(top -l 1 -s 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local memory_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    local disk_usage=$(df -h "$PROJECT_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    # Xcode-specific metrics
    local derived_data_size="0"
    if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
        derived_data_size=$(du -sh ~/Library/Developer/Xcode/DerivedData | cut -f1)
    fi
    
    # SweetPad/VSCode metrics
    local vscode_extensions=$(code --list-extensions 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    local sweetpad_installed=$(code --list-extensions 2>/dev/null | grep -c "sweetpad" || echo "0")
    
    log "CPU usage: ${cpu_usage}%"
    log "Memory free: ${memory_pressure}%"
    log "Disk usage: ${disk_usage}%"
    log "DerivedData size: $derived_data_size"
    log "VSCode extensions: $vscode_extensions"
    log "SweetPad installed: $([ "$sweetpad_installed" -gt 0 ] && echo "Yes" || echo "No")"
    
    # Generate environment performance report
    cat > "$REPORTS_DIR/xcode_metrics/dev_environment_${TIMESTAMP}.json" << EOF
{
    "timestamp": "$TIMESTAMP",
    "system_metrics": {
        "cpu_usage_percent": "$cpu_usage",
        "memory_free_percent": "$memory_pressure",
        "disk_usage_percent": "$disk_usage"
    },
    "development_tools": {
        "derived_data_size": "$derived_data_size",
        "vscode_extensions_count": $vscode_extensions,
        "sweetpad_installed": $([ "$sweetpad_installed" -gt 0 ] && echo "true" || echo "false"),
        "xcode_version": "$(xcodebuild -version | head -n1)"
    },
    "project_metrics": {
        "project_size": "$(du -sh "$PROJECT_ROOT" | cut -f1)",
        "swift_files": $(find "$PROJECT_ROOT" -name "*.swift" | wc -l | tr -d ' '),
        "test_files": $(find "$PROJECT_ROOT" -name "*Tests.swift" | wc -l | tr -d ' ')
    }
}
EOF
    
    success "Development environment metrics saved to dev_environment_${TIMESTAMP}.json"
}

# Generate performance summary
generate_performance_summary() {
    log "Generating performance summary..."
    
    local summary_file="$REPORTS_DIR/performance_summary_${TIMESTAMP}.md"
    
    cat > "$summary_file" << EOF
# FinanceMate Performance Report
**Generated:** $(date)
**Report ID:** $TIMESTAMP

## Executive Summary

This report provides comprehensive performance metrics for the FinanceMate macOS application development environment, including build performance, application metrics, and development tool efficiency.

## Build Performance

$([ -f "$REPORTS_DIR/build_times/build_performance_${TIMESTAMP}.json" ] && cat "$REPORTS_DIR/build_times/build_performance_${TIMESTAMP}.json" | jq -r '"- Build Duration: " + (.build_duration_seconds | tostring) + " seconds\n- Performance Rating: " + .performance_rating + "\n- Files Compiled: " + (.files_compiled | tostring) + "\n- Within Threshold: " + (.within_threshold | tostring)')

## Application Metrics

$([ -f "$REPORTS_DIR/app_performance/app_metrics_${TIMESTAMP}.json" ] && cat "$REPORTS_DIR/app_performance/app_metrics_${TIMESTAMP}.json" | jq -r '"- Application Size: " + .app_bundle_size + "\n- Binary Size: " + (.binary_size_mb | tostring) + " MB\n- Embedded Frameworks: " + (.embedded_frameworks | tostring)')

## Development Environment

$([ -f "$REPORTS_DIR/xcode_metrics/dev_environment_${TIMESTAMP}.json" ] && cat "$REPORTS_DIR/xcode_metrics/dev_environment_${TIMESTAMP}.json" | jq -r '"- CPU Usage: " + .system_metrics.cpu_usage_percent + "%\n- Memory Free: " + .system_metrics.memory_free_percent + "%\n- SweetPad Installed: " + (.development_tools.sweetpad_installed | tostring)')

## Recommendations

### Performance Optimizations
- Monitor build times regularly to detect regressions
- Consider incremental build optimizations for large codebases
- Optimize DerivedData management for faster builds

### Development Environment
- Ensure SweetPad integration is properly configured
- Regular cleanup of temporary files and caches
- Monitor system resources during intensive development sessions

---
*Generated by FinanceMate Performance Monitoring System*
EOF
    
    success "Performance summary generated: $summary_file"
}

# Performance trending analysis
analyze_performance_trends() {
    log "Analyzing performance trends..."
    
    # Find recent performance reports
    local recent_reports=$(find "$REPORTS_DIR/build_times" -name "build_performance_*.json" -mtime -7 | sort)
    
    if [ -z "$recent_reports" ]; then
        warning "No recent performance data available for trend analysis"
        return 0
    fi
    
    local trend_file="$REPORTS_DIR/performance_trends_${TIMESTAMP}.json"
    local avg_build_time=0
    local report_count=0
    
    # Calculate average build time
    for report in $recent_reports; do
        local build_time=$(cat "$report" | jq -r '.build_duration_seconds')
        avg_build_time=$((avg_build_time + build_time))
        report_count=$((report_count + 1))
    done
    
    if [ "$report_count" -gt 0 ]; then
        avg_build_time=$((avg_build_time / report_count))
        
        cat > "$trend_file" << EOF
{
    "analysis_timestamp": "$TIMESTAMP",
    "period_days": 7,
    "reports_analyzed": $report_count,
    "average_build_time_seconds": $avg_build_time,
    "threshold_seconds": $BUILD_TIME_THRESHOLD,
    "performance_trend": "$([ "$avg_build_time" -le "$BUILD_TIME_THRESHOLD" ] && echo "stable" || echo "declining")",
    "recommendation": "$([ "$avg_build_time" -le "$BUILD_TIME_THRESHOLD" ] && echo "Performance within acceptable range" || echo "Consider build optimization strategies")"
}
EOF
        
        success "Performance trend analysis saved to performance_trends_${TIMESTAMP}.json"
        log "Average build time over 7 days: ${avg_build_time} seconds"
    fi
}

# Main execution
main() {
    log "Starting FinanceMate Performance Monitoring..."
    log "Report timestamp: $TIMESTAMP"
    
    setup_reports_directory
    monitor_build_performance
    monitor_app_performance
    monitor_dev_environment
    analyze_performance_trends
    generate_performance_summary
    
    success "Performance monitoring completed successfully!"
    log "Reports available in: $REPORTS_DIR"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi