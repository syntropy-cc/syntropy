#!/bin/bash

#===============================================================================
# SSH CONNECTION MANAGEMENT
#===============================================================================

test_ssh_connection() {
    local host="$1"
    local user="$2"
    local key_file="${3:-}"
    local timeout="${4:-10}"
    
    local ssh_cmd="ssh"
    [[ -n "$key_file" ]] && ssh_cmd+=" -i '$key_file'"
    ssh_cmd+=" -o ConnectTimeout=$timeout"
    ssh_cmd+=" -o BatchMode=yes"
    ssh_cmd+=" -o StrictHostKeyChecking=no"
    ssh_cmd+=" '$user@$host' 'echo SSH_SUCCESS'"
    
    local result=$(timeout "$timeout" bash -c "$ssh_cmd" 2>/dev/null)
    [[ "$result" == "SSH_SUCCESS" ]]
}

execute_remote_command() {
    local host="$1"
    local user="$2"
    local command="$3"
    local key_file="${4:-}"
    local timeout="${5:-30}"
    
    local ssh_cmd="ssh"
    [[ -n "$key_file" ]] && ssh_cmd+=" -i '$key_file'"
    ssh_cmd+=" -o ConnectTimeout=$timeout"
    ssh_cmd+=" -o BatchMode=yes"
    ssh_cmd+=" -o StrictHostKeyChecking=no"
    ssh_cmd+=" '$user@$host' '$command'"
    
    timeout "$timeout" bash -c "$ssh_cmd"
}

execute_remote_script() {
    local host="$1"
    local user="$2"
    local script_path="$3"
    local key_file="${4:-}"
    local timeout="${5:-30}"
    local args="${6:-}"
    
    if [[ ! -f "$script_path" ]]; then
        echo "Script not found: $script_path" >&2
        return 1
    fi
    
    local remote_script="/tmp/$(basename "$script_path").$$"
    
    # Copy script to remote host
    scp ${key_file:+-i "$key_file"} \
        -o ConnectTimeout="$timeout" \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        "$script_path" "$user@$host:$remote_script"
    
    # Make script executable and run it
    execute_remote_command "$host" "$user" "chmod +x '$remote_script' && '$remote_script' $args" "$key_file" "$timeout"
    
    # Cleanup
    execute_remote_command "$host" "$user" "rm -f '$remote_script'" "$key_file" 5
}

create_ssh_tunnel() {
    local local_port="$1"
    local remote_host="$2"
    local remote_port="$3"
    local user="$4"
    local key_file="${5:-}"
    
    local ssh_cmd="ssh -f -N"
    [[ -n "$key_file" ]] && ssh_cmd+=" -i '$key_file'"
    ssh_cmd+=" -o ExitOnForwardFailure=yes"
    ssh_cmd+=" -L $local_port:localhost:$remote_port"
    ssh_cmd+=" $user@$remote_host"
    
    $ssh_cmd
    return $?
}

check_tunnel_status() {
    local local_port="$1"
    netstat -an | grep "LISTEN" | grep ":$local_port " >/dev/null
}

close_ssh_tunnel() {
    local local_port="$1"
    pkill -f "ssh.*:$local_port"
}

#===============================================================================
# SSH KEY MANAGEMENT
#===============================================================================

generate_ssh_key() {
    local key_file="$1"
    local key_type="${2:-ed25519}"
    local comment="${3:-diagnostic-system}"
    
    ssh-keygen -t "$key_type" -f "$key_file" -N "" -C "$comment"
}

copy_ssh_key() {
    local host="$1"
    local user="$2"
    local key_file="$3"
    local password="${4:-}"
    
    if [[ -n "$password" ]]; then
        sshpass -p "$password" ssh-copy-id -i "$key_file" "$user@$host"
    else
        ssh-copy-id -i "$key_file" "$user@$host"
    fi
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export -f test_ssh_connection execute_remote_command execute_remote_script
export -f create_ssh_tunnel check_tunnel_status close_ssh_tunnel
export -f generate_ssh_key copy_ssh_key
