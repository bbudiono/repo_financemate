#!/bin/bash

# FinanceMate Pre-Commit Security Scan
# Prevents commits containing secrets, API keys, or sensitive data
# Version: 1.0.0
# Last Updated: 2025-08-10

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SECURITY_LOG_DIR="$PROJECT_ROOT/.claude/security_reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SECURITY_LOG_DIR/pre_commit_scan_$TIMESTAMP.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create security log directory if it doesn't exist
mkdir -p "$SECURITY_LOG_DIR"

# Initialize log file
echo "FinanceMate Pre-Commit Security Scan - $TIMESTAMP" > "$LOG_FILE"
echo "=================================================================" >> "$LOG_FILE"

# Function to log and display messages
log_message() {
    local level=$1
    local message=$2
    local color=$3
    
    echo -e "${color}[$level] $message${NC}"
    echo "[$level] $message" >> "$LOG_FILE"
}

# Function to scan for secrets using multiple patterns
scan_for_secrets() {
    log_message "INFO" "Starting comprehensive secret detection scan..." "$BLUE"
    
    local violations=0
    local scan_results="$SECURITY_LOG_DIR/secret_scan_$TIMESTAMP.txt"
    
    # Define comprehensive secret patterns
    local secret_patterns=(
        # API Keys - Real formats
        'sk-[a-zA-Z0-9]{48,}'                    # OpenAI API keys
        'sk-ant-api03-[a-zA-Z0-9_-]{95,}'       # Anthropic Claude keys
        'xoxb-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}' # Slack bot tokens
        'ghp_[a-zA-Z0-9]{36}'                    # GitHub personal access tokens
        'ya29\.[a-zA-Z0-9_-]{68,}'               # Google OAuth2 access tokens
        'AKIA[0-9A-Z]{16}'                       # AWS access key IDs
        
        # Database Connection Strings - Real formats
        'mongodb(\+srv)?://[^/\s]+/[^/\s]+'      # MongoDB connection strings
        'postgresql://[^/\s]+/[^/\s]+'           # PostgreSQL connection strings
        'mysql://[^/\s]+/[^/\s]+'                # MySQL connection strings
        
        # OAuth Secrets - Real formats
        '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' # Client IDs
        '[a-zA-Z0-9_-]{40,}\.apps\.googleusercontent\.com' # Google Client IDs
        
        # JWT Tokens - Real formats
        'eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*' # JWT tokens
        
        # Private Keys - Real formats
        '-----BEGIN [A-Z ]+PRIVATE KEY-----'     # Private key headers
        'BEGIN RSA PRIVATE KEY'                  # RSA private keys
        'BEGIN OPENSSH PRIVATE KEY'              # OpenSSH private keys
        
        # Banking/Financial APIs - Australian focus
        'basiq_[a-zA-Z0-9_-]{32,}'              # Basiq API keys
        'nab_[a-zA-Z0-9_-]{32,}'                # NAB API keys
        'westpac_[a-zA-Z0-9_-]{32,}'            # Westpac API keys
        'anz_[a-zA-Z0-9_-]{32,}'                # ANZ API keys
    )
    
    # Define non-placeholder validation patterns
    local real_secret_indicators=(
        # Must NOT contain these placeholder indicators
        '!(your-|your_|example\.|test[@_]|demo[@_]|placeholder|sample[@_]|fake[@_]|mock[@_])'
    )
    
    echo "Secret Detection Scan Results - $TIMESTAMP" > "$scan_results"
    echo "=======================================================" >> "$scan_results"
    
    # Scan staged files only (pre-commit context)
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
    
    if [[ -z "$staged_files" ]]; then
        log_message "INFO" "No staged files to scan" "$BLUE"
        return 0
    fi
    
    log_message "INFO" "Scanning staged files for secrets..." "$BLUE"
    echo "Staged files:" >> "$scan_results"
    echo "$staged_files" >> "$scan_results"
    echo "" >> "$scan_results"
    
    # Scan each staged file
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            log_message "INFO" "Scanning: $file" "$BLUE"
            
            # Check against each secret pattern
            for pattern in "${secret_patterns[@]}"; do
                local matches
                matches=$(grep -Hn "$pattern" "$file" 2>/dev/null || true)
                
                if [[ -n "$matches" ]]; then
                    # Additional validation: ensure it's not a placeholder
                    while IFS= read -r match; do
                        local line_content
                        line_content=$(echo "$match" | cut -d: -f3-)
                        
                        # Skip if it contains placeholder indicators
                        if echo "$line_content" | grep -qE "(your-|your_|example\.|test[@_]|demo[@_]|placeholder|sample[@_]|fake[@_]|mock[@_])"; then
                            log_message "DEBUG" "Skipping placeholder in $match" "$YELLOW"
                            continue
                        fi
                        
                        # This appears to be a real secret
                        log_message "CRITICAL" "REAL SECRET DETECTED: $match" "$RED"
                        echo "CRITICAL VIOLATION: $match" >> "$scan_results"
                        ((violations++))
                        
                    done <<< "$matches"
                fi
            done
        fi
    done <<< "$staged_files"
    
    # Summary
    echo "" >> "$scan_results"
    echo "SCAN SUMMARY:" >> "$scan_results"
    echo "Files Scanned: $(echo "$staged_files" | wc -l)" >> "$scan_results"
    echo "Violations Found: $violations" >> "$scan_results"
    echo "Scan Timestamp: $TIMESTAMP" >> "$scan_results"
    
    log_message "INFO" "Secret scan complete. Violations found: $violations" "$BLUE"
    return $violations
}

