## These lines for importing these command aliases and functions into .bash_aliases (or .bashrc), the settings file for bash
# `wget https://raw.githubusercontent.com/auwsom/dotfiles/main/.bash_aliases -O ~/.bash_aliases && source ~/.bashrc`
# `wget https://bit.ly/3EjgWdx -O ~/.bash_aliases && source ~/.bashrc`
# `cp -f ~/.bash_aliases /home/user/.bash_aliases && chown user:user /home/user/.bash_aliases`
#shellcheck "$0" # `apt install shellcheck` to check any script for any errors. uncomment line to check this one.

# see further down for more general Linux tips and learning sites

## basic .bashrc settings
echo -ne '\e[?7l' # no line wrap in terminal <---------------- comment this out if you want line wrap
#shopt -s histappend # append to history, don't overwrite it. for using multiple shells at once. is default set in .bashrc
export HISTFILESIZE= #10000        # increase history file size # just leave blank for unlimited
export HISTSIZE= #${HISTFILESIZE}  # increase history list (in memory) size 
HISTFILE=~/.bash_eternal_history # "certain bash sessions truncate .bash_history" (like Screen) SU
#sed -i 's,HISTFILESIZE=,HISTFILESIZE= #,' ~/.bashrc && sed -i 's,HISTSIZE=,HISTSIZE= #,' ~/.bashrc # run once for unlimited. have to clear the default setting in .bashrc
HISTCONTROL=ignoredups:erasedups   # no duplicate entries. ignoredups is onlt for consecutive
#HISTTIMEFORMAT="%h %d %H:%M " # "%F %T "
#export HISTIGNORE="!(+(*\ *))" # ignores commands without arguments. not compatible with HISTTIMEFORMAT. should be the same as `grep -v -E "^\S+\s.*" $HISTFILE`
#export HISTIGNORE="&:ls:[bf]g:exit:pwd:clear:mount:umount" # ignore these single commands
#shopt -s histverify   # confirm bash history (!number) commands before executing. optional for beginners using bang ! commands. can also use ctrl+alt+e to expand before enter.
#alias ha='history -a ' # append current history before opening new terminal, to have it available.
export PROMPT_COMMAND='history -a; set +m' # will save (append) history every time a new shell is opened. unfortunately, it also adds duplicates before they get removed by writing to file. use cron job to erase dups.
#history -w # writes history on every new bash shell to remove duplicates
# `history -a;history -c;history -r` # this will reload history with commands from other shells 
set -o noclobber  # dont let accidental > overwrite. use >| to force redirection even with noclobber
# alias # unalias # put extra space at end of aliased command will make bash look if the next arg is an alias
alias vibash='vi ~/.bash_aliases' # use `vimtutor` to learn (`esc` then `:q` to quit. `ctrl+w` sometimes). or use `nano` editor.
alias rebash='source ~/.bashrc' # have to use `source` command to load the settings file. ~ is home directory
alias realias='\wget https://raw.githubusercontent.com/auwsom/dotfiles/main/.bash_aliases -O ~/.bash_aliases && source ~/.bashrc' 
dircolors -p | sed 's/;42/;01/' >| ~/.dircolors # remove directory colors
shopt -s lastpipe; set +m # allows last pipe to affect shell; needs Job Control disabled +m #https://askubuntu.com/questions/1395963/bash-set-m-option-does-not-work-when-placed-in-the-bashrc-file ..put it in PROMPT_COMMAND
shopt -s dotglob # makes `mv/cp /dir/*` copy all contents, both * and .*; or use `mv /path/{.,}* /path/`
#shopt -s globstar # makes ** be recursive for directories
shopt -s nocaseglob # ignores case of * globs
#if [ -f ~/.env ]; then source ~/.env ; fi # dont use env vars for storing secrets. create dir .env and store files in there. $(cat ~/.env/mykey)
export LC_ALL="C" # makes ls list dotfiles before others
#set -x # show aliases expanded when running them.. but causes too much other noise as debug
function rescue_history { history -a; }; trap rescue_history SIGHUP # saves history on interupt
set -o monitor

