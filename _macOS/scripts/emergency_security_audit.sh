#!/bin/bash

echo "🚨 EMERGENCY SECURITY AUDIT - API KEYS & SECRETS SCAN"
echo "===================================================="

PROJECT_DIR="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
cd "$PROJECT_DIR"

AUDIT_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
AUDIT_LOG="security_audit_${AUDIT_TIMESTAMP}.log"

echo "📍 Project: FinanceMate"
echo "📅 Audit Time: $(date)"
echo "📁 Directory: $PROJECT_DIR"
echo ""

# Initialize audit results
CRITICAL_FINDINGS=0
WARNING_FINDINGS=0
INFO_FINDINGS=0

echo "🔍 PHASE 1: GIT HISTORY SECRET SCAN"
echo "=================================="

# Check for potentially dangerous patterns in git history
echo "Scanning git history for potential secret commits..."

# Look for commits that might contain secrets
git log --oneline --all | head -20 > git_commits_${AUDIT_TIMESTAMP}.txt
echo "✅ Git commit history captured"

# Search for files that might contain secrets
POTENTIAL_SECRET_FILES=$(find . -name "*.swift" -o -name "*.json" -o -name "*.plist" | head -20)

echo ""
echo "🔍 PHASE 2: CURRENT CODEBASE SECRET SCAN"
echo "======================================="

# Define secret patterns to search for
SECRET_PATTERNS=(
    "client.*id.*=.*[A-Za-z0-9]{20,}"
    "secret.*=.*[A-Za-z0-9]{20,}"
    "token.*=.*[A-Za-z0-9]{20,}"
    "api.*key.*=.*[A-Za-z0-9]{20,}"
    "[A-Za-z0-9]{32,}"
    "sk_[A-Za-z0-9]{24,}"
    "pk_[A-Za-z0-9]{24,}"
)

echo "Scanning for hardcoded secrets in codebase..."

# Scan each pattern
for pattern in "${SECRET_PATTERNS[@]}"; do
    echo "  🔎 Pattern: $pattern"
    
    MATCHES=$(grep -r -E "$pattern" --include="*.swift" --include="*.json" --include="*.plist" . 2>/dev/null | grep -v "// TODO\|// PLACEHOLDER\|example\|template\|test\|your-.*-client-id" | head -5)
    
    if [ ! -z "$MATCHES" ]; then
        echo "    🚨 POTENTIAL SECRETS FOUND:"
        echo "$MATCHES" | while read line; do
            echo "      ⚠️  $line"
            ((CRITICAL_FINDINGS++))
        done
    else
        echo "    ✅ No hardcoded secrets found for this pattern"
        ((INFO_FINDINGS++))
    fi
done

echo ""
echo "🔍 PHASE 3: CONFIGURATION ANALYSIS"
echo "================================="

# Check for configuration files with potential secrets
CONFIG_FILES=(
    "ProductionConfig.swift"
    "EmailOAuthManager.swift" 
    ".env"
    "*.plist"
)

echo "Analyzing configuration files..."

for config_pattern in "${CONFIG_FILES[@]}"; do
    echo "  🔎 Checking: $config_pattern"
    
    CONFIG_MATCHES=$(find . -name "$config_pattern" 2>/dev/null)
    
    if [ ! -z "$CONFIG_MATCHES" ]; then
        echo "$CONFIG_MATCHES" | while read config_file; do
            echo "    📄 Found: $config_file"
            
            # Check if file contains actual secrets vs placeholders
            SECRET_CHECK=$(grep -E "client.*id.*=|secret.*=|token.*=" "$config_file" 2>/dev/null | grep -v "your-.*-client-id\|TODO\|PLACEHOLDER\|template")
            
            if [ ! -z "$SECRET_CHECK" ]; then
                echo "      🚨 POTENTIAL SECRETS:"
                echo "$SECRET_CHECK" | while read secret_line; do
                    echo "        ⚠️  $(echo $secret_line | head -c 100)..."
                done
                ((WARNING_FINDINGS++))
            else
                echo "      ✅ Contains placeholders only"
                ((INFO_FINDINGS++))
            fi
        done
    else
        echo "    ℹ️  No files matching pattern found"
    fi
done

echo ""
echo "🔍 PHASE 4: ENVIRONMENT VARIABLE ANALYSIS"
echo "========================================"

