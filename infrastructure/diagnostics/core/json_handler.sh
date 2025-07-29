#!/bin/bash

#===============================================================================
# JSON VALIDATION
#===============================================================================

is_valid_json() {
    local json_string="$1"
    echo "$json_string" | jq '.' >/dev/null 2>&1
}

#===============================================================================
# JSON GET/SET
#===============================================================================

json_get_value() {
    local json_string="$1"
    local key_path="$2"
    
    if is_valid_json "$json_string"; then
        echo "$json_string" | jq -r "$key_path" 2>/dev/null
    else
        return 1
    fi
}

json_set_value() {
    local json_string="$1"
    local key_path="$2"
    local value="$3"
    
    if is_valid_json "$json_string"; then
        echo "$json_string" | jq --arg val "$value" "$key_path = \$val" 2>/dev/null || echo "$json_string"
    else
        echo "{}"
    fi
}

json_merge() {
    local json1="$1"
    local json2="$2"
    
    if is_valid_json "$json1" && is_valid_json "$json2"; then
        echo "$json1" | jq --argjson obj2 "$json2" '. * $obj2' 2>/dev/null
    else
        echo "{}"
    fi
}

#===============================================================================
# JSON CREATION HELPERS
#===============================================================================

create_diagnostic_json() {
    local layer="$1"
    local status="$2"
    local timestamp="$3"
    local duration="$4"
    
    cat << EOF
{
    "layer": "$layer",
    "status": "$status", 
    "timestamp": "$timestamp",
    "duration_ms": $duration,
    "components": {},
    "summary": {},
    "recommendations": []
}
EOF
}

add_component_result() {
    local json_string="$1"
    local component_name="$2"
    local component_status="$3"
    local component_details="$4"
    
    echo "$json_string" | jq --arg name "$component_name" \
                            --arg status "$component_status" \
                            --argjson details "$component_details" \
                            '.components[$name] = {"status": $status} + $details'
}

add_recommendation() {
    local json_string="$1"
    local priority="$2"
    local message="$3"
    local action="$4"
    
    echo "$json_string" | jq --arg priority "$priority" \
                            --arg message "$message" \
                            --arg action "$action" \
                            '.recommendations += [{"priority": $priority, "message": $message, "action": $action}]'
}

#===============================================================================
# JSON ARRAY OPERATIONS
#===============================================================================

json_array_contains() {
    local json_array="$1"
    local value="$2"
    
    if is_valid_json "$json_array"; then
        echo "$json_array" | jq --arg val "$value" 'contains([$val])' 2>/dev/null
    else
        echo "false"
    fi
}

json_array_length() {
    local json_array="$1"
    
    if is_valid_json "$json_array"; then
        echo "$json_array" | jq 'length' 2>/dev/null
    else
        echo "0"
    fi
}

#===============================================================================
# JSON ENCODING
#===============================================================================

json_encode() {
    local value="$1"
    echo "$value" | jq -R -s '.' 2>/dev/null || echo '""'
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export -f is_valid_json json_get_value json_set_value json_merge json_encode
export -f create_diagnostic_json add_component_result add_recommendation
export -f json_array_contains json_array_length