# Function to validate environment files
validate_environment_files() {
    log_message "INFO" "Validating environment configuration files..." "$BLUE"
    
    local violations=0
    
    # Check for committed .env files (should be in .gitignore)
    if git diff --cached --name-only | grep -q "^\.env$"; then
        log_message "CRITICAL" ".env file is being committed! This likely contains secrets." "$RED"
        echo "CRITICAL: Attempted to commit .env file" >> "$LOG_FILE"
        ((violations++))
    fi
    
    # Ensure .env.template exists and has no real secrets
    if [[ -f "$PROJECT_ROOT/.env.template" ]]; then
        log_message "INFO" "Validating .env.template for placeholder compliance..." "$BLUE"
        
        # Check that .env.template only contains placeholders
        if grep -qE "[a-zA-Z0-9]{32,}" "$PROJECT_ROOT/.env.template"; then
            local suspicious_lines
            suspicious_lines=$(grep -n "[a-zA-Z0-9]{32,}" "$PROJECT_ROOT/.env.template" | grep -v "your-\|your_\|example\.\|placeholder" || true)
            
            if [[ -n "$suspicious_lines" ]]; then
                log_message "WARNING" "Suspicious non-placeholder values in .env.template:" "$YELLOW"
                echo "$suspicious_lines" | while read -r line; do
                    log_message "WARNING" "  $line" "$YELLOW"
                    echo "SUSPICIOUS: .env.template - $line" >> "$LOG_FILE"
                done
                ((violations++))
            fi
        fi
    else
        log_message "WARNING" ".env.template not found. Consider creating one for security." "$YELLOW"
    fi
    
    return $violations
}