# some familiar keyboard shortcuts 
stty -ixon # this unsets the ctrl+s to stop(suspend) the terminal. (ctrl+q would start it again).
#stty intr ^S # this changes the ctrl+c for interrupt process to ctrl+s, to allow modern ctrl+c for copy.
stty lnext ^N # this changes the ctrl+v for lnext to ctrl+b, to allow modern ctrl+v for paste. lnext shows the keycode of the next key typed.
stty susp ^F #stty susp undef; #stty intr undef # ctrl+z for undo have to remove default. https://www.computerhope.com/unix/bash/bind.htm
if [[ "$VIMRUNTIME" != "/usr/share/vim/vim82" ]]; then  # dont run in non-inteactive (ie vim)
bind '"\C-Z": undo' && bind '"\ez": yank'; fi # crtl+z and alt+z (bash bind wont do ctrl+shift+key, will do alt+shift+key ^[z) \e is esc and alt(meta). 
if [[ "$VIMRUNTIME" != "/usr/share/vim/vim82" ]]; then 
bind '"\C-f": revert-line'; fi # clear the line

## short abc's of common commands. be careful when making one letter test files or variables. 
## use \ to escape any alias. `type <command>` is in front to show it's an alias and avoid confusion.
## cant use type in front with sudo, so same name is used only when least confusion.
## aliases need space at end for chaining so can be used before alaised directories or files.
## use `whatis` then command name for official explanation of any command. then command plus `--help` flag or `man`, `info`, `tldr` and `whatis` commands for more info on any command. or q.
# full list of shell commmands: https://www.computerhope.com/unix.htm or `ls /bin`. https://www.gnu.org/software/coreutils/manual/coreutils.html
# list all builtins with `\help`. then `\help <builtin>` for any single one.
alias apt="sudo apt" # also extend sudo timeout: `echo 'Defaults timestamp_timeout=360 #minutes' | sudo EDITOR='tee -a' visudo`
alias b='bg 1' # put background job 1
alias f='fg 1' # put foreground job 1
alias c='clear' # clear terminal
alias cat='cat ' # concatenate (if more than one file) and display. use `realpath` for piping to cat.
alias cd='pushd > /dev/null ' # extra space allows aliasing directories `alias fstab='/etc/fstab '`. use `pd` to go back through dir stack.
alias cdh='cd ~' # cd home.. just use `cd ` with one space to goto home. 
#alias cdb='pd - ' # cd back
alias cdb='cd -' # cd back
alias cdu='cd ..' # change directory up
alias cpa='type cp; cp -ar ' # achive and recursive. but rsync is better because shows progress (not possible with cp without piping to pv). also try `install` command - copies and keeps permissions of target dir. type shows the alias to avoid confusion.
alias cpr='rsync -aAX --info=progress2 ' # copy with progress info, -a --archive mode: recursive, copies symlinks, keeps permissions, times, owner, group, device. -A acls -X extended attributes. -c checks/verify. cant use `type` (to show it is an alias) with sudo in front.
alias df='type df; df -h -x"squashfs"' # "disk free" human readable, will exclude show all the snap mounts
alias du='du -hs' # human readable, summarize
# 'echo' # print <args>. 'exit '.
alias fh='find . -iname' # i means case insensitive. have to use wildcards/globs * to find from partial text. have to be in double quotes (no expansion). -exec needs escaped semicolon \;
alias fr='find / -iname' # use `tldr find` for basics. -L will follow symlinks
alias fm='findmnt' # shows mountpoints as tree
alias g='grep -i ' # search for text and more. "Global Regular Expressions Print" -i is case-insensitive. use -v to exclude. add mulitple with `-e <pattern>`. use `-C 3` to show 3 lines above and below.
alias i='ip -color a' # network info
alias h='history 50'
alias hhh='history' # `apt install hstr`. replaces ctrl-r with `hstr --show-configuration >> ~/.bashrc` https://github.com/dvorka/hstr. disables hide by default.
alias hg='history | grep -i'
#alias hd='history -d -2--1 ' #not working # delete last line. `history -d -10--2` to del 9 lines from -10 to -2 inclusive, counting itself. or use space in front of command to hide. 
alias j='jobs' # dont use much unless `ctrl+z` to stop process
alias k='kill -9' #<id> # or `kill SIGTERM` to terminate process (or job). or `pgreg __` and then `pkill __`
alias kk='kill %1' # kill job 1 gently
alias kj='kill -TERM %1' # terminate job 1
alias loc='locate --limit 5' # `apt install locate` finds common file locations fast (fstab, etc) 
#alias ls='ls -F ' # list. F is --classify with symbols or colors. already included in most .bashrc
#alias la='ls -A' # list all. included. 
alias ll='ls -alFh ' # "list" all long format. included. added human readable. # maybe better:lsl
alias lll='ls -alF ' # "list" all long format. full bytec count. 
alias ltr='ls -ltr ' # "list" long, time, reverse. sorted bottom is latest changed. 
alias lsd='ls -d $PWD/* ' # returns full paths. have to be in the directory. 
alias mo='more ' # break output into pages. or `less`.
alias md='type md; mkdir -p' # makes all --parents directories necessary
alias mf='type mf; touch' # make file. or `echo $text | tee $newfile`. also `netstat`
alias mva='mv -i ' # interactive. -n for no clobber, but cant be used with -i (will not notify)
alias mvu='install -o user -g user -D -t' # target/ dir/* # this copies while keeping target dir ownersperms and ownership. change <user>
alias ncdu='ncdu -x' # manage disk space utility. `apt install ncdu`
alias o='eval $(history -p !!) | read v; echo v=$v' # this var only works with shopt lastpipe and set +m to disable pipe subshells. copies output to $v. 
alias ov='v=$(eval $(history -p !!))' # copies output of last command to $v. also can use xclip and xsel. works without lastpip or set +m.
alias p='echo $PATH' # show path
#alias pd='pushd ' # a way to move through directories in a row (https://linux.101hacks.com/cd-command/dirs-pushd-popd/) ..aliased as `cd`
alias pd='popd' # going back through the 'stack' history
alias psa='ps -ef' # show processes
#alias psp='ps -o ppid= -p ' # <PID> show parent PID
alias psp='ps -Flww -p' # <PID> show info on just one process
alias pgrep='pgrep -af' # grep processes - full, list-full. use \pgrep for just the PID.
alias pkill='pkill -f' # kill processed - full
# p for pipe `|` a very powerful feature of shell language. transfers command output to input next command.
alias q='helpany' # see helpany function
alias rm='rm -Irv ' # make remove confirm and also recursive for directories by default. v is for verbose. 
# ^^maybe most helpful alias^^, avoids deleting unintended files. use -i to approve each deletion.
alias sudo='sudo '; alias s='sudo '; alias sd='sudo -s ' # elevate privelege for command. see `visudo` to set. And `usermod -aG sudo add`, security caution when adding.
alias sss='eval sudo $(history -p !!)' # redo with sudo
alias ssh='ssh -vvv ' # most verbose level
alias sortn='sort --numeric-sort' # `sort --human-numeric-sort` `unique`. Find dupiclates `sort <file> | unique -c | sort -nr`
# `stat` will show file info including rwx octet value of perms.
alias t='touch' # new file. see mf also.
alias top='htop' # `q` to exit (common in unix). htop allows deleting directly. `apt install htop`
alias tree='tree -h --du -L 2' #<dir>. `apt install tree`
# `type` will show info on commands and show functions
alias untar='tar -xvf' # -C /target/directory
alias urel='cat /etc/os-release' # show OS info
alias vi='vi ' # needs space at end for alias chaining
#alias w='whatis ' # display one-line manual page descriptions
#alias w='whereis ' # locate the binary, source, and manual page files for a...
#alias w='which ' # locate a command
alias x='xargs ' # take last output and pipe into new command. not all commands support it, but many do
# use `xargs -I % some-command %` to use output as non-standard argument
alias rrr='reboot' # uncomment if you want this. also `systemctl reboot`. DE `reboot -t 120`   
alias zzz='systemctl poweroff' # also `systemctl halt` or `shutdown -H now`. halt leaves on


