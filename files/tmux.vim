" if our terminal supports escape sequences
if &term == "screen-256color"
  " set the insert mode cursor to a blinking vertical bar
  let &t_SI = "\<Esc>[5 q"
  " in other modes, set the cursor to a blinking block
  let &t_EI = "\<Esc>[1 q"

  " 1 -> blinking block
  " 2 -> solid block
  " 3 -> blinking underscore
  " 4 -> solid underscore
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar
endif
