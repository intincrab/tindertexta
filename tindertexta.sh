#!/bin/bash

# tindertexta - A Tinder-like sorting tool for text files using a swipe interface

# Constants
CONFIG_DIR="$HOME/.config/tindertexta"
CONFIG_FILE="$CONFIG_DIR/tindertexta.cfg"
UI_CONFIG_FILE="$CONFIG_DIR/tindertexta-ui.cfg"

# Functions
function write_error_and_exit {
    echo "Error: $1" >&2
    exit 1
}

function set_ui_config {
    echo "$1" > "$UI_CONFIG_FILE"
}

function get_ui_config {
    if [[ -f "$UI_CONFIG_FILE" ]]; then
        cat "$UI_CONFIG_FILE"
    else
        echo "1"  # Default to verbose
    fi
}

function read_last_index_config {
    if [[ -f "$CONFIG_FILE" ]]; then
        grep "^$1=" "$CONFIG_FILE" | cut -d'=' -f2
    else
        echo "0"
    fi
}

function write_last_index_config {
    mkdir -p "$CONFIG_DIR"
    sed -i "/^$1=/d" "$CONFIG_FILE"
    echo "$1=$2" >> "$CONFIG_FILE"
}

function reset_progress {
    sed -i "/^$1=/d" "$CONFIG_FILE"
    left_file="${1%.*}-left.${1##*.}"
    right_file="${1%.*}-right.${1##*.}"
    rm -f "$left_file" "$right_file"
    echo "Progress reset for $1. Previous output files deleted."
}

function append_to_file {
    echo "$2" >> "$1" || write_error_and_exit "Unable to write to file $1. Please check permissions and try again."
}

# Main script
input_file="$1"
ui_mode=$(get_ui_config)

# Check if input file is provided and exists
[[ -z "$input_file" ]] && write_error_and_exit "Usage: $0 <input_file> [-ui on|off] [-reset]"

if [[ "$2" == "-ui" && "$3" == "on" ]]; then
    set_ui_config "1"
    exit 0
elif [[ "$2" == "-ui" && "$3" == "off" ]]; then
    set_ui_config "0"
    exit 0
elif [[ "$2" == "-reset" ]]; then
    reset_progress "$input_file"
    exit 0
fi

[[ ! -f "$input_file" ]] && write_error_and_exit "Input file not found."

# Variables
left_file="${input_file%.*}-left.${input_file##*.}"
right_file="${input_file%.*}-right.${input_file##*.}"
current_index=$(read_last_index_config "$input_file")

# Read file lines
mapfile -t lines < "$input_file"

# Main loop
while (( current_index < ${#lines[@]} )); do
    clear
    current_line="${lines[$current_index]}"
    echo "$current_line"
    
    [[ "$ui_mode" == "1" ]] && echo "Swipe Left <- | Swipe Right -> | Undo ^ | Quit Q"

    read -s -n 1 key
    case "$key" in
        $'\x1b')  # Arrow keys and escape sequences
            read -s -n 2 rest
            case "$rest" in
                '[D')  # Left arrow
                    append_to_file "$left_file" "$current_line"
                    (( current_index++ ))
                    ;;
                '[C')  # Right arrow
                    append_to_file "$right_file" "$current_line"
                    (( current_index++ ))
                    ;;
                '[A')  # Up arrow (Undo)
                    if (( current_index > 0 )); then
                        (( current_index-- ))
                        last_choice=$(tail -n 1 "$right_file" 2>/dev/null)
                        if [[ "$last_choice" == "$current_line" ]]; then
                            sed -i '$ d' "$right_file"
                        else
                            sed -i '$ d' "$left_file"
                        fi
                    fi
                    ;;
            esac
            ;;
        q|Q)  # Quit
            write_last_index_config "$input_file" "$current_index"
            [[ "$ui_mode" == "1" ]] && echo "Progress saved. Exiting..."
            exit 0
            ;;
        *)  # Invalid key
            [[ "$ui_mode" == "1" ]] && echo "Invalid key. Please use arrow keys or 'Q' to quit." >&2
            ;;
    esac

    write_last_index_config "$input_file" "$current_index"
done

[[ "$ui_mode" == "1" ]] && echo "All lines processed. Files for left and right swipes are up to date."