### more advanced:
alias sze='7z x -o*' # extracts in to subdirectory
alias au='sudo apt update'
alias auu='sudo apt update && apt -y upgrade' # show all users logged in. `last` show last logins
alias aca='sudo apt clean && sudo apt autoremove'
alias bc='BC_ENV_ARGS=<(echo "scale=2") \bc'
alias cu='chown -R $USER:$USER' # change ownership to current user
alias cur='chown -R root:root' # change ownership to root
alias cx='chmod +x' # make executable
alias cm='chmod -R' # change perms to rwx octet
alias cm7='chmod -R 777' # change perms to all
alias comm='comm -12 <(sort a.txt) <(sort b.txt)' # compares and shows all same lines of tex. `comm -12` for diffs
alias diff='diff -y --color --brief' # compare. -y show. --breif only shows diffs. Use Meld for GUI.
alias dedup="tac /root/.bash_history | awk '!a[$0]++' | tac > /root/.bash_history" 
alias dmesg='type dmesg; dmesg -HTw' # messages from the kernel, human readable, timestamp, follow
alias dli='tac /var/log/dpkg.log | grep -i "install"' # list installed packages
alias aptli='apt list | grep -i "installed"' # list installed apt packages
alias aptlig='apt list | grep -i "installed" | grep -i' # list installed apt packages
alias dpkglk='dpkg --list | grep -i -E "linux-image|linux-kernel" | grep "^ii"' # list kernels
alias dpkgll='grep -i install /var/log/dpkg.log' # list last installed
alias dpkgli='dpkg --listfiles' # -L package file install locations. reverse search for pkg from file `dpkg -S <file>`. `apt-files --list <pkg>` also works, but not for Snaps.
alias dpkgrc='dpkg-reconfigure -a' # use when apt install breaks. use `apt -f install` install dependencies when using `apt install debfile.deb`
alias ds='dirs' # shows dir stack for pushd/popd
# dbus-monitor, qdbus
# `env` # shows environment variables
alias r='fc -s' #<query> # search and rerun command from history. shebang is similar !<query> or !number. fc -s [old=new] [command]   https://docs.oracle.com/cd/E19253 (fix command)
alias fsck='type fsck; fsck' #-p automatically fix. or use -y for yes to all except multiple choice.
alias redo='fc -s ' # redo from history. see fc.
alias fn='find . -iname ' # find, search in name
alias flmr='find / -type d \( -name proc -o -name sys -o -name dev -o -name run -o -name var -o -name media \) -prune -o -type f -mmin -1 '
alias flmh='find ~ -type d \( -name .cache -o -name .mozilla \) -prune -o -type f -mmin -1 '
alias flm='find . -type f -mmin -1 '
alias free='type free; free -h ' # check memory, human readable
alias gm='guestmount -i $file -a /mnt' # set file=<vm/partition-backup> first 
# `inotifywait -m ~/.config/ -e create -e modify` (inotify-tools), watch runs every x sec, entr runs command after file changes. use examples from bottom of `man entr` `ls *.js | entr -r node app.js`
alias jo='journalctl' # -p,  -err, --list-boots, -b boot, -b -1 last boot, -r reverse, -k (kernel/dmesg), -f follow, --grep -g, --catalog -x (use error notes), -e goto end
alias jof='journalctl -f' # follow.
alias ku='pkill -KILL -u user ' # kill another users processes. use `skill` default is TERM.
alias lsblk='lsblk -f' # -f lists UUIDs and percent full
alias lsof='type lsof; lsof -e /run/user/*' # remove cant stat errors
#alias lnf='ln -f ' # symlink. use -f to overwrite. <target> <linkname>
alias netstat='type netstat; netstat -atnp' 
alias pegrep='grep -P ' # PCRE grep https://stackoverflow.com/a/67943782/4240654
alias perl='type perl; perl -p -i -e ' # loop through stdin lines. in-place. use as command. https://stackoverflow.com/questions/6302025/perl-flags-pe-pi-p-w-d-i-t
alias pingt='type ping; ping -c 3 8.8.8.8' # ping test. count 3. google ip.
alias pip='type pip; pip3 --verbose'
#alias pipd='pip --download -d /media/user/data ' 
alias pstree='pstree ' # shows what started a process
alias py='type py; python3 ' 
alias ra='read -a ' # reads into array/list. 
alias rkonsole='/home/user/.config/autostart-scripts/konsole_watcher.sh restore' # restore konsole tabs
alias rplasma='pkill plasmashell && plasmashell & ' # restart plasmashell in KDE Kubuntu
alias sys='systemctl' # `enable --now` will enable and start
alias sysl='systemctl list-unit-files ' # | grep <arg>
alias tc='truncate -s' # <size, eg 10G> creates dynamic file; format with mkfs.ext4; `ls -s` to show true size on disk. use fallocate --length 1GiB for swapon /swapfile. 
alias tc0='truncate -s 0' # reset file with zeros to wipe. also use wipe -qr.
alias u='users' # show all users logged in. `last` show last logins
alias unamea='uname -a' # show all kernel info 
#alias uname='uname -a ' # show all kernel info 
#alias w='w ' # Show who is logged on and what they are doing. Or `who`.
alias wget='type wget; wget --no-clobber --content-disposition --trust-server-names' # -N overwrites only if newer file and disables timestamping # or curl to download webfile (curl -JLO)
alias wdu='watch du -d1 .' # `watch du -s <dir>`
alias zzr='shutdown -r now || true' # reboot in ssh, otherwise freezes
alias zzs='shutdown -h now || true' # shutdown in ssh, otherwise freezes
# common typos
alias unmount='umount' ; alias um='umount' ; alias mounts='mount' ; alias m='type m; printf "\033[?7l"; mount | g -v -e cgroup -e fs; printf "\033[?7h"' ; alias ma='mount -a' ; alias mg='mount | grep'; alias mr='mount -o remount,rw'; 
alias umf='umount -l' # unmount lazy works when force doesnt
# change tty term from cli: `chvt 2`
# keyrings https://itnext.io/what-is-linux-keyring-gnome-keyring-secret-service-and-d-bus-349df9411e67 
# encrypt files with `gpg -c`

