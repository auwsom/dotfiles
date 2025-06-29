#!/bin/bash

# git config --global --add safe.directory /home/user/git/dotfiles

cd /home/user/git/dotfiles
git fetch origin

if ! git rev-list HEAD..origin/main --count | grep -q '^0$'; then
    notify-send --urgency=critical --expire-time=0 "Dotfiles Updates Available" "Updates are available on the remote origin for your dotfiles."
fi

git diff --exit-code HEAD origin/main
