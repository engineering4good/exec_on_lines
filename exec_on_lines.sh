#!/bin/bash

# exec_on_lines.sh

exec_on_lines() {
    # Help message
    local help_message="Usage: exec_on_lines <command> [args...] <file_path>
    
This function executes a command with each line of the specified file as an argument.
    
Parameters:
  <command>       The command to execute
  [args...]      Additional arguments to pass to the command
  <file_path>     The path to the file containing lines to process

Options:
  -h, --help      Show this help message and exit
"

    # Check for help option
    if [[ "$1" == "--help" || "$1" == "-h" || $# -eq 0 ]]; then
        echo "$help_message"
        return 0
    fi
    
    local command="$1"
    shift  # Remove the first argument (command) from the list
    local filepath="${@: -1}"

    # Check if the file exists
    if [[ ! -f "$filepath" ]]; then
        echo "Error: File not found at '$filepath'"
        return 1
    fi

    # Read the file line by line
    while IFS= read -r line; do
        # Execute the command with the current line as argument, along with any additional parameters/flags
        "$command" "${@:1:$#-1}" "$line"
    done < "$filepath"
}

# Autocomplete function
_exec_on_lines_completion() {
    local current_arg="${COMP_WORDS[COMP_CWORD]}"

    # If the current argument is the command (first argument)
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -c -- "$current_arg") )  # List all commands
        return
    fi

    local COMP_WORDS_length=${#COMP_WORDS[@]}
    # If we're on the last argument, suggest file paths
    if [[ $COMP_CWORD -eq $((COMP_WORDS_length - 1)) ]]; then
        COMPREPLY=( $(compgen -f "$current_arg") )  # List files
        return
    fi

    # Otherwise, list words such as options for command or additional args
    COMPREPLY=()
}

# Register the autocompletion function
complete -F _exec_on_lines_completion exec_on_lines