## extra stuff
# `!!` for last command, as in `sudo !!`. `ctrl+alt+e` expand works here. `!-1:-1` for second to last arg in last command.
# `vi $(!!)` to use output of last command. or use backticks: vi `!!`
# `declare -f <function>` will show it
# export -f <alias> # will export alias as function to be used in scripts. or source .bash_aliases after settinge `shopt -s expand_aliases`
set -a # sets for export to env the following functions, for calling in scripts and subshells (aliases dont get called).
function hdn { history -d $1; history -w; } # delete history line number
function hdl { history -d $(($HISTCMD - 1)); history -w; } # delete history last number
function hdln { history -d $(($HISTCMD - $1 -1))-$(($HISTCMD - 2)); history -w; } # delete last n lines. (add 1 for this command) (history -d -$1--1; has error)
function help { $1 --help; } # use `\help` if you ever want to see the default commands list
function hh { $1 --help; } 
function helpany { $1 --help || help $1 || man $1 || info $1; } # use any of the help docs. # also use tldr. 
function ren { mv $1 $2; } # rename
function sudov { while true; do sudo -v; sleep 360; done; } # will grant sudo 'for 60 minutes
function addpath { export PATH="$1:$PATH"; } # add to path
function addpathp { echo "PATH="$1':$PATH' >> ~/.profile; } # add to path permanently
set +a
# `unset -f foo`; or `unset -f` to remove all functions
export CDPATH=".:/home/user" # can cd to any dir in user home from anywhere just by `cd Documents`
#export CDPATH=".:/etc" # just type `cd grub.d`
#export CDPATH=".:/" # could use at root to remove need for typing lead /, but could cause confusion
export VISUAL='vi' # export EDITOR='vi' is for old line editors like ed
# ! dont use single quotes when setting `export PATH="_:$PATH"`. single quotes do not do parameter expansion.
# export TERM='xterm' # makes vim use End and Home keys. but only vt220 on ubuntu cloud image

