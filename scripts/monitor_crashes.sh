#!/bin/bash

# FinanceMate Crash Monitoring Script
# Purpose: Automated crash detection and alerting for TestFlight monitoring
# Usage: Run hourly via cron or manually for immediate crash analysis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$PROJECT_ROOT/logs/crash_monitoring_$TIMESTAMP.log"

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

echo "🔍 FINANCEMATE CRASH MONITORING" | tee "$LOG_FILE"
echo "===============================" | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo "Monitoring Period: Last 1 hour" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to log with timestamp
log_with_timestamp() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check crash logs
check_crash_logs() {
    log_with_timestamp "🔍 Scanning for FinanceMate crashes..."
    
    local crash_dirs=(
        "$HOME/Library/Logs/DiagnosticReports"
        "/Library/Logs/DiagnosticReports"
        "$HOME/Library/Logs/CrashReporter"
    )
    
    local total_crashes=0
    local recent_crashes=0
    
    for dir in "${crash_dirs[@]}"; do
        if [ -d "$dir" ]; then
            # Find all FinanceMate crashes
            local all_crashes=$(find "$dir" -name "*FinanceMate*" -o -name "*financemate*" 2>/dev/null | wc -l)
            total_crashes=$((total_crashes + all_crashes))
            
            # Find recent crashes (last hour)
            local hour_crashes=$(find "$dir" -name "*FinanceMate*" -o -name "*financemate*" -newermt "1 hour ago" 2>/dev/null | wc -l)
            recent_crashes=$((recent_crashes + hour_crashes))
            
            if [ $hour_crashes -gt 0 ]; then
                log_with_timestamp "🔴 Found $hour_crashes recent crash(es) in $dir"
                find "$dir" -name "*FinanceMate*" -o -name "*financemate*" -newermt "1 hour ago" 2>/dev/null | while read -r crash_file; do
                    log_with_timestamp "    - $(basename "$crash_file")"
                    
                    # Extract basic crash info
                    if [ -f "$crash_file" ]; then
                        local crash_time=$(stat -f %Sm "$crash_file")
                        local crash_reason=$(grep -m 1 "Exception Type:" "$crash_file" 2>/dev/null || echo "Unknown")
                        log_with_timestamp "      Time: $crash_time"
                        log_with_timestamp "      Reason: $crash_reason"
                    fi
                done
            fi
        fi
    done
    
    log_with_timestamp "📊 Crash Summary:"
    log_with_timestamp "   Recent (1h): $recent_crashes crashes"
    log_with_timestamp "   Total Found: $total_crashes crashes"
    
    return $recent_crashes
}

# Function to check system health
check_system_health() {
    log_with_timestamp "🏥 System Health Check:"
    
    # Memory pressure
    local memory_info=$(memory_pressure | head -n 1)
    log_with_timestamp "   Memory: $memory_info"
    
    # CPU usage
    local cpu_info=$(top -l 1 -s 0 | grep "CPU usage" | head -n 1)
    log_with_timestamp "   CPU: $cpu_info"
    
    # Disk space
    local disk_info=$(df -h / | tail -n 1 | awk '{print $4 " available of " $2}')
    log_with_timestamp "   Disk: $disk_info"
    
    # Check if FinanceMate is running
    local financemate_pids=$(ps aux | grep -i financemate | grep -v grep | wc -l)
    if [ $financemate_pids -gt 0 ]; then
        log_with_timestamp "   ✅ FinanceMate: $financemate_pids process(es) running"
        ps aux | grep -i financemate | grep -v grep | while read -r line; do
            log_with_timestamp "      $line"
        done
    else
        log_with_timestamp "   ⚠️ FinanceMate: No processes detected"
    fi
}

