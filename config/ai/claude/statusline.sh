#!/bin/bash
input=$(cat)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
TOTAL_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST_FMT=$(printf '$%.4f' "$COST")
echo "Tokens: ${TOTAL_IN}in / ${TOTAL_OUT}out | Context: ${PCT}% | Cost: $COST_FMT"