## key bindings. custom emacs. or use `set -o vi` for vim bindings. `set -o emacs` to reverse.
# bind -p # will list all current key bindings. https://www.computerhope.com/unix/bash/bind.htm
# ***very helpful*** press `ctrl+alt+e` to expand the symbol to show. press double keys slowly to use normally. 
# `bind -r <keycode>` to remove. use ctrl+V (lnext) to use key normally. https://en.wikipedia.org/wiki/ANSI_escape_code
# `set -o posix ; set` or `set | more` lists all variables
#if [[ "$VIMRUNTIME" != "-" ]]; then bind '"\\\\": "|"'; fi # quick shortcut to | pipe key. double slash key `\\` (two of the 4 slashes are escape chars)
if [[ "$VIMRUNTIME" != "/usr/share/vim/vim82" ]]; then bind '",,": "!$"'; fi # easy way to get last argument from last line. can expand. delete $ for ! bang commands.
#if [[ "$VIMRUNTIME" != "-" ]]; then bind '",.": "$"'; fi # quick shortcut to $ key. 
#bind '"..": shell-expand-line' # easy `ctrl+alt+e` expand
#if [[ "$VIMRUNTIME" != "-" ]]; then bind '".,": "$(!!)"'; fi # easy way to add last output. can expand
#if [[ "$VIMRUNTIME" != "-" ]]; then bind '"///": reverse-search-history'; fi # easy ctrl+r for history search.
#if [[ "$VIMRUNTIME" != "-" ]]; then bind '\C-Q: shell-kill-word'; fi # crtl+q is erase forward one word. (ctrl+a, ctrl+q to change first command on line)
bind 'set show-all-if-ambiguous on' # this makes only one Tab necessary to show completion possibilities

