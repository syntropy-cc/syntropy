#!/bin/bash

# OAuth Diagnosis Script for Supabase + Google OAuth
# This script performs comprehensive tests to identify OAuth configuration issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output file
OUTPUT_FILE="oauth-diagnosis-$(date +%Y%m%d-%H%M%S).md"

echo "🔍 Starting OAuth Diagnosis..."
echo "📝 Output will be saved to: $OUTPUT_FILE"

# Initialize output file with header
cat > "$OUTPUT_FILE" << 'EOF'
# OAuth Diagnosis Report

**Generated:** $(date)
**System:** $(uname -a)

## Summary

This report contains comprehensive OAuth configuration analysis to identify the root cause of Google OAuth authentication issues.

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

# Test 1: Docker Services Status
add_section "Docker Services Status"
docker_status=$(docker-compose ps 2>/dev/null || echo "ERROR: docker-compose not available")
add_code_block "bash" "$docker_status"

# Test 2: Environment Variables
add_section "Environment Variables Analysis"
env_analysis=""
if [ -f ".env" ]; then
    env_analysis="✅ .env file exists\n"
    env_analysis="${env_analysis}$(grep -E '^(GOOGLE_|GITHUB_|JWT_|ANON_|SERVICE_|POSTGRES_)' .env | sed 's/=.*/=***MASKED***/' || echo 'No OAuth env vars found in .env')"
else
    env_analysis="❌ No .env file found"
fi
add_result "$env_analysis"

# Test 3: Docker Compose Configuration
add_section "Docker Compose OAuth Configuration"
auth_config=$(docker-compose config 2>/dev/null | grep -A 30 "auth:" | grep -E "(GOTRUE_|GOOGLE_|GITHUB_)" || echo "No OAuth environment variables found in docker-compose")
add_code_block "yaml" "$auth_config"

# Test 4: Supabase Configuration File
add_section "Supabase Configuration Files"
config_analysis=""
if [ -f "supabase/config.toml" ]; then
    config_analysis="✅ supabase/config.toml exists\n\n"
    config_analysis="${config_analysis}$(cat supabase/config.toml)"
else
    config_analysis="❌ supabase/config.toml not found"
fi
add_code_block "toml" "$config_analysis"

# Test 5: Network Connectivity Tests
add_section "Network Connectivity Tests"
connectivity_tests=""

# Test internal services
echo -e "${YELLOW}Testing internal connectivity...${NC}"
for service in "localhost:54321" "localhost:9999" "localhost:5432"; do
    if timeout 5 bash -c "echo >/dev/tcp/${service/:/ }" 2>/dev/null; then
        connectivity_tests="${connectivity_tests}✅ $service - ACCESSIBLE\n"
    else
        connectivity_tests="${connectivity_tests}❌ $service - NOT ACCESSIBLE\n"
    fi
done

# Test external domains
for domain in "syntropy.cc" "api.syntropy.cc"; do
    if curl -s --max-time 5 "https://$domain" >/dev/null 2>&1; then
        connectivity_tests="${connectivity_tests}✅ https://$domain - ACCESSIBLE\n"
    else
        connectivity_tests="${connectivity_tests}❌ https://$domain - NOT ACCESSIBLE\n"
    fi
done

add_result "$connectivity_tests"

# Test 6: Supabase Auth Settings
add_section "Supabase Auth Settings"
echo -e "${YELLOW}Fetching auth settings...${NC}"
auth_settings=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null || echo "ERROR: Could not fetch auth settings")
add_code_block "json" "$auth_settings"

# Test 7: OAuth URL Generation Tests
add_section "OAuth URL Generation Analysis"
echo -e "${YELLOW}Testing OAuth URL generation...${NC}"

oauth_tests=""

# Test Google OAuth URL without redirect_to
google_url_basic=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>/dev/null || echo "ERROR: Could not generate Google OAuth URL")
oauth_tests="${oauth_tests}### Basic Google OAuth URL\n\n"
oauth_tests="${oauth_tests}\`curl https://api.syntropy.cc/auth/v1/authorize?provider=google\`\n\n"
oauth_tests="${oauth_tests}**Response:**\n"
oauth_tests="${oauth_tests}$google_url_basic\n\n"

# Extract redirect_uri from the response
if echo "$google_url_basic" | grep -q "redirect_uri="; then
    redirect_uri=$(echo "$google_url_basic" | grep -o 'redirect_uri=[^&"]*' | head -1 | cut -d'=' -f2)
    decoded_redirect=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$redirect_uri'))" 2>/dev/null || echo "$redirect_uri")
    oauth_tests="${oauth_tests}**Extracted redirect_uri:** \`$decoded_redirect\`\n\n"
fi

# Test Google OAuth URL with redirect_to
google_url_redirect=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google&redirect_to=https://syntropy.cc/auth/callback" 2>/dev/null || echo "ERROR: Could not generate Google OAuth URL with redirect_to")
oauth_tests="${oauth_tests}### Google OAuth URL with redirect_to\n\n"
oauth_tests="${oauth_tests}\`curl 'https://api.syntropy.cc/auth/v1/authorize?provider=google&redirect_to=https://syntropy.cc/auth/callback'\`\n\n"
oauth_tests="${oauth_tests}**Response:**\n"
oauth_tests="${oauth_tests}$google_url_redirect\n\n"

