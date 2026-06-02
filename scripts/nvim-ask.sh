#!/bin/bash

# Ensure a question was provided
if [ -z "$1" ]; then
    echo "Usage: ./nvim-ask.sh '<question>'"
    exit 1
fi

QUERY="$1"
CONFIG_DIR="${HOME}/.config/nvim"

# Construct the prompt enforcing the conditional-access rules
PROMPT="You are a NeoVim expert. Your goal is to answer the user's question about NeoVim with ONLY the exact keybinding or a very short, concise command. Do NOT provide lengthy explanations.

CRITICAL RULE:
Do NOT read or access any files unless the user explicitly mentions 'my config', 'my setup', 'my custom', or a specific plugin. 
If they DO mention those keywords, you are permitted to use your tools to inspect the files in ${CONFIG_DIR} to find their specific custom bindings.

User Question: ${QUERY}"

# Execute opencode with the prompt
# Using a fast model (you can change this to gemini-1.5-flash or another model if needed)
opencode run --dangerously-skip-permissions -m "google/gemini-2.5-flash" "$PROMPT" < /dev/null
