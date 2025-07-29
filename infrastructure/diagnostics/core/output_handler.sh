#!/bin/bash

#===============================================================================
# OUTPUT HANDLER
#===============================================================================

# Importa dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/utils.sh"

# Configuração global
declare -r DIAGNOSTIC_BASE_DIR="${HOME}/diagnose"
declare OUTPUT_DIR=""
declare LAYER_NAME=""
declare TIMESTAMP=""
declare -r PID="$$"

#===============================================================================
# DIRECTORY MANAGEMENT
#===============================================================================

init_output_handler() {
    local layer="$1"
    LAYER_NAME="$layer"
    TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
    OUTPUT_DIR="$DIAGNOSTIC_BASE_DIR/$TIMESTAMP"
    CACHE_DIR="$OUTPUT_DIR/.cache"

    # Cria estrutura de diretórios
    for dir in "$OUTPUT_DIR" "$CACHE_DIR"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            log_warning "Failed to create directory, attempting with sudo: $dir"
            if ! sudo mkdir -p "$dir" 2>/dev/null; then
                log_error "Could not create directory: $dir"
                return 1
            fi
            sudo chown -R "$(id -u):$(id -g)" "$dir"
        fi

        # Verifica permissões de escrita
        if [[ ! -w "$dir" ]]; then
            log_error "Directory is not writable: $dir"
            return 1
        fi
    done

    log_debug "Output handler initialized for layer: $layer (Dir: $OUTPUT_DIR)"
    log_debug "Cache directory created at: $CACHE_DIR"
    return 0
}

get_output_dir() {
    echo "$OUTPUT_DIR"
}

ensure_output_permissions() {
    local path="$1"
    if [[ ! -w "$(dirname "$path")" ]]; then
        sudo chown -R "$(id -u):$(id -g)" "$(dirname "$path")"
        if [[ $? -ne 0 ]]; then
            log_error "Failed to set permissions for: $path"
            return 1
        fi
    fi
    return 0
}

#===============================================================================
# FILE GENERATION
#===============================================================================

generate_summary_txt() {
    local title="$1"
    local content="$2"
    local output_file="$OUTPUT_DIR/diagnostic_summary_${TIMESTAMP}_${PID}.txt"

    ensure_output_permissions "$output_file" || return 1

    cat > "$output_file" << EOF
==========================================================================
$title - Summary Report
Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Layer: $LAYER_NAME
Process ID: $PID
==========================================================================

$content
EOF

    log_debug "Generated summary at: $output_file"
    return 0
}

generate_results_json() {
    local content="$1"
    local output_file="$OUTPUT_DIR/diagnostic_results_${TIMESTAMP}_${PID}.json"
    local fallback_file="$OUTPUT_DIR/test_results_fallback.log"

    ensure_output_permissions "$output_file" || return 1
    ensure_output_permissions "$fallback_file" || return 1

    if ! echo "$content" | jq '.' > "$output_file" 2>/dev/null; then
        log_warning "Failed to generate JSON, using fallback format"
        echo "$content" > "$fallback_file"
        return 1
    fi

    log_debug "Generated results at: $output_file"
    return 0
}

copy_detailed_log() {
    local log_file="$1"
    local output_file="$OUTPUT_DIR/diagnostic_detailed.log"

    ensure_output_permissions "$output_file" || return 1

    if [[ -f "$log_file" ]]; then
        cp "$log_file" "$output_file" || {
            log_error "Failed to copy log file to: $output_file"
            return 1
        }
        log_debug "Copied detailed.log to: $output_file"
        return 0
    else
        log_error "Source log file not found: $log_file"
        return 1
    fi
}

#===============================================================================
# CLEANUP
#===============================================================================

cleanup_old_outputs() {
    local days="${1:-7}"

    # Remove diretórios mais antigos que X dias
    find "$DIAGNOSTIC_BASE_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +"$days" -exec rm -rf {} + 2>/dev/null || {
        log_warning "Failed to cleanup old outputs, attempting with sudo"
        sudo find "$DIAGNOSTIC_BASE_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +"$days" -exec rm -rf {} + 2>/dev/null
    }

    log_debug "Cleaned up diagnostic outputs older than $days days"
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export DIAGNOSTIC_BASE_DIR OUTPUT_DIR LAYER_NAME TIMESTAMP
export -f init_output_handler get_output_dir ensure_output_permissions
export -f generate_summary_txt generate_results_json copy_detailed_log
export -f cleanup_old_outputs
