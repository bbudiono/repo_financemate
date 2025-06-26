echo "Switching to Anthropic Max subscription..."
unset CLAUDE_CODE_USE_BEDROCK
export CLAUDE_CODE_ENABLE_PROMPT_CACHING=1
echo "Anthropic Max subscription activated"
echo "Provider changes will take effect after restart"
/exit