# Extract redirect_uri from the response with redirect_to
if echo "$google_url_redirect" | grep -q "redirect_uri="; then
    redirect_uri_2=$(echo "$google_url_redirect" | grep -o 'redirect_uri=[^&"]*' | head -1 | cut -d'=' -f2)
    decoded_redirect_2=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$redirect_uri_2'))" 2>/dev/null || echo "$redirect_uri_2")
    oauth_tests="${oauth_tests}**Extracted redirect_uri:** \`$decoded_redirect_2\`\n\n"
fi

add_result "$oauth_tests"

# Test 8: Auth Service Logs Analysis
add_section "Recent Auth Service Logs"
echo -e "${YELLOW}Analyzing recent auth logs...${NC}"
auth_logs=$(docker-compose logs --tail=50 auth 2>/dev/null | grep -E "(oauth|google|redirect|error|callback)" || echo "No relevant auth logs found")
add_code_block "log" "$auth_logs"

# Test 9: Database Auth Tables Analysis
add_section "Database Authentication Tables"
echo -e "${YELLOW}Checking auth database tables...${NC}"
db_analysis=""

# Check if database is accessible
if docker-compose exec -T db psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
    db_analysis="✅ Database accessible\n\n"
    
    # Check auth schema tables
    db_tables=$(docker-compose exec -T db psql -U postgres -c "\dt auth.*;" 2>/dev/null || echo "Could not list auth tables")
    db_analysis="${db_analysis}**Auth Tables:**\n$db_tables\n\n"
    
    # Check for existing users
    user_count=$(docker-compose exec -T db psql -U postgres -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | grep -E '^[0-9]+$' || echo "0")
    db_analysis="${db_analysis}**User Count:** $user_count\n\n"
    
    # Check for existing sessions
    session_count=$(docker-compose exec -T db psql -U postgres -c "SELECT COUNT(*) FROM auth.sessions;" 2>/dev/null | grep -E '^[0-9]+$' || echo "0")
    db_analysis="${db_analysis}**Active Sessions:** $session_count\n\n"
    
    # Check auth provider configurations in database
    providers=$(docker-compose exec -T db psql -U postgres -c "SELECT provider FROM auth.identities GROUP BY provider;" 2>/dev/null || echo "No providers found")
    db_analysis="${db_analysis}**Configured Providers:**\n$providers\n"
else
    db_analysis="❌ Database not accessible"
fi

add_result "$db_analysis"

# Test 10: Kong Gateway Configuration
add_section "Kong Gateway Configuration"
echo -e "${YELLOW}Analyzing Kong configuration...${NC}"
kong_analysis=""

# Check Kong status
if curl -s --max-time 5 "http://localhost:54320/status" >/dev/null 2>&1; then
    kong_analysis="✅ Kong admin API accessible\n\n"
    
    # Get Kong routes
    kong_routes=$(curl -s --max-time 10 "http://localhost:54320/routes" 2>/dev/null | jq '.data[] | {name, protocols, hosts, paths}' 2>/dev/null || echo "Could not fetch Kong routes")
    kong_analysis="${kong_analysis}**Kong Routes:**\n$kong_routes\n\n"
    
    # Get Kong services
    kong_services=$(curl -s --max-time 10 "http://localhost:54320/services" 2>/dev/null | jq '.data[] | {name, protocol, host, port}' 2>/dev/null || echo "Could not fetch Kong services")
    kong_analysis="${kong_analysis}**Kong Services:**\n$kong_services\n"
else
    kong_analysis="❌ Kong admin API not accessible"
fi

add_result "$kong_analysis"

# Test 11: SSL/TLS Certificate Analysis
add_section "SSL/TLS Certificate Analysis"
echo -e "${YELLOW}Checking SSL certificates...${NC}"
ssl_analysis=""

for domain in "syntropy.cc" "api.syntropy.cc"; do
    ssl_info=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null || echo "Could not fetch SSL info for $domain")
    ssl_analysis="${ssl_analysis}**$domain:**\n$ssl_info\n\n"
done

add_result "$ssl_analysis"

# Test 12: DNS Resolution
add_section "DNS Resolution Analysis"
echo -e "${YELLOW}Checking DNS resolution...${NC}"
dns_analysis=""

for domain in "syntropy.cc" "api.syntropy.cc" "accounts.google.com"; do
    dns_result=$(nslookup "$domain" 2>/dev/null | grep -A 2 "Name:" || echo "DNS resolution failed for $domain")
    dns_analysis="${dns_analysis}**$domain:**\n$dns_result\n\n"
done

add_result "$dns_analysis"

# Test 13: HTTP Headers Analysis
add_section "HTTP Headers Analysis"
echo -e "${YELLOW}Analyzing HTTP headers...${NC}"
headers_analysis=""

