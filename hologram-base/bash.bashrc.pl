#!/usr/bin/perl
use strict;
use warnings;

system("rm -f /home/*/.bashrc"); # Don't let ~/.bashrc overwrite the settings in bash.bashrc

# print contents of already existing file, substituting prompt variable
while(<>){
    if($_ =~ /^PS1/){
	print "PS1='\\t \\w <\\u@\\h> '\n";
    }else{
	print;
    }
}

# append
print "

##aliases

#basic aliases
alias ..='cd ..'
alias cd..='cd ..'
alias ls='ls --color=auto'
alias l='ls -b' # -b = use c-like escape sequences instead of ticks (a\\ whitespace instead of 'a whitespace')
alias ll='ls -lF'
alias la='ls -a'
alias lla='ll -a'
alias lld='ll -d'

# system tools and dev
alias grepi='grep -i'
alias xxd='xxd -c48'
# git (only commands that output stuff, no commands that actually change stuff, that'd be dangerous)
alias gita='git add'             ; alias ga='git add'
alias gitaa='git add -A'         ; alias gaa='git add -A'
alias gitb='git branch -v'       ; alias gb='git branch -v'
alias gitc='git commit'          ; alias gc='git commit' # might shadow /usr/bin/gc from package graphviz
alias gitca='git commit --amend' ; alias gca='git commit --amend'
alias gitcm='git commit -m'      ; alias gcm='git commit -m'
alias gitch='git checkout'       ; alias gch='git checkout'
alias gitco=gitch                ; alias gco=gch
alias gitd='git diff'            ; alias gd='git diff'
alias gitds='git diff --staged'  ; alias gds='git diff --staged'
alias gitl='git log'             ; alias gl='git log'
alias gitp='git pull'            ; alias gp='git pull'
alias gitst='git stash'          ; alias gst='git stash'
alias gitsta='git stash apply'   ; alias gsta='git stash apply'
alias gitstl='git stash list'    ; alias gstl='git stash list'
alias gitstd='git stash drop'    ; alias gstd='git stash drop'
# don't make an alias for git push because that one should be use with care! I. e. one should have to really want to type it everytime.
# Relying on the login credentials being asked is not enough, since that doesn't happen when pushing with an ssh key.
# Besides, only commands that output stuff, no commands that actually change stuff, as already stated above
alias gitr='git remote -v'       ; alias gr='git remote -v'
alias gits='git status'          ; alias gs='git status' # might shadow ghostscript
# define any as a function so that it can be called without arguments as well
function any {
	ps -e | grep \"\$1\"
}

# editors
alias eq='emacs -q'
alias e=emacs

# Multimedia
alias mpv='mpv --audio-display=no'
alias mpvall='mpv --loop-playlist --shuffle '
alias play='mpvall --no-video'
alias music='play ~/Musik'


#custom variables
export EDITOR='emacs -nw'
export VISUAL=vim
"
