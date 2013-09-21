# Function to start and stop the Synergy KVM server
function synergystart()
{
    #if [ "$1" == "" ] || [ "$1" == "start" ] || [ "$1" == "restart" ];
#then
        #synergy stop;

        echo -n 'Starting local synergy server‚Ä¶ ';
        synergys --config ~/.config/synergy/synergy.conf;
        echo 'done.';

        echo -n 'Starting remote synergy clients‚Ä¶ ';
        ssh smspillaz@192.168.0.151 'synergyc 192.168.0.150 ';
	ssh sam@192.168.0.100 'synergyc 192.168.0.150 ';
        # ‚Ä¶ insert extra client entries here
        echo 'done.';
    #else
        #if [ "$1" == "stop" ]; then
        #fi
    #fi
}

function synergystop ()
{
    #if [ "$1" == "" ] || [ "$1" == "start" ] || [ "$1" == "restart" ];
#then
        #synergy stop;
    #else
        #if [ "$1" == "stop" ]; then
            echo -n 'Stopping local synergy server‚Ä¶ ';
            killall -TERM synergys;
            echo 'done.';

            echo -n 'Stopping remote synergy clients‚Ä¶ ';
            ssh smspillaz@192.168.0.151 'killall -TERM synergyc';
	    ssh sam@192.168.0.100 'killall -TERM synergyc'
            # ‚Ä¶ insert extra client entries here
            echo 'done.';
        #else
            echo 'usage: synergy [[start]|stop]';
        #fi
    #fi
}

function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    ###
    # Truncate the path if it's too long.

    PR_FILLBAR=""
    PR_PWDLEN=""

    local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    local pwdsize=${#${(%):-%~}}

    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
	    ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
	PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi

    ###
    # Get APM info.

    PR_APM_RESULT=''

# let's get the current get branch that we are under
    # ripped from /etc/bash_completion.d/git from the git devs
    git_ps1 () {
        if which git > /dev/null; then
            local g="$(git rev-parse --git-dir 2>/dev/null)"
            if [ -n "$g" ]; then
                # in a git directory
                local r
                local b
                if [ -d "$g/rebase-apply" ]; then
                    if test -f "$g/rebase-apply/rebasing"; then
                        r="|REBASE"
                    elif test -f "$g/rebase-apply/applying"; then
                        r="|AM"
                    else
                        r="|AM/REBASE"
                    fi
                    b="$(git symbolic-ref HEAD 2>/dev/null)"
                elif [ -f "$g/rebase-merge/interactive" ]; then
                    r="|REBASE-i"
                    b="$(cat "$g/rebase-merge/head-name")"
                elif [ -d "$g/rebase-merge" ]; then
                    r="|REBASE-m"
                    b="$(cat "$g/rebase-merge/head-name")"
                elif [ -f "$g/MERGE_HEAD" ]; then
                    r="|MERGING"
                    b="$(git symbolic-ref HEAD 2>/dev/null)"
                else
                    if [ -f "$g/BISECT_LOG" ]; then
                        r="|BISECTING"
                    fi
                    if ! b="$(git symbolic-ref HEAD 2>/dev/null)"; then
                       if ! b="$(git describe --exact-match HEAD 2>/dev/null)"; then
                          b="$(cut -c1-7 "$g/HEAD")..."
                       fi
                    fi
                fi
                if [ -n "$1" ]; then
                     printf "$1" "${b##refs/heads/}$r"
                else
                     printf "%s" "${b##refs/heads/}$r"
                fi

                # print a * if git diff sees changes
                local uncommitted
                local queued
                UC=""
                uncommitted="$(git diff --exit-code > /dev/null 2>&1; echo $?)"
                if [ $uncommitted -eq 1 ]; then
                   UC="*"
                fi
                queued="$(git status > /dev/null 2>&1; echo $?)"
                if [ $queued -eq 0 ]; then
                   UC="$UC+"
                fi
                printf "$UC"
            fi
        else
            printf ""
        fi
    }

    GITBRANCH="$(git_ps1)"
    if [ -n "$GITBRANCH" ]; then
        GITBRANCH=" ($GITBRANCH)"
    fi

    GITBRANCH=$GITBRANCH

}

setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
	local CMD=${1[(wr)^(*=*|sudo|-*)]}
	echo -n "\ek$CMD\e\\"
    fi
}

setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst

    ###
    # See if we can use colors.

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
	colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    ###
    # See if we can use extended characters to look nicer.

    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    ###
    # Decide if we need to set titlebar text.

    case $TERM in
	xterm*)
	    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
	    ;;
	screen)
	    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
	    ;;
	*)
	    PR_TITLEBAR=''
	    ;;
    esac

    ###
    # Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
	PR_STITLE=$'%{\ekzsh\e\\%}'
    else
	PR_STITLE=''
    fi

    ###
    # APM detection

    PR_APM=''

    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.%SROOT%s.%n)$PR_GREEN@%m:%l\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_MAGENTA%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_LIGHT_RED%?$PR_BLUE:)\
${(e)PR_APM}$PR_YELLOW%D{%H:%M}\
$PR_LIGHT_BLUE:$GITBRANCH%%(!.$PR_RED.$PR_WHITE)%#$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR '

    RPROMPT=' $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT\
($PR_YELLOW%D{%a,%b%d}$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000
# History handling
setopt appendhistory  #append to history
setopt inc_append_history # append immediately
setopt hist_expire_dups_first # expire duplicates in history first
setopt hist_ignore_dups # don't add dupes to history

# interactive configuration
setopt nomatch # print error if no match is found
setopt correct # correct spelling mistakes in commands
setopt autocd # change to directory without "cd"
setopt auto_list # auto-list all completion choices when hitting TAB
# automenu is needed for menu-based selection
setopt auto_menu # don't auto-list first match
unsetopt extendedglob

# misc
unsetopt beep # don't beep
unsetopt notify # don't report background jobs immediately
unsetopt hup # don't set HUP to jobs when exiting

setprompt

# Source global definitions

# User specific aliases and functions

## A script to setup some needed variables and functions for KDE 4 development.
## This should normally go in the ~/.bashrc file of your kde-devel user, so
## that it is executed when a session for that user is started.
##
## If you don't use a separate user, the first section with the
## environment variables should go into a separate script.

