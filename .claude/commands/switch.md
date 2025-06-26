# Switch Claude Provider

## Description
Switches between Anthropic Max subscription, AWS Bedrock provider, and default provider.

## Usage
/switch [provider]

Where provider is 'max', 'bedrock', or 'default' (optional, cycles if not specified)

## Arguments
- `max`: Switch to Anthropic Max subscription
- `bedrock`: Switch to AWS Bedrock provider
- `default`: Switch to default provider

## Examples
- `/switch max` - Switch to Anthropic Max subscription
- `/switch bedrock` - Switch to AWS Bedrock
- `/switch default` - Switch to default provider
- `/switch` - Cycle between providers

```bash
# Get current provider
if [ -f "${HOME}/.claude_provider" ]; then
  CURRENT_PROVIDER=$(cat "${HOME}/.claude_provider")
else
  CURRENT_PROVIDER="default"
fi

# Handle provider argument
if [[ "$1" == "max" ]]; then
  NEW_PROVIDER="max"
elif [[ "$1" == "bedrock" ]]; then
  NEW_PROVIDER="bedrock"
elif [[ "$1" == "default" ]]; then
  NEW_PROVIDER="default"
else
  # Cycle mode
  if [[ "$CURRENT_PROVIDER" == "max" ]]; then
    NEW_PROVIDER="bedrock"
  elif [[ "$CURRENT_PROVIDER" == "bedrock" ]]; then
    NEW_PROVIDER="default"
  else
    NEW_PROVIDER="max"
  fi
fi

# Store the provider choice
echo "${NEW_PROVIDER}" > "${HOME}/.claude_provider"

# Set environment variables
if [[ "${NEW_PROVIDER}" == "bedrock" ]]; then
  export CLAUDE_CODE_USE_BEDROCK=1
  echo "Switched to AWS Bedrock provider"
elif [[ "${NEW_PROVIDER}" == "max" ]]; then
  unset CLAUDE_CODE_USE_BEDROCK
  echo "Switched to Anthropic Max subscription"
else
  unset CLAUDE_CODE_USE_BEDROCK
  echo "Switched to default provider"
fi

# Always enable prompt caching
export CLAUDE_CODE_ENABLE_PROMPT_CACHING=1
echo "Prompt caching enabled"

echo "Exiting to apply provider changes..."
/exit

# Add to shell config if we're in persistent mode
if [[ -n "$CLAUDE_CODE_PERSISTENT" ]]; then
  SHELL_RC=""
  if [ -f "${HOME}/.zshrc" ]; then
    SHELL_RC="${HOME}/.zshrc"
  elif [ -f "${HOME}/.bashrc" ]; then
    SHELL_RC="${HOME}/.bashrc"
  fi
  
  if [[ -n "$SHELL_RC" ]]; then
    if grep -q "CLAUDE_CODE_USE_BEDROCK" "$SHELL_RC"; then
      if [[ "${NEW_PROVIDER}" == "bedrock" ]]; then
        sed -i '' "s/export CLAUDE_CODE_USE_BEDROCK=.*/export CLAUDE_CODE_USE_BEDROCK=1/" "$SHELL_RC"
      else
        sed -i '' "/export CLAUDE_CODE_USE_BEDROCK=.*/d" "$SHELL_RC"
      fi
    else
      if [[ "${NEW_PROVIDER}" == "bedrock" ]]; then
        echo "" >> "$SHELL_RC"
        echo "# Claude Code provider configuration" >> "$SHELL_RC"
        echo "export CLAUDE_CODE_USE_BEDROCK=1" >> "$SHELL_RC"
      fi
    fi
    
    if ! grep -q "CLAUDE_CODE_ENABLE_PROMPT_CACHING" "$SHELL_RC"; then
      echo "export CLAUDE_CODE_ENABLE_PROMPT_CACHING=1" >> "$SHELL_RC"
    fi
    
    echo "Changes saved to $SHELL_RC"
    echo "Run 'source $SHELL_RC' in your terminal to apply changes globally"
  fi
fi
```