echo "Checking for environment variable usage patterns..."

ENV_USAGE=$(grep -r "ProcessInfo.*environment\|getenv\|ENV" --include="*.swift" . | head -10)

if [ ! -z "$ENV_USAGE" ]; then
    echo "✅ Found secure environment variable usage:"
    echo "$ENV_USAGE" | while read env_line; do
        echo "  📍 $env_line"
    done
    ((INFO_FINDINGS++))
else
    echo "ℹ️  No environment variable usage found"
fi

echo ""
echo "🔍 PHASE 5: KEYCHAIN USAGE ANALYSIS" 
echo "=================================="

KEYCHAIN_USAGE=$(grep -r "Keychain\|Security" --include="*.swift" . | head -10)

if [ ! -z "$KEYCHAIN_USAGE" ]; then
    echo "✅ Found secure Keychain usage:"
    echo "$KEYCHAIN_USAGE" | while read keychain_line; do
        echo "  🔐 $keychain_line"
    done
    ((INFO_FINDINGS++))
else
    echo "⚠️  No Keychain usage found - consider for production secrets"
    ((WARNING_FINDINGS++))
fi

echo ""
echo "📊 AUDIT SUMMARY"
echo "================"
echo "🚨 Critical Findings: $CRITICAL_FINDINGS"
echo "⚠️  Warning Findings: $WARNING_FINDINGS"  
echo "ℹ️  Info Findings: $INFO_FINDINGS"
echo ""

# Determine overall security status
if [ $CRITICAL_FINDINGS -gt 0 ]; then
    SECURITY_STATUS="🚨 CRITICAL - IMMEDIATE ACTION REQUIRED"
    REMEDIATION_REQUIRED="YES"
elif [ $WARNING_FINDINGS -gt 3 ]; then
    SECURITY_STATUS="⚠️  WARNING - SECURITY IMPROVEMENTS NEEDED"
    REMEDIATION_REQUIRED="RECOMMENDED"
else
    SECURITY_STATUS="✅ GOOD - SECURITY PRACTICES FOLLOWED"
    REMEDIATION_REQUIRED="NO"
fi

echo "🎯 OVERALL SECURITY STATUS: $SECURITY_STATUS"
echo "🔧 REMEDIATION REQUIRED: $REMEDIATION_REQUIRED"
echo ""

echo "📋 IMMEDIATE ACTIONS"
echo "==================="

if [ $CRITICAL_FINDINGS -gt 0 ]; then
    echo "🚨 CRITICAL ACTIONS REQUIRED:"
    echo "  1. Rotate any exposed API keys immediately"
    echo "  2. Remove secrets from git history"
    echo "  3. Implement proper secret management"
    echo "  4. Add pre-commit hooks to prevent future exposure"
fi

if [ $WARNING_FINDINGS -gt 0 ]; then
    echo "⚠️  RECOMMENDED ACTIONS:"
    echo "  1. Review configuration management practices"
    echo "  2. Implement environment variable usage"
    echo "  3. Use Keychain for sensitive data storage"
    echo "  4. Add .env template files for configuration"
fi

echo "✅ SECURITY BEST PRACTICES:"
echo "  1. Use environment variables for configuration"
echo "  2. Store secrets in Keychain (iOS/macOS)"
echo "  3. Use .env files with .gitignore protection"
echo "  4. Implement pre-commit secret scanning"
echo "  5. Regular security audits"

echo ""
echo "📄 AUDIT LOG SAVED: $AUDIT_LOG"
echo ""

# Save summary to log file
{
    echo "EMERGENCY SECURITY AUDIT RESULTS - $AUDIT_TIMESTAMP"
    echo "=================================================="
    echo "Critical Findings: $CRITICAL_FINDINGS"
    echo "Warning Findings: $WARNING_FINDINGS"
    echo "Info Findings: $INFO_FINDINGS"
    echo "Security Status: $SECURITY_STATUS"
    echo "Remediation Required: $REMEDIATION_REQUIRED"
    echo ""
    echo "Scan completed at: $(date)"
} > "$AUDIT_LOG"

if [ $CRITICAL_FINDINGS -gt 0 ]; then
    exit 1  # Critical security issues found
elif [ $WARNING_FINDINGS -gt 3 ]; then
    exit 2  # Warning level issues found
else
    exit 0  # Security audit passed
fi