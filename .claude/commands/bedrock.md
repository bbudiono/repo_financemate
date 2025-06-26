echo "Switching to AWS Bedrock provider..."
export CLAUDE_CODE_USE_BEDROCK=1
export CLAUDE_CODE_ENABLE_PROMPT_CACHING=1
echo "AWS Bedrock provider activated"
echo "Provider changes will take effect after restart"
/exit