# Function to check app launch capability
check_app_launch() {
    log_with_timestamp "🚀 App Launch Verification:"
    
    local app_path="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-cwhtqhdxlmpjveapchugoaqybedf/Build/Products/Release/FinanceMate.app"
    
    if [ -d "$app_path" ]; then
        log_with_timestamp "   ✅ Production app bundle exists"
        
        # Check if app is code signed
        local codesign_status=$(codesign -v "$app_path" 2>&1 || echo "Code signing verification failed")
        if [[ "$codesign_status" == *"valid on disk"* ]] || [[ "$codesign_status" == "" ]]; then
            log_with_timestamp "   ✅ Code signing: Valid"
        else
            log_with_timestamp "   ⚠️ Code signing: $codesign_status"
        fi
        
        # Check app bundle structure
        if [ -f "$app_path/Contents/MacOS/FinanceMate" ]; then
            log_with_timestamp "   ✅ Executable: Present"
        else
            log_with_timestamp "   ❌ Executable: Missing"
        fi
        
        if [ -f "$app_path/Contents/Info.plist" ]; then
            log_with_timestamp "   ✅ Info.plist: Present"
        else
            log_with_timestamp "   ❌ Info.plist: Missing"
        fi
        
    else
        log_with_timestamp "   ❌ Production app bundle not found at expected location"
    fi
}

# Function to generate alert
generate_alert() {
    local crash_count=$1
    local alert_file="$PROJECT_ROOT/temp/crash_alert_$TIMESTAMP.md"
    
    cat > "$alert_file" << EOF
# 🚨 FINANCEMATE CRASH ALERT

**Generated:** $(date)  
**Severity:** $([ $crash_count -gt 3 ] && echo "P0 CRITICAL" || echo "P1 HIGH")  
**Crash Count:** $crash_count crashes detected in last hour

## Summary
$crash_count new FinanceMate crashes detected in the last hour. This requires immediate investigation to maintain TestFlight user trust and application stability.

## Immediate Actions Required
1. **Review crash logs** for root cause analysis
2. **Check affected user count** via TestFlight analytics
3. **Assess impact** on core functionality
4. **Develop hotfix** if critical functionality affected
5. **Notify users** if widespread issue confirmed

## Investigation Steps
1. Run comprehensive diagnostics: \`./scripts/execute_comprehensive_headless_testing.sh\`
2. Review detailed crash logs in ~/Library/Logs/DiagnosticReports/
3. Test app launch and core functionality
4. Check for recent code changes that might have caused regressions

## Escalation
- **If >3 crashes:** Immediate P0 escalation to development team
- **If authentication affected:** P0 critical - user access blocked
- **If data corruption suspected:** P0 critical - user trust at risk

**Contact:** financemate-dev@ablankcanvas.com  
**Log Details:** $LOG_FILE
EOF

    log_with_timestamp "🚨 ALERT GENERATED: $alert_file"
    
    # In a real implementation, this would send notifications
    # echo "CRASH ALERT: $crash_count crashes detected" | mail -s "FinanceMate Crash Alert" dev-team@example.com
}

# Function to update monitoring status
update_monitoring_status() {
    local crash_count=$1
    local status_file="$PROJECT_ROOT/temp/monitoring_status.json"
    
    cat > "$status_file" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "status": "$([ $crash_count -eq 0 ] && echo "healthy" || echo "alert")",
    "crashes_last_hour": $crash_count,
    "monitoring_log": "$LOG_FILE",
    "next_check": "$(date -v+1H -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    log_with_timestamp "📊 Status updated: $status_file"
}

# Main execution
main() {
    local start_time=$(date +%s)
    
    # System health check
    check_system_health
    echo "" | tee -a "$LOG_FILE"
    
    # App launch verification
    check_app_launch
    echo "" | tee -a "$LOG_FILE"
    
    # Crash detection
    check_crash_logs
    local crash_count=$?
    echo "" | tee -a "$LOG_FILE"
    
    # Generate alerts if necessary
    if [ $crash_count -gt 0 ]; then
        log_with_timestamp "🚨 ALERT CONDITION: $crash_count crashes detected"
        generate_alert $crash_count
        
        # Run comprehensive testing if crashes detected
        log_with_timestamp "🔧 Running comprehensive diagnostics..."
        if [ -f "$PROJECT_ROOT/scripts/execute_comprehensive_headless_testing.sh" ]; then
            "$PROJECT_ROOT/scripts/execute_comprehensive_headless_testing.sh" >> "$LOG_FILE" 2>&1
        fi
    else
        log_with_timestamp "✅ NO CRASHES DETECTED - System healthy"
    fi
    
    # Update monitoring status
    update_monitoring_status $crash_count
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_with_timestamp "⏱️ Monitoring completed in ${duration}s"
    log_with_timestamp "📝 Full log: $LOG_FILE"
    
    # Return crash count for script chaining
    exit $crash_count
}

# Execute main function
main "$@"