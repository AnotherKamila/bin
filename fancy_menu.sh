#!/bin/bash


usage() {
cat <<- 'EOF'
Usage: $0 [-t] commands-file

makes a fancy dmenu from a file formatted:
  option name 1    : command1
  another option   : command2
  ...

Options: -h|--help  show this help
         -t         run commands in terminal (with fancy headers)
EOF
exit $1
}

[[ $# == 0 || $# > 2 ]] && usage 1

if [[ $# == 1 ]]; then
    [[ $1 == '-h' || $1 == '--help' ]] && usage 0
    MENUFILE="$1"
elif [[ $1 == '-t' ]]; then
    IN_TERM=1
    MENUFILE="$2"
else
    usage 1
fi
[[ ! -f "$MENUFILE" ]] && usage 1

R=`grep -v "^#" "$MENUFILE" | sed 's/ *: *.*$//g' | dmenu -i -fn '-*-terminus-medium-*-*-*-*-160-72-72-*-*-iso10646-*' -nb \#268bd2 -nf \#073642 -sb \#073642 -sf \#fff`
[[ $? != 0 ]] && exit 1

CMD=`grep -v "^#" "$MENUFILE" | grep "$R" | sed 's/.*:[[:space:]]//g'`

if [[ $IN_TERM == 1 ]];then
    $TERMINAL -e /bin/bash -c "echo -e \"\033[0;35m$CMD\033[0;0m\"; $CMD; echo -e \"\033[0;35mPress any key to exit...\033[0;0m\"; read -n1 -s"
else
    $CMD
fi

exit 0