# Check CORS headers
cors_headers=$(curl -s -I --max-time 10 "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null | grep -E "(Access-Control|CORS|Origin)" || echo "No CORS headers found")
headers_analysis="${headers_analysis}**CORS Headers:**\n$cors_headers\n\n"

# Check security headers
security_headers=$(curl -s -I --max-time 10 "https://syntropy.cc" 2>/dev/null | grep -E "(Strict-Transport|Content-Security|X-Frame)" || echo "No security headers found")
headers_analysis="${headers_analysis}**Security Headers:**\n$security_headers\n"

add_result "$headers_analysis"

# Test 14: File System Configuration
add_section "File System Configuration Analysis"
echo -e "${YELLOW}Checking configuration files...${NC}"
fs_analysis=""

# Check for important config files
config_files=("docker-compose.yml" "docker-compose.override.yml" ".env" "supabase/config.toml" "package.json")
for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        fs_analysis="${fs_analysis}✅ $file exists\n"
    else
        fs_analysis="${fs_analysis}❌ $file missing\n"
    fi
done

# Check directory structure
fs_analysis="${fs_analysis}\n**Directory Structure:**\n"
fs_analysis="${fs_analysis}$(find . -maxdepth 3 -type d | grep -E "(app|components|supabase|configs)" | sort || echo 'Standard directories not found')\n"

add_result "$fs_analysis"

# Test 15: Summary and Recommendations
add_section "Diagnosis Summary and Key Findings"

summary_analysis=""

# Analyze redirect URI mismatch
if echo "$google_url_basic" | grep -q "redirect_uri="; then
    actual_redirect=$(echo "$google_url_basic" | grep -o 'redirect_uri=[^&"]*' | head -1 | cut -d'=' -f2)
    decoded_actual=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$actual_redirect'))" 2>/dev/null || echo "$actual_redirect")
    
    summary_analysis="${summary_analysis}### 🔍 **ROOT CAUSE ANALYSIS**\n\n"
    summary_analysis="${summary_analysis}**Actual redirect_uri being sent to Google:**\n"
    summary_analysis="${summary_analysis}\`$decoded_actual\`\n\n"
    
    summary_analysis="${summary_analysis}**Expected redirect_uri configurations in Google OAuth:**\n"
    summary_analysis="${summary_analysis}- \`https://api.syntropy.cc/auth/v1/callback\`\n"
    summary_analysis="${summary_analysis}- \`$decoded_actual\` (if different from above)\n\n"
    
    if [[ "$decoded_actual" == *"api.syntropy.cc/auth/v1/callback"* ]]; then
        summary_analysis="${summary_analysis}✅ **The redirect URI format looks correct**\n\n"
    else
        summary_analysis="${summary_analysis}❌ **PROBLEM IDENTIFIED:** Unexpected redirect URI format\n\n"
    fi
fi

# Check service status
if echo "$docker_status" | grep -q "Up"; then
    summary_analysis="${summary_analysis}✅ Docker services are running\n"
else
    summary_analysis="${summary_analysis}❌ Docker services have issues\n"
fi

# Check auth settings
if echo "$auth_settings" | grep -q '"google":true'; then
    summary_analysis="${summary_analysis}✅ Google OAuth is enabled in Supabase\n"
else
    summary_analysis="${summary_analysis}❌ Google OAuth is not enabled in Supabase\n"
fi

summary_analysis="${summary_analysis}\n### 🎯 **NEXT STEPS**\n\n"
summary_analysis="${summary_analysis}1. **Verify Google OAuth redirect URI** matches the actual URI from this report\n"
summary_analysis="${summary_analysis}2. **Check environment variables** are properly loaded\n"
summary_analysis="${summary_analysis}3. **Review docker-compose configuration** for OAuth settings\n"
summary_analysis="${summary_analysis}4. **Examine auth service logs** for specific error patterns\n\n"

summary_analysis="${summary_analysis}### 📋 **CRITICAL INFORMATION FOR LLM ANALYSIS**\n\n"
summary_analysis="${summary_analysis}- **Actual redirect_uri:** \`$decoded_actual\`\n"
summary_analysis="${summary_analysis}- **Auth settings status:** $(echo "$auth_settings" | grep -o '"google":[^,]*' || echo 'unknown')\n"
summary_analysis="${summary_analysis}- **Docker services:** $(echo "$docker_status" | grep -c "Up" || echo '0') running\n"
summary_analysis="${summary_analysis}- **Configuration files:** $(ls -1 docker-compose*.yml .env supabase/config.toml 2>/dev/null | wc -l) found\n"

add_result "$summary_analysis"

# Final output
echo -e "\n${GREEN}✅ Diagnosis completed!${NC}"
echo -e "${GREEN}📝 Report saved to: $OUTPUT_FILE${NC}"
echo -e "\n${YELLOW}📤 Send this file to your LLM for comprehensive analysis.${NC}"
echo -e "${BLUE}💡 The report contains all necessary information to identify and fix the OAuth issue.${NC}"