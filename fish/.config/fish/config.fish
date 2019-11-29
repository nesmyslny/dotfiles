# set env vars
set -x GOPATH $HOME/dev/go
set -xa PATH $HOME/bin $GOPATH $GOPATH/bin $HOME/.cargo/bin $HOME/.yarn/bin
set -x EDITOR nvim
set -x VISUAL nvim
set -x MANPAGER "nvim -c 'set ft=man' -"

# https://github.com/0rax/fish-bd
set -x BD_OPT 'insensitive'

# https://github.com/junegunn/fzf
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git/'

# https://github.com/jethrokuan/fzf
set -x FZF_LEGACY_KEYBINDINGS 0
set -x FZF_FIND_FILE_COMMAND 'fd --type f --hidden --exclude .git/ . $dir'
set -x FZF_CD_COMMAND 'fd --type d --exclude .git/ . $dir'
set -x FZF_CD_WITH_HIDDEN_COMMAND 'fd --type d --hidden --exclude .git/ . $dir'
set -x FZF_OPEN_COMMAND 'fd --hidden --exclude .git/ . $dir'

# https://github.com/sharkdp/bat
set -x BAT_THEME 'OneHalfDark'

alias a=atom
alias o=open
alias n=nvim
alias nup='nvim +PlugUpgrade +PlugUpdate'
alias nn='nvim +Notes!'
alias nng='nvim +RgNotes!'
alias c='xclip -sel clip'
alias pwdc='pwd | head -c -1 | c'
alias se=sudoedit
alias time='time -p'

if set -q TMUX
    # rename first window of first session
    if test (tmux display-message -p '#S') = '0' -a (tmux display-message -p '#I') = '0'
        tmux rename-window chaos
    end
end

function hybrid_bindings --description "Vi-style bindings that inherit emacs-style bindings in all modes"
    fish_hybrid_key_bindings
    # use `fish_key_reader -c` or `showkey -a` to get keys
    bind -M insert \e\r accept-autosuggestion execute # \e\r = alt+enter; ctrl+enter is mapped to \e\r in alacritty.yml
    bind -M insert \cc kill-whole-line force-repaint
    bind -M default -m insert \cc kill-whole-line force-repaint
    bind -M default \eh fzf_copycmd
    bind -M insert \eh fzf_copycmd
    bind -M default \ek fzf_kill
    bind -M insert \ek fzf_kill
end
set -g fish_key_bindings hybrid_bindings

function fish_greeting
    set -l FILE (dirname (status --current-filename))/greeting.md
    if test -e $FILE
      bat -p $FILE
    end
end

function ls
    #command ls -hF --color=auto --group-directories-first $argv
    exa --group-directories-first --time-style=long-iso $argv
end

function ll
  ls -l $argv
end

function rg
    # if it's in a tty (not piped,...), use --pretty and a pager
    if isatty 1
        command rg -Sp $argv | less -XFR
    else
        command rg -S $argv
    end
end

function tldr
    command tldr --color $argv | less -XFR
end

function oni
    command oni $argv &
end

function start_ssh_agent
    eval (ssh-agent -c)
    ssh-add -k ~/.ssh/id_rsa
end

function weather
  curl "wttr.in/$argv"
end

function fzf_copycmd
  set -l cmd (history | fzf --no-sort --height 40%)
  if test -n "$cmd"
    echo $cmd | c
  end
  commandline -f repaint
end

function fzf_kill
  # args statt comm -> full command
  set -l process (ps -eo pid,euser,%cpu,etime,comm --sort -pid --no-headers | fzf --height 40%)
  if test -n "$process"
    set -l pid (echo $process | awk '{print $1}')
    set -l comm (echo $process | awk '{print $5}')
    commandline -r "kill -9 $pid #$comm"
  end
  commandline -f repaint
end

starship init fish | source
