echo "Switching to default provider..."
unset CLAUDE_CODE_USE_BEDROCK
export CLAUDE_CODE_ENABLE_PROMPT_CACHING=1
echo "Default provider activated"
echo "Provider changes will take effect after restart"
/exit