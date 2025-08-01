#!/bin/bash

# Docker Services Diagnosis Script
# Comprehensive analysis of why localhost services are not accessible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Output file
OUTPUT_FILE="docker-services-diagnosis-$(date +%Y%m%d-%H%M%S).md"

echo "🔍 Starting Docker Services Diagnosis..."
echo "📝 Output will be saved to: $OUTPUT_FILE"

# Initialize output file with header
cat > "$OUTPUT_FILE" << 'EOF'
# Docker Services Diagnosis Report

**Generated:** $(date)
**System:** $(uname -a)
**User:** $(whoami)
**Working Directory:** $(pwd)

## Summary

This report contains comprehensive analysis of Docker services accessibility issues to identify why localhost ports are not accessible.

---

EOF

# Function to add section to output
add_section() {
    local title="$1"
    echo -e "\n## $title\n" >> "$OUTPUT_FILE"
    echo -e "${BLUE}🔍 Testing: $title${NC}"
}

# Function to add result to output
add_result() {
    local result="$1"
    echo -e "$result\n" >> "$OUTPUT_FILE"
}

# Function to add code block to output
add_code_block() {
    local lang="$1"
    local content="$2"
    echo -e "\`\`\`$lang" >> "$OUTPUT_FILE"
    echo -e "$content" >> "$OUTPUT_FILE"
    echo -e "\`\`\`\n" >> "$OUTPUT_FILE"
}

# Test 1: System Information
add_section "System Information"
system_info="**Operating System:** $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)\n"
system_info="${system_info}**Kernel:** $(uname -r)\n"
system_info="${system_info}**Architecture:** $(uname -m)\n"
system_info="${system_info}**User:** $(whoami)\n"
system_info="${system_info}**Groups:** $(groups)\n"
system_info="${system_info}**Shell:** $SHELL\n"
system_info="${system_info}**Working Directory:** $(pwd)\n"
system_info="${system_info}**Home Directory:** $HOME\n"
add_result "$system_info"

# Test 2: Docker Installation Analysis
add_section "Docker Installation Analysis"
echo -e "${YELLOW}Checking Docker installation...${NC}"
docker_analysis=""

# Check Docker version
if command -v docker &> /dev/null; then
    docker_version=$(docker --version 2>/dev/null || echo "Docker command failed")
    docker_analysis="✅ **Docker Available:** $docker_version\n\n"
    
    # Check Docker daemon status
    if docker info >/dev/null 2>&1; then
        docker_analysis="${docker_analysis}✅ **Docker Daemon:** Running\n\n"
        
        # Docker daemon info
        docker_info=$(docker info 2>/dev/null | head -20 || echo "Could not get Docker info")
        docker_analysis="${docker_analysis}**Docker Daemon Info:**\n$docker_info\n\n"
    else
        docker_analysis="${docker_analysis}❌ **Docker Daemon:** Not running or not accessible\n\n"
        docker_error=$(docker info 2>&1 || echo "No error details")
        docker_analysis="${docker_analysis}**Error Details:** $docker_error\n\n"
    fi
    
    # Check Docker permissions
    docker_perms=$(ls -la /var/run/docker.sock 2>/dev/null || echo "Docker socket not found")
    docker_analysis="${docker_analysis}**Docker Socket Permissions:**\n$docker_perms\n\n"
    
    # Check if user is in docker group
    if groups | grep -q docker; then
        docker_analysis="${docker_analysis}✅ **User in docker group:** Yes\n"
    else
        docker_analysis="${docker_analysis}❌ **User in docker group:** No\n"
    fi
else
    docker_analysis="❌ **Docker:** Not installed or not in PATH"
fi

add_result "$docker_analysis"

# Test 3: Docker Compose Analysis
add_section "Docker Compose Analysis"
echo -e "${YELLOW}Checking Docker Compose...${NC}"
compose_analysis=""

# Check docker-compose (old version)
if command -v docker-compose &> /dev/null; then
    compose_version=$(docker-compose --version 2>/dev/null || echo "docker-compose command failed")
    compose_analysis="✅ **docker-compose Available:** $compose_version\n\n"
    COMPOSE_CMD="docker-compose"