: <<'END' 
basic bash commands:
`fdisk -l` # partition table list. also see `cfdisk` for changing
`blkid` # block id
`lsblk` # list block `lsblk --output UUID /dev/sda1`
`mount` # list mounts. or `findmnt` list as tree
`df -h` # filesystem disk usage, human readable
`du -sh`; `du -cd1 . | sort -n` # disk usage --summarize --human-readable or du --total --max-depth 1 pipe to sort numerically
`ncdu -x /` # `apt install ncdu` to find disk usage to delete when full
`ps -ef | grep`   # process snapshot --all in `full format` then search for text string
`kill -9 <pid>` `kill -TERM <pid>` `pidof <> | xargs kill` `pkill` to kill processes
`systemctl status | grep`   # systemctl is the current process manager using services
`uname -a`   # get quick system info
`cat /etc/*release`   # get kernel info
`dircolors -p | sed 's/;42/;01/' >| ~/.dircolors`   # if you need to remove colorization
press `ctrl+alt+e` to expand symbols to show them, such as `!!`
clear line: `ctrl+e`,`ctrl+u` goto end then clear to left, (or ctrl+a, ctrl+k)
cut left word `ctrl w`, paste that word `ctrl y`, use `alt d` to cut forward
undo like this : `ctrl+_`
creation time if available: `stat`
terminal key shortcuts: `stty -a`
search history reverse (type afterward): `ctrl+r`, go forward `ctrl+f`. `ctrl+g` cancels. `alt(meta)+>` go back to history bottom.
ways to kill runaway process: `ctrl+c`, `ctrl+d` (exit current shell), `ctrl+\` 
apt: remove. purge deletes config except in home dir. autoremove deletes unused.    
apt -s, --simulate, --just-print, --dry-run, --recon, --no-act  = No action; perform a simulation..
`apt show <package>` shows size, unlike simulate, even if not installed, but sizes not same as install info
conditional expressions, if [  ];then ;fi, `man bash` search / comparsion, https://tldp.org
learnshell.org
linuxcommand.org
https://linux.101hacks.com/toc/ CDPATH info
https://www.gnu.org/software/bash/manual/html_node/index.html#SEC_Contents
END

## common dirs and files: # need extra space in alias for commands on files
shopt -s cdable_vars # makes directories aliasable. see bottom for commonly used directories
alias alias1='~/.bash_aliases' 
alias fstab='/etc/fstab' #dir
#alias passwd1'/etc/passwd' #dir
alias group1='/etc/group' #dir
alias shadow='/etc/shadow' #dir
alias sudoers='/etc/sudoers' #dir
alias grub1='/etc/default/grub' #dir
alias grubd='/etc/default/grub.d/' #dir
alias sources='/etc/apt/sources.list' #dir
alias sourcesd='/etc/apt/sources.list.d/' #dir
alias crontab1='/etc/crontab' # runs /etc/cron.daily and /etc/cron.hourly. `crontab -e` is official /var/spool/cron/crontabs/root #dir
alias crondd='/etc/cron.d/' #dir # misc cron files 
alias crond='/etc/cron.daily' #dir
alias cronh='/etc/cron.hourly' #dir
alias cronw='/etc/cron.weekly' #dir
alias cronm='/etc/cron.monthly' #dir
alias resolv='/etc/resolv.conf' #dir # resolvectl status
alias hosts1='/etc/hosts' #dir
alias log='/var/log/' #dir # logs: syslog auth.log boot.log lastlog
#alias netman='/etc/network/interfaces' # `man interfaces`#dir
alias netplan1='/etc/netplan/01-netcfg.yaml' # add `optional: true` under ethernets: interface: to prevent boot waiting on network #dir
alias known='~/.ssh/known_hosts' # rm this to remove unused store ssh connections
alias mailr='/var/mail/root ' # mail #dir
alias osr='/etc/os-release' # os name #dir
alias sysd='/etc/systemd/system/multi-user.target.wants' # services startup #dir
alias userd='/home/user' #dir 
export hh="--help" # can use like `bash $hh` (man bash)
# /etc/skel has default user home files
# common directories: # need extra space in alias for commands on files
# /var/cache/apt/archives/ (use apt clean?)visudo
# /proc/cmdline, /dev/disk/by-id (etc), /proc, /dev, /media/user, /home/user
# admin commands: last, w, who, whoami, users, login, uptime, free -th, mpstat, iostat, bashtop, ssh, lsof, lspci, dmesg, dbus, strace, 
# editing: `sed -i 's/<search>/<replace>/g' (g global optional), `awk '{ print $1 }' file` for printing column(s)
# info: file, stat, type, date, +date %F,
# `locate *.desktop`
# `locate *.desktop | grep -v usr` shows program shortcuts location. also: https://askubuntu.com/questions/5172/running-a-desktop-file-in-the-terminal

