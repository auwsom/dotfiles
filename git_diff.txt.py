diff --git a/.bash_aliases b/.bash_aliases
index 75cc814..b1edf12 100644
--- a/.bash_aliases
+++ b/.bash_aliases
@@ -9,24 +9,12 @@
 # add to sudo -E visudo for cache across tabs.. Defaults:user   timestamp_timeout=30, !tty_tickets, timestamp_type=global
 echo CDPATH dirs: $CDPATH # to see which dirs are autofound (can be annoying with tab complete)
 
+# default bash emacs keybindings. you can also use `set -o vi` for vim keybinding navgation: ^@:null-char ^A:beginning-of-line ^B:backward-char ^C:SIGINT ^D:EOF ^E:end-of-line ^F:forward-char ^G:abort ^H:backward-delete-char ^I:tab ^J:newline ^K:kill-line ^L:clear-screen ^M:newline ^N:next-history ^O:reserved ^P:previous-history ^Q:flow-control ^R:reverse-search ^S:flow-control ^T:transpose-chars ^U:kill-line ^V:quoted-insert ^W:word-rubout ^X:reserved ^Y:yank ^Z:SIGTSTP ^[:escape/meta-prefix ^\\:SIGQUIT ^]:unbound ^^:unbound ^_:unbound
+
 
 true <<'END' # skips section to next END
 temp notes:
-echo "export EDITOR=vi" >> ~/.bashrc
-sudo -E visudo # no nano
-aimgr ALL=(ALL:ALL) NOPASSWD: /usr/bin/tmux, /usr/sbin/useradd, /usr/bin/passwd[ags] # couldnt get working
-allow sudo tmux -S /home/user/shared_tmux/shared_tmux_socket attach-session # couldnt get working
-ttyd -W -p 8889 bash
-
-ps aux (BSD-style options)
-a – Show processes from all users.
-u – Display user-oriented output (includes user, CPU/mem usage, start time, etc.).
-x – Show processes without a controlling terminal (like daemons).
-ps -ef (UNIX-style options)
--e – Show all processes.
 END
-alias rts="sed -i 's/[[:space:]]*$//'" # <file> remove trailing spaces on every line
-
 
 #if ! [[ $- == *i* ]]; then true "<<'ENDI'"; fi # this skips this file when running scripts
 [[ -t 0 ]] && true "<<'ENDI'" # this skips this file when running scripts
@@ -44,7 +32,8 @@ HISTCONTROL=ignoreboth:erasedups   # no duplicate entries. ignoredups is only fo
 #HISTTIMEFORMAT="%h %d %H:%M " # "%F %T " # adds unix epoch timestamp before each history: #1746739135. then "1836  May 08 14:21 cat .bash_history"
 #export HISTIGNORE="!(+(*\ *))" # ignores commands without arguments. not compatible with HISTTIMEFORMAT. should be the same as `grep -v -E "^\S+\s.*" $HISTFILE`
 export HISTIGNORE="c:cdb:cdh:cdu:df:i:h:hh:hhh:l:lll:lld:lsd:lsp:ltr::mount:umount:rebash:path:env:pd:ps1:sd:top:tree1:zr:zz:au:auu:aca:cu:cur:cx:dedup:dmesg:dli:aptli:d:flmh:flmho:flmr:fm:free:lsblk:na:netstat:ping1:wrapon:wrapoff:um:m:hdl" # :"ls *":"hg *" # ignore commands from history
