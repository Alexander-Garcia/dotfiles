#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Stowing dotfiles..."
stow starship tmux

echo "Done!"