## basic settings:
# be careful of your filesystem filling up space as it will freeze your OS.. ways to deal with that: create a large dummy file that can be erased, like swapfile, `echo 'SystemMaxUse=200M' >> journald.conf` then limit /tmp and /home 
# use `sudo -s` to elevate user but stay in same user environment (history and bashrc prefs). 
# add user to sudo group: `usermod -aG sudo user` to protect root user (can remove privelege from user if needed)
# careful with changing all permissions to 777: https://superuser.com/questions/132891/how-to-reset-folder-permissions-to-their-default-in-ubuntu

## basic vim settings: 
if ! [[ -f ~/.vimrc ]]; then
echo -e '
nnoremap <c-z> <nop> "no ctrl-z stop because exits without saving and makes .swp file"
set nocompatible
set showmode
set whichwrap+=<,> "arrow key wraparound"
"set number   "set nonumber" "set nu" "set nonu"
set autowrite
set autoindent
set ruler "set ru"
set wrapscan 
set hlsearch
autocmd InsertEnter,InsertLeave * set cul!
if has("autocmd")\n
  au BufReadPost * if line("'\''\"") > 0 && line("'\''\"") <= line("$") | exe "normal! g`\"" | endif\n
endif
set autowrite "save before run, also when changing buffer"
nnoremap <F5> :!clear && %:p<Enter> "run script in normal mode" 
inoremap <F5> <esc>:!clear && %:p<enter> "in insert mode too"
let $BASH_ENV = "~/.bash_aliases" "<--to use aliases in vi plus `shopt -s expand_aliases`"
"set list " shows hidden characters
"set ruf " ruler format
set tabstop=4       " The width of a TAB is set to 4.
set shiftwidth=4    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces
set shell=/bin/bash
nnoremap <F3> :set hlsearch!<CR> "toggle search highligh. or use :noh"
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
' >| ~/.vimrc >| ~/.vimrc   # > to not overwrite 
fi
# basic vim commands: https://gist.github.com/auwsom/78c837fde60fe36159ee89e4e29ed6f1
# `:e <filename>` to open file or `:e .` to browse directory 
# `:!bash %` to run script from within vim
# vim tabs: (open multiple files or open more from inside vim) then `gt` and `gT` for forward/back, `2gt`, `:tabs` list
# https://askubuntu.com/questions/202075/how-do-i-get-vim-to-remember-the-line-i-was-on-when-i-reopen-a-file
# more ideas: https://github.com/amix/vimrc, https://github.com/rwxrob/dot/blob/main/vim/.vimrc
# https://rwxrob.github.io/vi-help/
# deindent ctrl-D
# https://github.com/tpope/vim-sensible # sensible settings repo
shopt -s expand_aliases # to use bash aliases inside vi plus the `let $BASH_ENV = "~/.bash_aliase` in .vimrc

: <<'END3'
## tmux   wget https://raw.githubusercontent.com/rwxrob/dot/main/tmux/.tmux.conf
# tmux a # to attach (start) old session. C-a,d to detach. C-a,x to close. C-a,: for command mode.
# C-a,[ for copy mode, q to quit, space to start selection, enter to copy, C-a,] to paste
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# C-b + I (shift+i) to install plugins with tpm
echo -e "
set -g prefix C-a # change default prefix to match Screen's
set mouse on # allows scrolling # !! hold shift to select text 
set -g status-style "fg=#665c54"
set -g status-bg default
set-option -g status-interval 5
set-option -g automatic-rename on
set-option -g automatic-rename-format '#{b:pane_current_path}'
bind-key C-a last-window
bind c new-window -c "#{pane_current_path}"
bind -r r source-file ~/.tmux.conf

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-resurrect' # C-s, C-r  to save and restore
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @continuum-restore 'on' # every 15 min
run '~/.tmux/plugins/tpm/tpm'
" >> ~/.tmux.conf
alias remux='tmux source ~/.tmux.conf' # reload tmux
# https://tmuxcheatsheet.com/
# Scrolling: Ctrl-b then [ then you can use your normal navigation keys to scroll around (eg. Up Arrow or PgDn). Press q to quit scroll mode.
END3