-#export PROMPT_COMMAND='history -a' # ;set +m' # will save (append) unwritten history in memory every time a new shell is opened. unfortunately, it also adds duplicates before they get removed by writing to file. use cron job to erase dups. set +m makes disables job control for aliases in vi.
+#export PROMPT_COMMAND='history -a' # ;set +m' # will save (append) unwritten history in memory every time a new shell is opened. unfortunately, it also adds duplicates before they get removed by writing to file. use cron job to erase dups. 
+#set +m # disables job control to allow use of bash aliases in vi.
 #export PROMPT_COMMAND='EC=$? && history -a && test $EC -eq 1 && echo error $HISTCMD && history -d $HISTCMD && history -w' # excludes errors from history
 #export PROMPT_COMMAND='history -a ~/.bash_history_backup' # writes to backup file instead of polluting every terminal with all history. doenst work
 export PROMPT_COMMAND='history -a; tail -n1 ~/.bash_eternal_history >> ~/.bash_history_backup' # writes to central backup file instead of polluting every terminal with all history. search it with hg2
@@ -64,7 +53,7 @@ alias realiasr2='cd /home/user/git/dotfiles && git fetch origin && git checkout
 alias revim='rm ~/.vimrc && source ~/.bashrc' # redo vim settings. below import is blocked for existing .vimrc
 ## `shopt` list shell options. `set -o` lists settings. `set -<opt>` enables like flag options.
 set -o noclobber  # dont let accidental > overwrite. use >| to force redirection even with noclobber
-shopt -s lastpipe; set -o monitor # (set +m). allows last pipe to affect shell; needs Job Control enabled. for the o output alias.
+shopt -s lastpipe # allows last pipe to affect shell for the o (output) alias. needs Job Control enabled (set -m). `set -o monitor` will check job control state.
 shopt -s nocaseglob # ignores upper or lower case of globs (*)
 shopt -s dotglob # uses all contents both * and .* for cp, mv, etc. or use `mv /path/{.,}* /path/`
 shopt -s globstar # makes ** be recursive for directories. use lld below for non-recursive ls.
@@ -85,18 +74,13 @@ IFS=$' \t\n' # restricts "internal field separator" to tab and newline. handles
 echo -ne "\033[?7h" # set line wrap on
 
 
-## some familiar keyboard shortcuts: 
+## some familiar keyboard shortcuts (cat -v; showkey -a; xev; are all good tools to show kep mapping: 
 stty -ixon # this unsets the ctrl+s to stop(suspend) the terminal. (ctrl+q would start it again).
-stty intr ^S # changes the ctrl+c for interrupt process to ctrl+s, to allow modern ctrl+c for copy.
+stty intr ^S # changes the ctrl+c for interrupt process to ctrl+s, to allow modern ctrl+c for copy. ctrl-shift-c will show ^S with this line if it is remapped in terminial.
 stty susp ^Q #stty susp undef; #stty intr undef # for bind ctrl+z to undo have to remove default. https://www.computerhope.com/unix/bash/bind.htm
-[[ $- == *i* ]] && bind '"\C-Z": undo' && bind -x '"\C-c": "printf %s $READLINE_LINE | xclip -selection clipboard"' # this copies (whole line unless region selected by mouse) to desktop clipboard like modern ^c
-# bind '"\C-c": copy-region-as-kill' # use ctrl+space to start mark, then ^c to copy and then ^y to paste
-
-
-
-# if [[ $- == *i* ]]; then trap '' SIGINT && bind '"\C-Z": undo' ; fi # crtl+Z (cant remap C-z yet) and alt+z (bash bind wont do ctrl+shift+key, will do alt+shift+key ^[z) \e is es (c&& bind '"\ez": yank' and alt(meta). # dont run in non-inteactive (ie vim) # (usually ctrl+/ is undo in the bash cli)
-stty lnext ^N # changes the ctrl+v for lnext to ctrl+b, to allow modern ctrl+v for paste. lnext shows the keycode of the next key typed.
-#if [[ $- == *i* ]]; then bind '"\C-f": revert-line'; fi# clear line. use ctrl-shift-c or C-c or C-\
+[[ $- == *i* ]] && bind '"\C-Z": undo' && bind -x '"\C-c": "printf %s $READLINE_LINE | xclip -selection clipboard"' # this copies (whole line unless region selected by mouse) to desktop clipboard like modern ^c # wont run in non-inteactive (ie vim)
+# alternaitve: bind '"\C-c": copy-region-as-kill' # use ctrl+space to start mark, then ^c to copy and then ^y to paste
+stty lnext ^_ # changes the ctrl+] for lnext to ctrl+], to allow modern ctrl+v for paste. lnext shows the keycode of the next key typed.
 #[ -f ~/.xmodmaprc ] || printf $'keycode 20 = underscore minus underscore minus' > ~/.xmodmaprc && xmodmap ~/.xmodmaprc # swap minus and underscore. nearly impossible to remap ctrl-space to underscore.
 
 ## short abc's of common commands: (avoid one letter files or variables to avoid conflicts)