fi

# Check docker compose (new version)
if docker compose version >/dev/null 2>&1; then
    compose_v2_version=$(docker compose version 2>/dev/null || echo "docker compose command failed")
    compose_analysis="${compose_analysis}✅ **docker compose Available:** $compose_v2_version\n\n"
    if [ -z "$COMPOSE_CMD" ]; then
        COMPOSE_CMD="docker compose"
    fi
fi

if [ -z "$COMPOSE_CMD" ]; then
    compose_analysis="❌ **Docker Compose:** Not available"
    COMPOSE_CMD="docker-compose" # fallback for further tests
else
    compose_analysis="${compose_analysis}**Selected Command:** $COMPOSE_CMD\n"
fi

add_result "$compose_analysis"

# Test 4: Docker Compose File Analysis
add_section "Docker Compose Configuration Analysis"
echo -e "${YELLOW}Analyzing compose files...${NC}"
compose_config_analysis=""

# Check for compose files
compose_files=("docker-compose.yml" "docker-compose.yaml" "compose.yml" "compose.yaml" "docker-compose.override.yml")
found_files=""
for file in "${compose_files[@]}"; do
    if [ -f "$file" ]; then
        found_files="$found_files$file "
        compose_config_analysis="${compose_config_analysis}✅ **Found:** $file\n"
    fi
done

if [ -z "$found_files" ]; then
    compose_config_analysis="❌ **No Docker Compose files found**"
else
    compose_config_analysis="${compose_config_analysis}\n**Found Files:** $found_files\n\n"
    
    # Validate compose file syntax
    if $COMPOSE_CMD config >/dev/null 2>&1; then
        compose_config_analysis="${compose_config_analysis}✅ **Syntax:** Valid\n\n"
        
        # Get full composed configuration
        composed_config=$($COMPOSE_CMD config 2>/dev/null | head -100 || echo "Could not get composed config")
        add_result "$compose_config_analysis"
        add_code_block "yaml" "$composed_config"
    else
        compose_error=$($COMPOSE_CMD config 2>&1 || echo "Unknown error")
        compose_config_analysis="${compose_config_analysis}❌ **Syntax:** Invalid\n\n**Error:**\n$compose_error\n"
        add_result "$compose_config_analysis"
    fi
fi

if [ -z "$found_files" ]; then
    add_result "$compose_config_analysis"
fi

# Test 5: Docker Services Status
add_section "Docker Services Status Analysis"
echo -e "${YELLOW}Checking services status...${NC}"
services_analysis=""

if [ ! -z "$found_files" ]; then
    # Get services list
    services_list=$($COMPOSE_CMD ps -a 2>/dev/null || echo "Could not list services")
    services_analysis="**All Services:**\n$services_list\n\n"
    
    # Count different states
    if echo "$services_list" | grep -q "Up"; then
        running_count=$(echo "$services_list" | grep -c "Up" || echo "0")
        services_analysis="${services_analysis}✅ **Running Services:** $running_count\n"
    else
        services_analysis="${services_analysis}❌ **Running Services:** 0\n"
    fi
    
    if echo "$services_list" | grep -q "Exit"; then
        exited_count=$(echo "$services_list" | grep -c "Exit" || echo "0")
        services_analysis="${services_analysis}❌ **Exited Services:** $exited_count\n"
    fi
    
    # Get individual service details
    services_analysis="${services_analysis}\n**Individual Service Analysis:**\n"
    for service in auth db kong rest realtime storage nextjs; do
        service_status=$($COMPOSE_CMD ps $service 2>/dev/null | tail -n +2 || echo "Service not found")
        if [ ! -z "$service_status" ] && [ "$service_status" != "Service not found" ]; then
            services_analysis="${services_analysis}- **$service:** $service_status\n"
        fi
    done
else
    services_analysis="❌ **Cannot check services:** No compose files found"
fi

add_result "$services_analysis"

