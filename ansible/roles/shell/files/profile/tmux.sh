# exceeding kudos to http://robinwinslow.co.uk/2012/07/20/tmux-and-ssh-auto-login-with-ssh-agent-finally/

# if not in a tmux session
if [[ ! $TERM =~ screen ]]; then
  # if the auth socket variable isn't set
  if [ -z "$SSH_AUTH_SOCK" ]; then
    # Set it
    export SSH_AUTH_SOCK="$HOME/.ssh/.auth_socket"
  fi

  # If the Socket is available
  if [ ! -S "$SSH_AUTH_SOCK" ]; then
    # start ssh-agent on the auth socket
    `ssh-agent -a $SSH_AUTH_SOCK` > /dev/null 2>&1
    # save the pid of that process
    echo $SSH_AGENT_PID &gt; $HOME/.ssh/.auth_pid
  fi

  # if the pid variable isn't set
  if [ -z $SSH_AGENT_PID ]; then
    # set it to the pid of the newly created socket
    export SSH_AGENT_PID=`cat $HOME/.ssh/.auth_pid`
  fi

  # attach to the first running session or start one
  tmux -q has-session && exec tmux attach || exec tmux
fi