@@ -107,9 +91,7 @@ stty lnext ^N # changes the ctrl+v for lnext to ctrl+b, to allow modern ctrl+v f
 # use `whatis` then command name for official explanation of any command. then command plus `--help` flag or `man`, `info`, `tldr` and `whatis` commands for more info on any command. or q alias below.
 # full list of shell commmands: https://www.computerhope.com/unix.htm or `ls /bin`. https://www.gnu.org/software/coreutils/manual/coreutils.html
 # list all builtins with `\help`. then `\help <builtin>` for any single one.
-#alias ag='alias | grep' # search the aliases for commands. function below shows comments too.
-#function ag(){ grep "$1" ~/.bash_aliases; }
-function ag(){ type ag | tr -d '\n'; echo; grep "$1" ~/.bash_aliases; } # make type declare one line
+alias ag='alias | grep' # search the aliases for commands
 alias apt="sudo apt" # also extend sudo timeout: `echo 'Defaults timestamp_timeout=360 #minutes' | sudo EDITOR='tee -a' visudo`
 alias b='bg 1' # put background job 1
 alias f='fg 1' # put foreground job 1
@@ -127,7 +109,6 @@ alias cpa='type cp; cp -ar ' # achive and recursive. rsync is will show progress
 # type shows the alias to avoid confusion. but cant use type in combo with sudo.
 alias cp='cp -ir' # copy interactive to avoid cp with files unintentionally. use `find <dir> -type f -mmin -1` to find files copied in last 1 min. then add `-exec rm {} \;` once sure to delete. or `find <dir> -maxdepth 1 -type f -exec cmp -s '{}' "$destdir/{}" \; -print` can compare dirs. -a vs -R.
 alias cpr='rsync -aAX --info=progress2 ' # copy with progress info, -a --archive mode: recursive, copies symlinks, keeps permissions, times, owner, group, device. -A acls -X extended attributes. -c checks/verify. cant use `type` (to show it is an alias) with sudo in front.
-function install1 { sudo install -o "$(stat -c '%U' "$(dirname "$2")")" -g "$(stat -c '%G' "$(dirname "$2")")" "$1" "$2"; } # copies but uses target dir ownership, though doesnt set group yetv
 alias df='type df; df -h -x"squashfs"' # "disk free" human readable, will exclude show all the snap mounts
 alias du='du -hs' # human readable, summarize. 
 alias du1='\du -cd1 . | sort -n' # du --total --max-depth 1, pipe to sort numerically
@@ -140,7 +121,8 @@ alias fn='find . -not -path excluded -o -exec echo {} \;' # find with excluded b
 alias fl='find . -cmin -10' # created last 10 min (or use ctime for days). or mmin/mtime, amin/atime
 alias fd='find . -cmin -10 -exec "\rm -r {} ;"' # find recent and delete. see above for alts.
 alias g='grep -i ' # search for text and more. "Global Regular Expressions Print" -i is case-insensitive. use -v to exclude. add mulitple with `-e <pattern>`. use `-C 3` to show 3 lines of context.
-alias i='ip -color a' # network info
+alias i='ip -color a' # network info ip addresses
+alias i2='curl ifconfig.me' # get external ip address
 alias h='history 30'
 alias hhh='history 500' # `apt install hstr`. replaces ctrl-r with `hstr --show-configuration >> ~/.bashrc` https://github.com/dvorka/hstr. disables hide by default.
 alias hg='history | grep -i'