prepend() { [ -d "$2" ] && eval $1=\"$2\$\{$1:+':'\$$1\}\" && export $1 ; }

# Other
# you might want to set a full value for PATH rather than prepend'ing, to make
# sure the your kde3 path isn't in here.
prepend PATH /usr/local/bin

# Qt
# only set Qt related variables if you compiled Qt on your own
# (which is discouraged). if you use the distro provided Qt, skip
# this section. Comment it if necessary.
export QTDIR=$HOME/Applications/qt-copy
prepend PATH $QTDIR/bin
prepend LD_LIBRARY_PATH $QTDIR/lib
prepend PKG_CONFIG_PATH $QTDIR/lib/pkgconfig

# KDE
export KDEDIR=$HOME/Applications/kde
export KDEHOME=$HOME/.kde4
export KDETMP=/tmp/kde4-$USER
mkdir -p $KDETMP
export KDEDIRS=$KDEDIR
prepend PATH $KDEDIR/bin
prepend LD_LIBRARY_PATH $KDEDIR/lib
prepend PKG_CONFIG_PATH $KDEDIR/lib/pkgconfig
prepend QT_PLUGIN_PATH $KDEDIR/lib/kde4/plugins

export PATH
export LD_LIBRARY_PATH
export PKG_CONFIG_PATH
export QT_PLUGIN_PATH

# CMake
# Make sure CMake searches the right places.
prepend CMAKE_PREFIX_PATH  $KDEDIR
prepend CMAKE_LIBRARY_PATH $KDEDIR/lib
prepend CMAKE_INCLUDE_PATH $KDEDIR/include

export CMAKE_PREFIX_PATH
export CMAKE_LIBRARY_PATH
export CMAKE_INCLUDE_PATH

# Compiz
# Compiz related paths
export COMPIZDIR=$HOME/Applications/compiz
prepend PKG_CONFIG_PATH  $COMPIZDIR/lib/pkgconfig
prepend LD_LIBRARY_PATH $COMPIZDIR/lib
prepend PYTHONPATH $COMPIZDIR/lib/python2.6/site-packages
prepend PATH $COMPIZDIR/bin

export PATH
export PKG_CONFIG_PATH
export LD_LIBRARY_PATH
export PYTHONPATH

# GNOME
# GNOME related paths

# GNOME Shell
#prepend PATH ~/gnome-shell/bin
#prepend PKG_CONFIG_PATH ~/gnome-shell/lib/pkgconfig

#export PATH
#export PKG_CONFIG_PATH

# XBMC
# XBMC related paths
prepend PATH $HOME/Applications/xbmc/bin
export PATH

# Cairo-dock
prepend PATH $HOME/Applications/cairo-dock/bin
prepend PKG_CONFIG_PATH $HOME/Applications/cairo-dock/lib/pkgconfig
export PKG_CONFIG_PATH
export PATH

# Used for compiling X.org and dependent apps
prepend PKG_CONFIG_PATH /opt/xorg/lib/pkgconfig
prepend LD_LIBRARY_PATH /opt/xorg/lib
prepend LD_RUN_PATH /opt/xorg/lib
export ACLOCAL="aclocal -I /opt/xorg/share/aclocal"
export PKG_CONFIG_PATH
export LD_LIBRARY_PATH
export LD_RUN_PATH

# Because git is stupid
prepend PATH `git --exec-path`
export path

# DBus
# only set DBUS related variables if you compiled dbus on your own
# (which is really discouraged). if you use the distro provided dbus,
# skip this variable. Uncomment it if necessary.
#export DBUSDIR=$KDEDIR
#prepend PKG_CONFIG_PATH $DBUSDIR/lib/pkgconfig

# only needed on some strange systems for compiling Qt. do not set
# it unless you have to.
#export YACC='byacc -d'

# XDG
unset XDG_DATA_DIRS # to avoid seeing kde3 files from /usr
unset XDG_CONFIG_DIRS

# you might want to change these:
export KDE_BUILD=$HOME/Source/kde/build
export KDE_SRC=$HOME/Sourcekde/src

# make the debug output prettier
export KDE_COLOR_DEBUG=1
export QTEST_COLORED=1

# Make
# Tell many scripts how to switch from source dir to build dir:
export OBJ_REPLACEMENT="s#$KDE_SRC#$KDE_BUILD#"
# Use makeobj instead of make, to automatically switch to the build dir.
# If you don't have makeobj, install the package named kdesdk-scripts or
# kdesdk, or check out kdesdk/scripts from svn.
alias make=makeobj

# Uncomment the following lines if DBus does not work. DBus is not
# working if, when you run `dbus-uuidgen --ensure && qdbus`, you get an error.
#
# alias dbusstart="eval `PATH=$DBUSDIR/bin \
#  $DBUSDIR/bin/dbus-launch --auto-syntax`"

# A function to easily build the current directory of KDE.
#
# This builds only the sources in the current ~/{src,build}/KDE subdirectory.
# Usage: cs KDE/kdebase && cmakekde
#   will build/rebuild the sources in ~/src/KDE/kdebase
function cmakekde {
        local srcFolder current

        if test -n "$1"; then
                # srcFolder is defined via command line argument
                srcFolder="$1"
        else
                # get srcFolder for current dir
                srcFolder=`pwd | sed -e s,$KDE_BUILD,$KDE_SRC,`
        fi
        # we are in the src folder, change to build directory
        # Alternatively, we could just use makeobj in the commands below...
        current=`pwd`
        if [ "$srcFolder" = "$current" ]; then
                cb
        fi
        # To enable tests, uncomment -DKDE4_BUILD_TESTS=TRUE.
        # If you are building to debug or develop, it is reccommended to
        # uncomment the line -DCMAKE_BUILD_TYPE=debugfull. Be sure to move
        # it above the -DKDE4_BUILD_TESTS=TRUE line if you leave that one
        # commented out. You can also change "debugfull" to "debug" to save
        # disk space.
        # Some distributions use a suffix for their library directory when
        # on x86_64 (i.e. /usr/lib64) if so, you have to add -DLIB_SUFFIX=64
        # for example.
        cmake "$srcFolder" -DCMAKE_INSTALL_PREFIX=$KDEDIR \
               # -DKDE4_BUILD_TESTS=TRUE \
               # -DCMAKE_BUILD_TYPE=debugfull

        # uncomment the following two lines to make builds wait after
        # configuration step, so that the user can check configure output
        #echo "Press  to continue..."
        #read userinput

        # Note: To speed up compiling, change 'make -j2' to 'make -jx',
        #   where x is your number of processors +1
        nice make -j2 && make install
        RETURN=$?
        cs
        return ${RETURN}
}

# for the lazy ones (aren't we all?)
function cmakekdeall {
        local folders

        folders="kdesupport KDE/kdelibs KDE/kdebase \
                KDE/kdepimlibs KDE/kdepim KDE/kdesdk \
                KDE/kdegraphics KDE/kdevplatform KDE/kdevelop \
                "
                # Add others or remove to taste, e.g.
                # KDE/kdemultimedia KDE/kdenetwork KDE/kdeutils \

        cd && cs # go to src root
        svn up $folders

        for f in $folders; do
            # Remove the "|| return" part if you don't want to
            # stop the build whenever a single module fails.
            cs $f && cmakekde || return
        done
}

# A function to easily change to the build directory.
# Usage: cb KDE/kdebase
#   will change to $KDE_BUILD/KDE/kdebase
# Usage: cb
#   will simply go to the build folder if you are currently in a src folder
#   Example:
#     $ pwd
#     /home/user/src/KDE/kdebase
#     $ cb && pwd
#     /home/user/build/KDE/kdebase
function cb {
        local dest

        # Make sure build directory exists.
        mkdir -p "$KDE_BUILD"

        # command line argument
        if test -n "$1"; then
                cd "$KDE_BUILD/$1"
                return
        fi
        # substitute src dir with build dir
        dest=`pwd | sed -e s,$KDE_SRC,$KDE_BUILD,`
        if test ! -d "$dest"; then
                # build directory does not exist, create
                mkdir -p "$dest"
        fi
        cd "$dest"
}

# Change to the source directory.  Same as cb, except this
# switches to $KDE_SRC instead of $KDE_BUILD.
# Usage: cs KDE/kdebase
#   will change to $KDE_SRC/KDE/kdebase
# Usage: cs
#   will simply go to the source folder if you are currently in a build folder
#   Example:
#     $ pwd
#     /home/user/build/KDE/kdebase
#     $ cs && pwd
#     /home/user/src/KDE/kdebase
function cs {
        local dest current

        # Make sure source directory exists.
        mkdir -p "$KDE_SRC"

        # command line argument
        if test -n "$1"; then
                cd "$KDE_SRC/$1"
        else
                # substitute build dir with src dir
                dest=`pwd | sed -e s,$KDE_BUILD,$KDE_SRC,`
                current=`pwd`
                if [ "$dest" = "$current" ]; then
                        cd "$KDE_SRC"
                else
                        cd "$dest"
                fi
        fi
}

# Add autocompletion to cs function
function _cs_scandir
{
        local base ext

        base=$1
        ext=$2
        if [ -d $base ]; then
                for d in `ls $base`; do
                        if [ -d $base/$d ]; then
                                dirs="$dirs $ext$d/"
                        fi
                done
        fi
}

function _cs()
{
        local cur dirs
        _cs_scandir "$KDE_SRC"
        _cs_scandir "$KDE_SRC/KDE" "KDE/"
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        COMPREPLY=( $(compgen -W "${dirs}" -- ${cur}) )
}

# Remove comment on next line to enable cs autocompletion
#complete -F _cs cs

function start3app {
        mkdir -p /tmp/$USER-kde
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games
        export LD_LIBRARY_PATH=
        export KDETMP=/tmp/$USER-kde
        export KDEVARTMP=/var/tmp/$USER-kde
        export KDEHOME=$HOME/.kde
        export KDEDIR=/usr
        export KDEDIRS=$KDEDIR
        export DISPLAY=:0
        eval "$@"
        source $HOME/.bashrc   #Reset environment variables again
}
