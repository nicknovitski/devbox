# if not in a tmux session
if [ -z "$TMUX" ]; then
  # attach to the first running session or start one
  exec tmux attach
fi
