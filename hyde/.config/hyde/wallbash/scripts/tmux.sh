#!/usr/bin/env bash
# Re-applies the wallbash tmux theme to every running tmux server.
# Invoked by wallbash after ~/.cache/hyde/wallbash/tmux.conf is regenerated.

command -v tmux >/dev/null 2>&1 || exit 0

cacheDir="${cacheDir:-${XDG_CACHE_HOME:-$HOME/.cache}/hyde}"
theme="${cacheDir}/wallbash/tmux.conf"

[ -r "$theme" ] || exit 0

# No server running means nothing to reload; that is not an error.
tmux has-session 2>/dev/null || exit 0

tmux source-file "$theme" 2>/dev/null || true
tmux refresh-client -S 2>/dev/null || true