# Test 6: Container Processes Analysis
add_section "Container Processes Analysis"
echo -e "${YELLOW}Analyzing container processes...${NC}"
containers_analysis=""

# List all containers
all_containers=$(docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Could not list containers")
containers_analysis="**All Containers:**\n$all_containers\n\n"

# Focus on Syntropy containers
syntropy_containers=$(docker ps -a --filter "name=syntropy" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No Syntropy containers found")
containers_analysis="${containers_analysis}**Syntropy Containers:**\n$syntropy_containers\n\n"

# Check running containers specifically
running_containers=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No running containers")
containers_analysis="${containers_analysis}**Running Containers:**\n$running_containers\n"

add_result "$containers_analysis"

# Test 7: Port Binding Analysis
add_section "Port Binding Analysis"
echo -e "${YELLOW}Analyzing port bindings...${NC}"
ports_analysis=""

# Expected ports for Syntropy
expected_ports=(54321 9999 5432 3000 54320 54323 54324)

ports_analysis="**Expected Syntropy Ports Analysis:**\n\n"

for port in "${expected_ports[@]}"; do
    # Check if port is bound
    port_binding=$(docker ps --format "table {{.Names}}\t{{.Ports}}" 2>/dev/null | grep ":$port->" || echo "")
    
    if [ ! -z "$port_binding" ]; then
        ports_analysis="${ports_analysis}✅ **Port $port:** Bound\n$port_binding\n\n"
    else
        ports_analysis="${ports_analysis}❌ **Port $port:** Not bound\n\n"
    fi
    
    # Check if something else is using the port
    port_usage=$(netstat -tlnp 2>/dev/null | grep ":$port " || lsof -i :$port 2>/dev/null || echo "Port not in use")
    if [ "$port_usage" != "Port not in use" ]; then
        ports_analysis="${ports_analysis}**System usage for port $port:**\n$port_usage\n\n"
    fi
done

# Check all Docker port bindings
all_port_bindings=$(docker ps --format "table {{.Names}}\t{{.Ports}}" 2>/dev/null | grep -v "PORTS" || echo "No port bindings found")
ports_analysis="${ports_analysis}**All Docker Port Bindings:**\n$all_port_bindings\n"

add_result "$ports_analysis"

# Test 8: Network Analysis
add_section "Docker Network Analysis"
echo -e "${YELLOW}Analyzing Docker networks...${NC}"
network_analysis=""

# List Docker networks
docker_networks=$(docker network ls 2>/dev/null || echo "Could not list networks")
network_analysis="**Docker Networks:**\n$docker_networks\n\n"

# Check Syntropy network specifically
syntropy_network=$(docker network ls | grep syntropy || echo "No Syntropy network found")
network_analysis="${network_analysis}**Syntropy Networks:**\n$syntropy_network\n\n"

# Inspect networks if they exist
if echo "$docker_networks" | grep -q syntropy; then
    network_name=$(echo "$syntropy_network" | awk '{print $2}' | head -1)
    if [ ! -z "$network_name" ]; then
        network_details=$(docker network inspect "$network_name" 2>/dev/null | jq '.[0].Containers' 2>/dev/null || echo "Could not inspect network")
        network_analysis="${network_analysis}**Syntropy Network Details:**\n$network_details\n\n"
    fi
fi

# Check default network
default_network=$(docker network inspect bridge 2>/dev/null | jq '.[0].Containers' 2>/dev/null || echo "Could not inspect default network")
network_analysis="${network_analysis}**Default Bridge Network:**\n$default_network\n"

add_result "$network_analysis"

# Test 9: Resource Usage Analysis
add_section "System Resource Usage Analysis"
echo -e "${YELLOW}Checking system resources...${NC}"
resources_analysis=""

# Memory usage
memory_info=$(free -h 2>/dev/null || echo "Could not get memory info")
resources_analysis="**Memory Usage:**\n$memory_info\n\n"

# Disk usage
disk_info=$(df -h . 2>/dev/null || echo "Could not get disk info")
resources_analysis="${resources_analysis}**Disk Usage (current directory):**\n$disk_info\n\n"

# CPU info
cpu_info=$(nproc 2>/dev/null && echo " cores" || echo "Could not get CPU info")
resources_analysis="${resources_analysis}**CPU Cores:** $cpu_info\n\n"

# Docker resource usage
if docker stats --no-stream >/dev/null 2>&1; then
    docker_stats=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | head -10 || echo "Could not get Docker stats")
    resources_analysis="${resources_analysis}**Docker Container Stats:**\n$docker_stats\n\n"
fi

# Load average
load_avg=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' || echo "Could not get load average")
resources_analysis="${resources_analysis}**Load Average:**$load_avg\n"

add_result "$resources_analysis"

# Test 10: Logs Analysis
add_section "Docker Logs Analysis"
echo -e "${YELLOW}Analyzing Docker logs...${NC}"
logs_analysis=""

# Docker daemon logs (if accessible)
docker_daemon_logs=""
if journalctl -u docker --no-pager -n 20 >/dev/null 2>&1; then
    docker_daemon_logs=$(journalctl -u docker --no-pager -n 20 2>/dev/null || echo "Could not access Docker daemon logs")
elif [ -f /var/log/docker.log ]; then
    docker_daemon_logs=$(tail -20 /var/log/docker.log 2>/dev/null || echo "Could not read Docker log file")
else
    docker_daemon_logs="Docker daemon logs not accessible"
fi

logs_analysis="**Docker Daemon Logs (last 20 lines):**\n$docker_daemon_logs\n\n"

# Service logs
if [ ! -z "$found_files" ]; then
    for service in auth db kong rest; do
        service_logs=$($COMPOSE_CMD logs --tail=10 $service 2>/dev/null | head -20 || echo "No logs for $service")
        if [ "$service_logs" != "No logs for $service" ]; then
            logs_analysis="${logs_analysis}**$service Service Logs:**\n$service_logs\n\n"
        fi
    done
else
    logs_analysis="${logs_analysis}**Service Logs:** Cannot retrieve (no compose files)\n"
fi

add_result "$logs_analysis"

# Test 11: Environment Variables Analysis
add_section "Environment Variables Analysis"
echo -e "${YELLOW}Checking environment variables...${NC}"
env_analysis=""

# Check Docker-related environment variables
docker_env_vars=$(env | grep -i docker || echo "No Docker environment variables")
env_analysis="**Docker Environment Variables:**\n$docker_env_vars\n\n"

# Check compose-related environment variables
compose_env_vars=$(env | grep -i compose || echo "No Compose environment variables")
env_analysis="${env_analysis}**Compose Environment Variables:**\n$compose_env_vars\n\n"

# Check .env file
if [ -f ".env" ]; then
    env_file_count=$(wc -l .env 2>/dev/null | awk '{print $1}' || echo "0")
    env_analysis="${env_analysis}✅ **.env file:** Found ($env_file_count lines)\n"
    
    # Show non-sensitive variables from .env
    env_sample=$(grep -E '^[A-Z_]+(=|\s*=)' .env | head -10 | sed 's/=.*/=***MASKED***/' || echo "Could not read .env")
    env_analysis="${env_analysis}**Sample .env variables:**\n$env_sample\n\n"
else
    env_analysis="${env_analysis}❌ **.env file:** Not found\n\n"
fi

# Check important paths
important_paths="PATH DOCKER_HOST COMPOSE_PROJECT_NAME"
for var in $important_paths; do
    var_value=$(env | grep "^$var=" | cut -d'=' -f2- || echo "Not set")
    env_analysis="${env_analysis}**$var:** $var_value\n"
done

add_result "$env_analysis"

# Test 12: Firewall and Security Analysis
add_section "Firewall and Security Analysis"
echo -e "${YELLOW}Checking firewall and security settings...${NC}"
security_analysis=""

# Check if firewall is active
if command -v ufw &> /dev/null; then
    ufw_status=$(ufw status 2>/dev/null || echo "Could not check ufw status")
    security_analysis="**UFW Firewall:**\n$ufw_status\n\n"
fi

if command -v iptables &> /dev/null; then
    iptables_rules=$(iptables -L INPUT -n 2>/dev/null | head -10 || echo "Could not check iptables")
    security_analysis="${security_analysis}**IPTables Rules (INPUT chain):**\n$iptables_rules\n\n"
fi

# Check SELinux if available
if command -v getenforce &> /dev/null; then
    selinux_status=$(getenforce 2>/dev/null || echo "SELinux not available")
    security_analysis="${security_analysis}**SELinux Status:** $selinux_status\n\n"
fi

# Check AppArmor if available
if command -v aa-status &> /dev/null; then
    apparmor_status=$(aa-status 2>/dev/null | head -5 || echo "AppArmor not available")
    security_analysis="${security_analysis}**AppArmor Status:**\n$apparmor_status\n\n"
fi

# Check localhost connectivity
localhost_test=""
for port in 54321 9999 5432 3000; do
    if timeout 2 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        localhost_test="${localhost_test}✅ localhost:$port - ACCESSIBLE\n"
    else
        localhost_test="${localhost_test}❌ localhost:$port - NOT ACCESSIBLE\n"
    fi
done

security_analysis="${security_analysis}**Localhost Connectivity Test:**\n$localhost_test"

add_result "$security_analysis"

# Test 13: File Permissions Analysis
add_section "File Permissions Analysis"
echo -e "${YELLOW}Checking file permissions...${NC}"
permissions_analysis=""

# Check current directory permissions
current_dir_perms=$(ls -la . | head -5 2>/dev/null || echo "Could not check current directory")
permissions_analysis="**Current Directory Permissions:**\n$current_dir_perms\n\n"

# Check compose file permissions
for file in docker-compose.yml docker-compose.override.yml .env; do
    if [ -f "$file" ]; then
        file_perms=$(ls -la "$file" 2>/dev/null || echo "Could not check $file")
        permissions_analysis="${permissions_analysis}**$file permissions:** $file_perms\n"
    fi
done

# Check if we can write to current directory
if touch test-write-$(date +%s) 2>/dev/null; then
    rm -f test-write-*
    permissions_analysis="${permissions_analysis}\n✅ **Write permissions:** Current directory writable\n"
else
    permissions_analysis="${permissions_analysis}\n❌ **Write permissions:** Cannot write to current directory\n"
fi

add_result "$permissions_analysis"

# Test 14: Diagnosis Summary and Root Cause Analysis
add_section "Root Cause Analysis and Recommendations"
echo -e "${YELLOW}Performing root cause analysis...${NC}"

summary_analysis="### 🔍 **ROOT CAUSE ANALYSIS**\n\n"

# Analyze Docker availability
if command -v docker &> /dev/null; then
    summary_analysis="${summary_analysis}✅ **Docker Installation:** Available\n"
    if docker info >/dev/null 2>&1; then
        summary_analysis="${summary_analysis}✅ **Docker Daemon:** Running\n"
    else
        summary_analysis="${summary_analysis}❌ **Docker Daemon:** Not running or not accessible\n"
        summary_analysis="${summary_analysis}🔧 **ACTION REQUIRED:** Start Docker daemon or fix permissions\n\n"
    fi
else
    summary_analysis="${summary_analysis}❌ **Docker Installation:** Not found\n"
    summary_analysis="${summary_analysis}🔧 **ACTION REQUIRED:** Install Docker\n\n"
fi

# Analyze Compose availability
if [ ! -z "$COMPOSE_CMD" ]; then
    summary_analysis="${summary_analysis}✅ **Docker Compose:** Available ($COMPOSE_CMD)\n"
else
    summary_analysis="${summary_analysis}❌ **Docker Compose:** Not available\n"
    summary_analysis="${summary_analysis}🔧 **ACTION REQUIRED:** Install Docker Compose\n\n"
fi

# Analyze compose files
if [ ! -z "$found_files" ]; then
    summary_analysis="${summary_analysis}✅ **Compose Files:** Found ($found_files)\n"
    if $COMPOSE_CMD config >/dev/null 2>&1; then
        summary_analysis="${summary_analysis}✅ **Compose Syntax:** Valid\n"
    else
        summary_analysis="${summary_analysis}❌ **Compose Syntax:** Invalid\n"
        summary_analysis="${summary_analysis}🔧 **ACTION REQUIRED:** Fix compose file syntax errors\n\n"
    fi
else
    summary_analysis="${summary_analysis}❌ **Compose Files:** Not found\n"
    summary_analysis="${summary_analysis}🔧 **ACTION REQUIRED:** Create docker-compose.yml file\n\n"
fi

# Analyze services status
if echo "$services_list" | grep -q "Up" 2>/dev/null; then
    running_count=$(echo "$services_list" | grep -c "Up" 2>/dev/null || echo "0")
    summary_analysis="${summary_analysis}✅ **Services Running:** $running_count\n"
else
    summary_analysis="${summary_analysis}❌ **Services Running:** 0\n"
    summary_analysis="${summary_analysis}🔧 **ACTION REQUIRED:** Start services with '$COMPOSE_CMD up -d'\n\n"
fi

# Port accessibility summary
accessible_ports=0
for port in 54321 9999 5432 3000; do
    if timeout 2 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        ((accessible_ports++))
    fi
done

if [ $accessible_ports -gt 0 ]; then
    summary_analysis="${summary_analysis}✅ **Port Accessibility:** $accessible_ports/4 ports accessible\n"
else
    summary_analysis="${summary_analysis}❌ **Port Accessibility:** 0/4 ports accessible\n"
fi

summary_analysis="${summary_analysis}\n### 🎯 **RECOMMENDED ACTIONS**\n\n"

# Generate specific recommendations
if ! docker info >/dev/null 2>&1; then
    summary_analysis="${summary_analysis}1. **Start Docker daemon:**\n"
    summary_analysis="${summary_analysis}   \`sudo systemctl start docker\`\n\n"
fi

if [ ! -z "$found_files" ] && $COMPOSE_CMD config >/dev/null 2>&1; then
    if ! echo "$services_list" | grep -q "Up" 2>/dev/null; then
        summary_analysis="${summary_analysis}2. **Start services:**\n"
        summary_analysis="${summary_analysis}   \`$COMPOSE_CMD up -d\`\n\n"
    fi
fi

if [ $accessible_ports -eq 0 ]; then
    summary_analysis="${summary_analysis}3. **Wait for services to be ready:**\n"
    summary_analysis="${summary_analysis}   \`$COMPOSE_CMD ps\`\n"
    summary_analysis="${summary_analysis}   \`$COMPOSE_CMD logs -f\`\n\n"
fi

summary_analysis="${summary_analysis}4. **Verify connectivity:**\n"
summary_analysis="${summary_analysis}   \`curl http://localhost:54321/health\`\n\n"

summary_analysis="${summary_analysis}### 📋 **CRITICAL INFORMATION FOR LLM ANALYSIS**\n\n"
summary_analysis="${summary_analysis}- **Docker daemon status:** $(docker info >/dev/null 2>&1 && echo 'Running' || echo 'Not running')\n"
summary_analysis="${summary_analysis}- **Compose command:** $COMPOSE_CMD\n"
summary_analysis="${summary_analysis}- **Compose files found:** $found_files\n"
summary_analysis="${summary_analysis}- **Services running:** $(echo "$services_list" | grep -c "Up" 2>/dev/null || echo '0')\n"
summary_analysis="${summary_analysis}- **Accessible ports:** $accessible_ports/4\n"
summary_analysis="${summary_analysis}- **User permissions:** $(groups | grep -q docker && echo 'In docker group' || echo 'Not in docker group')\n"

add_result "$summary_analysis"

# Final output
echo -e "\n${GREEN}✅ Docker Services Diagnosis completed!${NC}"
echo -e "${GREEN}📝 Report saved to: $OUTPUT_FILE${NC}"
echo -e "\n${YELLOW}📤 Send this file to your LLM for comprehensive analysis.${NC}"
echo -e "${BLUE}💡 The report contains detailed information to identify why localhost services are not accessible.${NC}"