@@ -185,7 +167,7 @@ alias pkill='pkill -f' # kill processed - full
 alias q='helpany' # see helpany function
 alias rm0='rm -Irv ' # -I requires confirmation. -r recursive into directories. -v verbose. 
 # ^^^^^ maybe most helpful alias. avoids deleting unintended files. use -i to approve each deletion.
-function rm { type rm | tr -d '\n'; echo; mkdir -p ~/0del && mv "$@" ~/0del/;  # ~/0del is trash bin. escaping with \rm doenst work on functions, so use /usr/bin/rm or which rm) }.
+function rm { type "${FUNCNAME[0]}"; mkdir -p ~/0del && mv "$@" ~/0del/; } # ~/0del is trash bin. use \rm for the original command (which is not working atm, so use /usr/bin/rm).
 function rl { readlink -f "$1"; } # function returns full path of file, very useful
 # `sed` # Stream EDitor `sed -i 's/aaa/bbb/g' file` -i inplace, replace aaa with bbb. g globally. can use any char instead of /, such as `sed -i 's,aaa,bbb,' file`. -E to use re pattern matching.
 alias sudo='sudo '; alias s='sudo '; alias sd='sudo -s ' # elevate privelege for command. see `visudo` to set. And `usermod -aG sudo add`, security caution when adding.
@@ -327,13 +309,13 @@ if [[ $(whoami) == 'root' ]]; then export TMOUT=18000 && readonly TMOUT; fi # ti
 ## extra stuff
 # `!!` for last command, as in `sudo !!`. `ctrl+alt+e` expand works here. `!-1:-1` for second to last arg in last command.
 # `vi $(!!)` to use output of last command. or use backticks: vi `!!`
-# `declare -f <function>` will show it
+# `declare -f <function>` will show it. use `type <name>` will show both alias and functions
 set -a # sets for export to env the following functions, for calling in scripts and subshells (aliases dont get called).
 function hdn { history -d "$1"; history -w;} # delete history line number
 # function hdl { history -d $(($HISTCMD - 1)); history -w;} # delete history last number
 function hdl { history -d $HISTCMD; history -w;} # delete history last number
 function hdln { history -d $(($HISTCMD - "$1" -1))-$(($HISTCMD - 2)); history -w;} # delete last n lines. (add 1 for this command) (history -d -$1--1; has error)
-function help { "$1" --help;} # use `\help` to disable the function alias
+function help { type "${FUNCNAME[0]}"; "$1" --help;} # use `\help` to disable the function alias
 function q { "$1" --help || help "$1" || man "$1" || info "$1";} # use any help doc. # also tldr. 
 command_not_found_handle2() { [ $# -eq 0 ] && command -v "$1" > /dev/null 2>&1 && "$1" --help || command "$@"; } # adds --help to all commands that need a parameter. or use below to exclude certain ones.
 #command_not_found_handle() { local excluded_commands=("ls" "cd" "pwd"); if [ $# -eq 0 ] && command -v "$1" > /dev/null 2>&1; then [[ ! " ${excluded_commands[@]} " =~ " $1 " ]] && "$1" --help || command "$1"; else command "$@"; fi }
@@ -386,17 +368,14 @@ if [[ $- == *i* ]]; then bind '",.": "$"'; fi # quick $
 
 
 true <<'END' 
-CLI emacs mode common keys (Control, Meta(Esc-then-key)=alt/option, Super=win/command, fn):
-alt-. for last word from history lines. ctrl-alt-t to transpose 2 words. 
+CLI emacs mode common keys:
 press `ctrl+alt+e` to expand symbols to show them, such as `!!`
 clear line: `ctrl+e`,`ctrl+u` goto end then clear to left, (or ctrl+a, ctrl+k)
 cut word backward `ctrl w`, paste that word `ctrl y`, use `alt d` to cut word forward
-undo like this : `ctrl+_` (or `ctrl-/` or `ctrl-z` from bindings here)
-kill runaway process: `ctrl+c`, `ctrl+\`, `ctrl+d` (exit current shell), ctrl+z is remapped to undo.
-search history, reverse (type afterward): `ctrl+r`, go forward `ctrl+f`. `ctrl+g` cancels. `alt+>` go back to history bottom.
-C-x,C-e exec line. C-o to process an reenter line. 
-https://dokumen.tips/documents/macintosh-terminal-pocket-guide.html?page=42 (vi/emacs keys table, broken link to Orielly's book)
-https://dokumen.pub/qdownload/macintosh-terminal-pocket-guide-take-command-of-your-mac-1nbsped-1449328342-9781449328344.html  pg 36
+undo like this : `ctrl+_`
+kill runaway process: `ctrl+c`, `ctrl+d` (exit current shell), `ctrl+\` 
+search history, reverse (type afterward): `ctrl+r`, go forward `ctrl+f`. `ctrl+g` cancels. `alt(meta)+>` go back to history bottom.
+https://dokumen.tips/documents/macintosh-terminal-pocket-guide.html?page=42 (vi/emacs keys table)
 
 basic bash system commands:
 `fdisk -l` # partition table list. also see `cfdisk` for changing
@@ -778,7 +757,7 @@ alias remux='tmux source ~/.tmux.conf' # reload tmux
 # https://tmuxcheatsheet.com/
 # Scrolling: Ctrl-b then [ then you can use your normal navigation keys to scroll around (eg. Up Arrow or PgDn). Press q to quit scroll mode.
 
-## basic git settings. GIT DOESNT compare by timestamp, only by commit order.
+## basic GIT settings. git DOESNT compare by timestamp, only by commit order.
 alias gits='git status'
 alias gitl='git log'
 alias gitb='git branch'
@@ -787,12 +766,25 @@ alias gitc='git commit -m "ok"'
 alias gitpu='git push origin main' # usually same as `git push`. see below for conflicts
 alias gitpl='git pull' # (git fetch && git merge) 
 alias gitac='gita && gitc' # add and commit
-alias gs='git status && git add -A && git commit -m \"ok\" && git push # git sync by push' 
-alias gitsd='pushd ~/git/dotfiles && git add . && git commit -m commit && git push -u origin main; popd' # git sync push on dotfiles dir
-alias gpho='git push -u origin main '
-alias agitinfo='# git clone is for first copy # git status, git log, git branch \# git clone https://github.com/auwsom/dotfiles.git #add ssh priv & pub key or will pull but not push
 
-setup a repo from local:
+alias gs='git status && git add -A && git commit -m \"ok\" && git push # local ahead: git status,add,commit,push' # push recent changes
+alias gss='git fetch origin >/dev/null && commits=$(git rev-list --left-right --count HEAD...origin/$(git rev-parse --abbrev-ref HEAD)) && [[ $commits == "0	0" ]] && echo "synced" || ([[ ${commits%%	*} -gt 0 ]] && echo "local ahead" || echo "origin ahead") # git sync' # check if in sync
+alias gsss='git fetch origin && git merge-tree $(git merge-base HEAD origin/$(git rev-parse --abbrev-ref HEAD)) HEAD origin/$(git rev-parse --abbrev-ref HEAD) | grep -q "^<<<<<<<" && echo "Conflict!" || echo "No Conflicts"' # checks for file conflicts before merge
+alias gssss='git commit -m "rebase" && git pull --rebase # local ahead.. merge after gsss checks theres no conflicts locally'
+alias gsssss='git push --force-with-lease origin main # origin ahead.. merge after gsss checks theres no conflicts in origin. lease checks if files are checked out' 
+
+# gs: Commits and pushes your current local changes to the remote.
+# gss: Checks if your local branch is in sync, ahead, or behind the remote.
+# gsss: Predicts if merging remote changes would cause conflicts.
+# gssss: Commits your local changes then pulls remote changes by replaying your commits on top.
+# gsssss: Forces your local branch to overwrite the remote branch, with a safety check.
+
+
+alias gsync='git commit -m "rebase" && git pull --rebase && git push' # full sync but adds markup of changes inside files. will add local changes onto origin. doesnt merge (does rewrite history linearly). 'git pull --rebase' will add markers in file of conflict. have to remove manually, then `git add $file` and `git rebase --continue` and `git push origin main --force-with-lease` or `git rebase --abort` to cancel. 
+alias gfullsync='git add -A && git commit -m "sync" && git fetch origin && git rebase origin/$(git rev-parse --abbrev-ref HEAD) && git push --force-with-lease'
+
+#setup a repo from local:
+alias agitinfo='# git clone is for first copy # git status, git log, git branch \# git clone https://github.com/auwsom/dotfiles.git #add ssh priv & pub key or will pull but not push
 # git clone git@github.com:auwsom/dotfiles.git # will ask to connect. need to `eval $(ssh-agent -s) && ssh-add ~/.ssh/id_rsa` checks if agent running and adds (will display email of GH account) 
 # `apt install gh` then click enter until auth through webpage'
 #alias git1='gh repo create <newrepo> --private' # or --public
@@ -813,6 +805,7 @@ alias gitlo='git log --oneline' # shows compact commit history
 alias gitchkf='git checkout <commit> -- <file>' # restores a file from that commit. 
 alias gitsr1='keyword="replacethis"; for commit in $(git log -S "$keyword" --oneline --pretty=format:"%H"); do git grep "$keyword" "$commit"; done'
 alias gitsr2='git log --name-status --diff-filter=A --'
+alias gitsd='pushd ~/git/dotfiles && git add . && git commit -m commit && git push -u origin main; popd' # git sync push on dotfiles dir
 
 #git resolve conflicts:
 alias gitf='git fetch # have to fetch before compare to origin (wont overwrite local)'
@@ -824,13 +817,12 @@ alias gitd5='git diff origin/main -- $file # to compare a single file'
 alias gitv1='git log HEAD..origin/main -p      # view Remote changes' # can use --oneline for commit number and desc
 alias gitv2='git log origin/main..HEAD -p      # view Your changes'
 
-alias gitrc1='git commit -m "rebase" && git pull --rebase && git push' # will add local changes onto origin. doesnt merge (does rewrite history linearly). 'git pull --rebase' will add markers in file of conflict. have to remove manually, then `git add $file` and `git rebase --continue` and `git push origin main --force-with-lease` or `git rebase --abort` to cancel
 alias gitkr='git checkout --theirs $file && git add $file && git rebase --continue # keep remote'
 alias gitkl='git checkout --ours $file && git add $file && git rebase --continue # keep local'
 # if sure origin (github) is correct:
 alias gitpfr='git format-patch -1 HEAD && git fetch origin && git reset --hard origin/main # save local as patch, fetch, reset'
 # if sure local is correct:
-alias gitpuf='git push --force origin main' # use only after diffing remote to local. also if warning from remote being ahead, you can pull and merge.
+alias gitpuf='git push --force-with-lease origin main' # use only after diffing remote to local. also if warning from remote being ahead, you can pull and merge.
 
 
 # mv ~/.bash_aliases ~/.bash_aliases0 && ln -s ~/git/dotfiles/.bash_aliases ~/.bash_aliases
@@ -971,6 +963,9 @@ export PYTHONTRACEBACKLIMIT=1  # limits python traceback lines to 1
 alias sv='source /home/user/venv1/bin/activate'
 alias sv2='source /home/aimgr/venv2/bin/activate'
 
+alias rts="sed -i 's/[[:space:]]*$//'" # <file> remove trailing spaces on every line. for copying from terminal that adds spaces.
+
+
 if ! [[ $- == *i* ]]; then true "ENDI"; fi
 true <<'ENDZ' # move this line to anywhere above and whatever is below it will be skipped.
 ENDZ
