# tmux

Prefix is `C-b`.

## sessions

| keys | what |
|---|---|
| `tmux new -s name` | new named session |
| `C-b d` | detach |
| `tmux a -t name` | attach |
| `C-b s` | list and switch sessions |
| `C-b $` | rename session |
| `tmux kill-session -t name` | kill session |

## windows

| keys | what |
|---|---|
| `C-b c` | new window |
| `C-b n` / `C-b p` | next / previous |
| `C-b 0-9` | go to window N |
| `C-b l` | last window |
| `C-b ,` | rename window |
| `C-b &` | kill window |
| `C-b w` | list windows |

- The green bar lists windows, not panes.

## panes

| keys | what |
|---|---|
| `C-b %` | split right |
| `C-b "` | split below |
| `C-b arrows` | move between panes |
| `C-b o` | cycle panes |
| `C-b q` | pick pane by number |
| `C-b z` | zoom toggle |
| `C-b x` | kill pane |
| `C-b {` / `C-b }` | swap with prev / next |
| `C-b space` | cycle layouts |
| `C-b C-arrows` | resize by 1 |
| `C-b M-arrows` | resize by 5 |
| `C-b !` | break pane out to window |
| `:join-pane -s N` | pull window N in as pane |

## placing splits

Command prompt is `C-b :`, drop the leading `tmux`.

| keys | what |
|---|---|
| `split-window -h` | right |
| `split-window -hb` | left |
| `split-window -v` | below |
| `split-window -vb` | above |
| `split-window -hf` | full height |
| `split-window -l 30%` | with size |

## naming

| keys | what |
|---|---|
| `new-window -n name` | new named window |
| `rename-window name` | rename current window |
| `select-pane -T name` | title current pane |

- Pane titles only show with `set -g pane-border-status top`.

## copy mode

| keys | what |
|---|---|
| `C-b [` | enter copy mode |
| `space` | start selection |
| `enter` | copy selection |
| `C-b ]` | paste |
| `q` | quit copy mode |

## misc

| keys | what |
|---|---|
| `:source ~/.tmux.conf` | reload config |
| `set -g status 2` | two-line bar with pane list |

- Mouse is on (`set -g mouse on` in `~/.tmux.conf`).