## basic git settings
alias gs='git status '
alias gl='git log '
alias gb='git branch '
alias ga='git add . '
alias gc='git commit -m "commit" '
alias gac='ga && gc ' #git
alias gacp='gs && ga && gc && gph ' #git
#alias gph='git push -u origin main '
alias gph='git push '
alias gpl='git pull ' # (git fetch && git merge) 
# git clone is for first copy # git status, git log, git branch
# git clone https://github.com/auwsom/dotfiles.git # add ssh priv and pub key, and will pull but not push
# git clone git@github.com:auwsom/dotfiles.git # will ask to connect. need to `eval $(ssh-agent -s) && ssh-add ~/.ssh/id_rsa` (will display email of GH account) 
## add from local creatJust found this tool called Briefcase to deploy python apps to 6 platforms (mac,win,linux,ios,android,web) looks great. Produces standalone binariese:
# `apt install gh` then click enter until auth through webpage
alias gi='git init  && git remote add origin git@github.com:auwsom/<newrepo>.git  && git branch -M main'
alias gi2='gh repo create <newrepo> --public '
alias gi3='git add . && git push --set-upstream origin main'
# git config --global init.defaultBranch main 
# https://www.freecodecamp.org/news/how-to-make-your-first-pull-request-on-github-3/


# mv ~/.bash_aliases ~/.bash_aliases0 && ln -s ~/git/dotfiles/.bash_aliases ~/.bash_aliases
# to push new repo from CLI you have to create it using curl and PERSONAL_ACCESS_TOKEN.
#[Configure GitHub SSH Keys - YouTube](https://www.youtube.com/watch?v=s6KTbytdNgs?disablekb=0)
#git-cheatsheet.com
#[Learn Github in 20 Minutes - YouTube](https://www.youtube.com/watch?v=nhNq2kIvi9s)
#[Git MERGE vs REBASE - YouTube](https://www.youtube.com/watch?v=CRlGDDprdOQ) use merge squash
# undo last commit added to remote `git reset --soft HEAD~` then `git pull -f` 
#https://alvar3z.com/blog/git-going-gud/
# delete a file from all commits: git filter-branch --index-filter     'git rm -rf --cached --ignore-unmatch <file>' HEAD


## misc linux/ubuntu help
# -- marks the end of the option list. This avoids issues with filenames starting with hyphens.
# renaming extensions `for f in file*.txt; do echo/mv "$f" "${f/%txt/text}"; done`
# `apt --fix-broken install` or `dpkg --configure -a`
# `apt clean` then `apt purge <package>` to uninstall package broken from out of disk space.
# use `apt purge *<old kernel number>*` to clear out old kernels for space. orr `journalctl --vacuum-size=5M`
# `apt purge <package>` doesnt erase anything in home dir
# list installed packages by date: `grep " install " /var/log/dpkg.log` or `apt-mark showmanual` (`apt-mark minimize-manual` is supposed to unmark all dependencies) (zgrep will search /var/log/dpkg.log.2.gz files)
# `apt install mlocate ncdu htop`
# ext4magic and testdisk (extundelete defunct segfault) can only recover files because of ext#. keeping data on ntfs has structure info in journal.
# `ntfsundelete /dev/hda1 -t 2d` Look for deleted files altered in the last two days

# bash wildcards (glob/global): `*(pattern|optional-or) ? * + @ ! https://www.linuxjournal.com/content/bash-extended-globbing
# `egrep "(a)(.*b)"` matches everything between a and b inclusively. 
# test regex (non-lookahead) https://regex101.com/
# lookahead can match any combination of `(?=.*word1)(?=.*word2)(?=.*word3)` https://www.ocpsoft.org/tutorials/regular-expressions/and-in-regex/

#alias -p | g ' u=' | xargs -I % bash -c "sed -i 's/="/=" type _ ; /' %"
# wget rc files
#
export home='/home/user' # for setup, $home variable
# firewall
alias us='ufw status'
alias usv='ufw status verbose'
alias usn='ufw status numbered'
alias ue='ufw enable'
alias ud='ufw disable'
alias uh='ufw logging high'
alias ul='ufw logging low'
alias il='iptables -L'
alias ill='iptables -L --line-numbers'
# `watch -n 2 -d iptables -nvL` # shows blocking realtime
# arp && 
alias bs='brctl show'

alias vl='virsh list '
alias vc='virsh console '
alias vnl='virsh net-list '
#virsh net-destroy default && virsh net-start default # use GUI

#`echo foobar | tr "bar" "substituded"
# echo -e allows \n, sed -i is inplace, perl -pie uses better regex

# python
alias py='python3'
# `py -m venv <name>; `source <path>/bin/activate`

# nerd-dictation voice commands
alias list='ll '

# ble - Bash autosuggestion
# https://github.com/akinomyoga/ble.sh
#bleopt complete_auto_complete= # Disable auto-complete 





