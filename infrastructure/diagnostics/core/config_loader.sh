#!/bin/bash

#===============================================================================
# CONFIGURATION LOADING
#===============================================================================

load_config() {
    local config_file="$1"
    local required_keys="${2:-}"
    
    # Verifica se arquivo existe
    if [[ ! -f "$config_file" ]]; then
        echo "Config file not found: $config_file" >&2
        return 1
    }
    
    # Verifica se é JSON válido
    if ! jq '.' "$config_file" >/dev/null 2>&1; then
        echo "Invalid JSON in config file: $config_file" >&2
        return 1
    }
    
    # Verifica keys obrigatórias
    if [[ -n "$required_keys" ]]; then
        local missing_keys=()
        for key in $required_keys; do
            if ! jq -e ".$key" "$config_file" >/dev/null 2>&1; then
                missing_keys+=("$key")
            fi
        done
        
        if (( ${#missing_keys[@]} > 0 )); then
            echo "Missing required keys in config: ${missing_keys[*]}" >&2
            return 1
        fi
    fi
    
    # Retorna conteúdo do config
    cat "$config_file"
}

get_config_value() {
    local config_json="$1"
    local key_path="$2"
    local default_value="${3:-}"
    
    local value
    value=$(echo "$config_json" | jq -r "$key_path" 2>/dev/null)
    
    if [[ "$value" == "null" ]] || [[ -z "$value" ]]; then
        echo "$default_value"
    else
        echo "$value"
    fi
}

merge_configs() {
    local base_config="$1"
    local override_config="$2"
    
    if [[ ! -f "$override_config" ]]; then
        cat "$base_config"
        return
    fi
    
    jq -s '.[0] * .[1]' "$base_config" "$override_config"
}

validate_config_schema() {
    local config_file="$1"
    local schema_file="$2"
    
    if ! command -v jsonschema >/dev/null 2>&1; then
        echo "jsonschema validator not found. Installing..."
        pip install jsonschema >/dev/null 2>&1 || {
            echo "Failed to install jsonschema" >&2
            return 1
        }
    fi
    
    jsonschema -i "$config_file" "$schema_file"
}

#===============================================================================
# ENVIRONMENT VARIABLES
#===============================================================================

load_env_file() {
    local env_file="$1"
    local required_vars="${2:-}"
    
    if [[ ! -f "$env_file" ]]; then
        echo "Environment file not found: $env_file" >&2
        return 1
    fi
    
    # Carrega variáveis
    set -a
    source "$env_file"
    set +a
    
    # Verifica vars obrigatórias
    if [[ -n "$required_vars" ]]; then
        local missing_vars=()
        for var in $required_vars; do
            if [[ -z "${!var}" ]]; then
                missing_vars+=("$var")
            fi
        done
        
        if (( ${#missing_vars[@]} > 0 )); then
            echo "Missing required environment variables: ${missing_vars[*]}" >&2
            return 1
        fi
    fi
    
    return 0
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export -f load_config get_config_value merge_configs validate_config_schema load_env_file
