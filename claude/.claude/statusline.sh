#!/bin/bash

# Catppuccin Mocha color palette
RED="\033[38;2;243;139;168m"
PEACH="\033[38;2;250;179;135m"
YELLOW="\033[38;2;249;226;175m"
GREEN="\033[38;2;166;227;161m"
SAPPHIRE="\033[38;2;116;199;236m"
BLUE="\033[38;2;137;180;250m"
MAUVE="\033[38;2;203;166;247m"
CRUST="\033[38;2;17;17;27m"
TEXT="\033[38;2;205;214;244m"
SUBTEXT0="\033[38;2;166;173;200m"
RESET="\033[0m"

# Background colors
BG_RED="\033[48;2;243;139;168m"
BG_PEACH="\033[48;2;250;179;135m"
BG_YELLOW="\033[48;2;249;226;175m"
BG_GREEN="\033[48;2;166;227;161m"
BG_SAPPHIRE="\033[48;2;116;199;236m"
BG_BLUE="\033[48;2;137;180;250m"
BG_MAUVE="\033[48;2;203;166;247m"

# Read JSON input
input=$(cat)

# Extract account identity from ~/.claude.json
account_email=$(jq -r '.oauthAccount.emailAddress // ""' ~/.claude.json 2>/dev/null)
# Split on '.' or '@', take the first token (e.g. "alexander" or "agarcia")
account_label=$(echo "$account_email" | awk -F'[.@]' '{print $1}')
if [ -z "$account_label" ]; then
    account_label="?"
fi

# Extract data
model_display=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# Calculate cost (Claude Sonnet 4.5 pricing: $3/MTok input, $15/MTok output)
input_cost=$(echo "scale=4; $total_input * 3 / 1000000" | bc)
output_cost=$(echo "scale=4; $total_output * 15 / 1000000" | bc)
total_cost=$(echo "scale=4; $input_cost + $output_cost" | bc)

# Format cost to 4 decimal places with leading zero if needed
cost_formatted=$(printf "%.4f" $total_cost)

# Create Pac-Man progress bar with dots
bar_width=10
pacman_pos=$(printf "%.0f" $(echo "scale=0; $used_pct * $bar_width / 100" | bc))
# Ensure pacman_pos is within bounds
if [ $pacman_pos -gt $bar_width ]; then
    pacman_pos=$bar_width
fi

progress_bar=""
for ((i=0; i<bar_width; i++)); do
    if [ $i -eq $pacman_pos ]; then
        progress_bar+="󰮯"  # Pac-Man icon
    else
        progress_bar+="·"  # Dot
    fi
done

# Get git branch if in a git repo
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
fi

# Build status line in starship style with powerline arrows
output=""

# Model name segment (red background, crust text)
output+=$(printf "${CRUST}${RED}${RESET}")
output+=$(printf "${BG_RED}${CRUST}󰧑 %s ${RESET}" "$model_display")

# Account segment (green background, crust text)
output+=$(printf "${BG_GREEN}${RED}${RESET}")  # Arrow in red on green bg
output+=$(printf "${BG_GREEN}${CRUST} %s ${RESET}" "$account_label")


# Working directory segment (sapphire background, crust text)
dir_name=$(basename "$cwd")
output+=$(printf "${BG_SAPPHIRE}${GREEN}${RESET}")  # Arrow in green on sapphire bg
output+=$(printf "${BG_SAPPHIRE}${CRUST} 📁 %s ${RESET}" "$dir_name")

# Git branch segment (mauve background, crust text)
if [ -n "$git_branch" ]; then
    output+=$(printf "${BG_MAUVE}${SAPPHIRE}${RESET}")  # Arrow in sapphire on mauve bg

    output+=$(printf "${BG_MAUVE}${CRUST}  %s ${RESET}" "$git_branch")

    # Arrow to context segment
    output+=$(printf "${BG_PEACH}${MAUVE}${RESET}")
else
    # No branch, arrow directly from directory to context
    output+=$(printf "${BG_PEACH}${SAPPHIRE}  ${RESET}")
fi

# Context usage segment (peach background, crust text)
output+=$(printf "${BG_PEACH}${CRUST} ${RESET}")
output+=$(printf "${BG_PEACH}${CRUST}%s ${RESET}" "$progress_bar")
output+=$(printf "${BG_PEACH}${CRUST} %.1f%% ${RESET}" "$used_pct")

# Cost segment (yellow background, crust text)
output+=$(printf "${BG_YELLOW}${PEACH}${RESET}")  # Arrow in peach on yellow bg
output+=$(printf "${BG_YELLOW}${CRUST} \$%s ${RESET}" "$cost_formatted")

# Final arrow to close the statusline
output+=$(printf "${YELLOW}${RESET}")

# Print the final output
printf '%s\n' "$output"
