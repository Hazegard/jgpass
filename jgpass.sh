#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
function show_pass() {
    res=$(pass show "$1" &&)
    echo "$res"
    if [[ $! -eq 2 ]]; then
        notify-send "JGPass" "$res"
    else
        notify-send "JGPass" "$res"
    fi
}

function copy_pass() {
    res=$(pass show -c "$1" 2>&1 | tail -n 1)
    if [[ "$res" == "Error:"* ]]; then
        echo "$res"
        notify-send "$res"
    else
        echo "$res"
        notify-send "$res"
    fi
}

function gen_menu() {
    local current_path="$1"
    local current_gen;
    current_gen="$(basename "$1"),^tag($1)"
    local pwd="$HOME/.password-store/"
    for item in "$current_path"*; do
        if [[ -d "$item" ]]; then
            current_gen="$current_gen\n$(basename "$item"),^checkout($item/),$DIR/folder.svg"
        elif [[ -f "$item" ]]; then
            pass=${item#$pwd}
            pass=${pass%.*}
            password_name=$(basename "${item%.*}")
            current_gen="$current_gen\n$(basename "${item%.*}"), $DIR/jgpass.sh copy ${pass%.*},$DIR/folder-locked.svg"
        fi
    done

    for item in "$current_path"*; do
        if [[ -d "$item" ]]; then
            current_gen="$current_gen\n$(gen_menu "$item/")"
        fi
    done
    printf "$current_gen\n"
}

function gen_item_pipe(){
    local item;
    item="echo \"show,pass show $1,\" | jgmenu --simple --config-file="$DIR/jgpassrc"\",$DIR/folder-unlocked.svg"
    echo -n "$item"
}


folder="$HOME/.password-store/"

if [[ "$1" == "menu" ]]; then
    gen_menu "$folder" | jgmenu --simple --config-file="$DIR/jgpassrc"
elif [[ "$1" == "copy" ]]; then
    copy_pass "$2"
elif [[ "$1" == "display" ]]; then
    gen_menu "$folder"
fi