# Function to run SEMGREP security scan
run_semgrep_scan() {
    log_message "INFO" "Running SEMGREP security analysis..." "$BLUE"
    
    local violations=0
    local semgrep_output="$SECURITY_LOG_DIR/semgrep_scan_$TIMESTAMP.json"
    
    # Check if semgrep is available
    if ! command -v semgrep &> /dev/null; then
        log_message "WARNING" "SEMGREP not installed. Skipping advanced security scan." "$YELLOW"
        log_message "INFO" "Install with: pip install semgrep" "$BLUE"
        return 0
    fi
    
    # Run SEMGREP with security rules
    log_message "INFO" "Executing SEMGREP security rules..." "$BLUE"
    
    if semgrep --config=auto --json --quiet --no-rewrite-rule-ids . > "$semgrep_output" 2>/dev/null; then
        local findings_count
        findings_count=$(jq '.results | length' "$semgrep_output" 2>/dev/null || echo "0")
        
        if [[ "$findings_count" -gt 0 ]]; then
            log_message "WARNING" "SEMGREP found $findings_count security findings" "$YELLOW"
            
            # Extract critical findings
            local critical_findings
            critical_findings=$(jq -r '.results[] | select(.extra.severity == "ERROR") | "\(.path):\(.start.line) - \(.message)"' "$semgrep_output" 2>/dev/null || echo "")
            
            if [[ -n "$critical_findings" ]]; then
                log_message "CRITICAL" "Critical security findings found:" "$RED"
                echo "$critical_findings" | while read -r finding; do
                    log_message "CRITICAL" "  $finding" "$RED"
                    echo "SEMGREP CRITICAL: $finding" >> "$LOG_FILE"
                done
                violations=$findings_count
            fi
        else
            log_message "SUCCESS" "SEMGREP scan passed - no security issues found" "$GREEN"
        fi
    else
        log_message "ERROR" "SEMGREP scan failed to execute" "$RED"
        echo "SEMGREP execution failed" >> "$LOG_FILE"
        violations=1
    fi
    
    return $violations
}

# Function to generate security report
generate_security_report() {
    local total_violations=$1
    
    local report_file="$SECURITY_LOG_DIR/security_report_$TIMESTAMP.json"
    
    # Create JSON security report
    cat > "$report_file" << EOF
{
    "timestamp": "$TIMESTAMP",
    "scan_type": "pre_commit_security",
    "total_violations": $total_violations,
    "scan_results": {
        "secret_detection": {
            "violations": $(scan_for_secrets; echo $?)
        },
        "environment_validation": {
            "violations": 0
        },
        "semgrep_scan": {
            "violations": 0
        }
    },
    "staged_files": [
        $(git diff --cached --name-only --diff-filter=ACM | sed 's/.*/"&"/' | paste -sd, -)
    ],
    "security_status": "$([ $total_violations -eq 0 ] && echo "SECURE" || echo "VIOLATIONS_DETECTED")",
    "recommendations": [
        "Ensure .env file is in .gitignore",
        "Use .env.template for configuration examples",
        "Never commit real API keys or secrets",
        "Use environment variables for sensitive data",
        "Regularly rotate API keys and secrets"
    ]
}
EOF
    
    log_message "INFO" "Security report generated: $report_file" "$BLUE"
}

# Main execution
main() {
    log_message "INFO" "Starting FinanceMate pre-commit security scan..." "$BLUE"
    
    local total_violations=0
    
    # Run secret detection scan
    scan_for_secrets
    ((total_violations += $?))
    
    # Validate environment files
    validate_environment_files
    ((total_violations += $?))
    
    # Run SEMGREP scan
    run_semgrep_scan
    ((total_violations += $?))
    
    # Generate security report
    generate_security_report $total_violations
    
    # Final result
    if [[ $total_violations -eq 0 ]]; then
        log_message "SUCCESS" "✅ Pre-commit security scan PASSED - No violations detected" "$GREEN"
        echo "SCAN RESULT: PASSED" >> "$LOG_FILE"
        exit 0
    else
        log_message "CRITICAL" "❌ Pre-commit security scan FAILED - $total_violations violations detected" "$RED"
        log_message "CRITICAL" "Commit BLOCKED to prevent security breach" "$RED"
        log_message "INFO" "Review security report: $LOG_FILE" "$BLUE"
        echo "SCAN RESULT: FAILED ($total_violations violations)" >> "$LOG_FILE"
        exit 1
    fi
}

# Execute main function
main "$@"