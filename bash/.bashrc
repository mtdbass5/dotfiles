uname=$(uname)
# If not running interactively, don't do anything
[[ $uname == 'Linux' && $- != *i* ]] && return

# arch:
if [[ -e /usr/share/git/completion/git-prompt.sh ]]; then
    source /usr/share/git/completion/git-prompt.sh
# ubuntu:
elif [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
    source /usr/lib/git-core/git-sh-prompt
else
    source ~/scripts/git-prompt.sh
fi

# pass bash completion:
if [[ -e /usr/share/bash-completion/completions/pass ]]; then
    source /usr/share/bash-completion/completions/pass
fi

# helm charts bash completion
source ~/scripts/helm.sh

# PS1 colors:
txtcyn='\e[0;36m'
bldblu='\e[1;34m'
txtrst='\e[0m'

export CHROME_BIN=$(which chromium)
export EDITOR=vim
export GREP_COLOR='1;32'
export PS1="\[$txtcyn\][\w]\$(__git_ps1 '[\[$bldblu\]%s\[$txtcyn\]]')\[$txtrst\]$ "
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export LESS="$LESS -R -Q"

if [[ $TERM != linux && $TERM != *-256color ]]; then
    export TERM=$TERM-256color
fi

# wsl:
if [[ -e /proc/version ]] && grep -q Microsoft /proc/version; then
    cisco_dir=/mnt/c/Users/chris/Cisco
else
    cisco_dir=$HOME/Cisco
fi

alias apollo_mongo='mongo --nodb'
alias arcnewfol="arc diff --reviewers '#fol' --create"
alias arcnewfeb="arc diff --reviewers '#feb' --create"
alias arcnewcli="arc diff --reviewers '#apollo' --create"
alias arcpre='arc diff --preview'
alias arcupd='arc diff --update'
alias away='setJabberStatus away'
alias avail='setJabberStatus available'
alias cdac='cdc api-console'
alias cdia='cdc ironbank-auth'
alias cdiau='cdc ironbank-audit-utils'
alias cdib='cdc banker'
alias cdic='cdc counter'
alias cdicu='cdc ironbank-collection-utils'
alias cdie='cdc entitler'
alias cdil='cdc ironbank-libraries'
alias cdim='cdc migrator'
alias cdis='cdc ironbank'
alias cdssa='cdc CLIAnalyzer'
alias cdsst='cdc CLIAnalyzer/build/standalone/staging'
alias cdui='cdc IronBankApp; cd client'
alias cisco_vpn='sudo vpnc --no-detach /etc/vpnc/default.conf'
alias ffmpeg='ffmpeg -hide_banner'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gau='git add -u'
alias gc='git commit -n'
alias gch='git checkout'
alias gcm='gc -m'
alias gd='git diff -w'
alias gdc='gd --cached'
alias gf='git fetch; git status'
alias gl='git log -w'
alias glg='gl --stat'
alias glp='gl -p'
alias gp='git push'
alias gpl='git pull'
alias grep='grep --color=auto --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=vendor --exclude-dir=dist --exclude-dir=build --exclude-dir=coverage'
alias gst='git status'
alias l='ls -lah'
alias lint='for i in $(gst -s | grep -P '"'"'\.js$'"'"' | awk '"'"'{print $NF}'"'"'); do jshint $i; done'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias pyserver='python -m http.server 3001'
alias pyserver2='python -m SimpleHTTPServer 3001'
alias rename='perl-rename'
alias sa_sync='cp -r ~/Cisco/CLIAnalyzer/build/standalone/staging/ ~/Containers/Current/home/chris/www'
alias set_class_names='grep -rPl "export class" --include="*component.ts" --include="*.service.ts" | xargs perl -pi -e "BEGIN{undef $/;} s/(export class (\w+) .*)/\1Object.defineProperty(\2, '"'"'name'"'"', {\n\tvalue: '"'"'\2'"'"',\n});\n/smg"'
alias snw='cdsst; nw'
alias xlock='xscreensaver-command -lock'
alias xsleep='xlock; sleep 2; systemctl suspend'
alias ubuntu_vm='qemu-system-x86_64 -vga qxl -enable-kvm -m 6G -cpu host -smp 4 -drive file=/home/chris/qemu_vms/ubuntu,format=raw'
alias windows_vm='qemu-system-x86_64 -enable-kvm -m 6G -cpu host -smp 4 -drive file=/home/chris/qemu_vms/windows10,format=raw'
alias wired_auth='sudo wpa_supplicant -D wired -i enp0s25 -c /etc/wpa_supplicant/wpa_supplicant-enp0s25.conf'

# reduce mouse accel for sc2:
# alias get_pointer_id="xinput list | grep -Po 'M325\s+id=\d+.+pointer' | grep -Po '(?<==)\d+'"
alias get_pointer_id='for i in $(xinput list | grep -Po "Viper Mini\s+id=\d+.+pointer" | grep -Po "(?<==)\d+"); do xinput list-props $i | grep -q "libinput Accel Speed (" && echo $i; done'
function set_accel() {
	xinput --set-prop $(get_pointer_id) 'libinput Accel Speed' -0.5
}
function show_accel() {
	xinput list-props $(get_pointer_id) | grep 'libinput Accel Speed (' | cut -d ':' -f 2 | perl -pe 's/^\s*//'
}

# radio stations
alias wcpe='mpv http://audio-mp3.ibiblio.org:8000/wcpe.mp3'
alias wncu='mpv http://playerservices.streamtheworld.com/api/livestream-redirect/WNCUFM.mp3'
alias wsha='mpv http://live.wshafm.org/WSHA'
alias wunc='mpv http://mediaserver.wuncfm.unc.edu:8000/wunc128.m3u'

# safety nets:
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias rm='rm -I --preserve-root'

# history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
export PROMPT_COMMAND='history -a'

source ~/.kube/bash_config.sh

function cdc() {
    cd $cisco_dir/$1
}

function ffmpegSplice() {
    ffmpeg -i $1 -ss 0 -c copy -t $2 cut1.mp4
    ffmpeg -i $1 -ss $3 -c copy cut2.mp4
    printf "file 'cut1.mp4'\nfile 'cut2.mp4'" > ffmpeg_concat.txt
    ffmpeg -f concat -i ffmpeg_concat.txt -c copy result.mp4
    rm cut1.mp4 cut2.mp4 ffmpeg_concat.txt
}

dockerNuke() {
	docker stop $(docker ps -a -q);
	docker rm $(docker ps -a -q) --force;
	docker rmi $(docker images -q) --force;
}

function setJabberStatus() {
    purple-remote setstatus?status=$1
}

function tmpv() {
    mpv https://twitch.tv/$1
}

# PATH:
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin

# OS X: gnu coreutils paths:
if [[ $uname == 'Darwin' ]]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
if [[ -e /usr/share/nvm/nvm.sh ]]; then
    source /usr/share/nvm/nvm.sh
    source /usr/share/nvm/bash_completion
    source /usr/share/nvm/install-nvm-exec
fi
