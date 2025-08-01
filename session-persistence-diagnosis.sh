#!/bin/bash

# Session Persistence Diagnosis Script
# Comprehensive analysis of OAuth session persistence issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output file
OUTPUT_FILE="session-persistence-diagnosis-$(date +%Y%m%d-%H%M%S).md"

echo "🔍 Starting Session Persistence Diagnosis..."
echo "📝 Output will be saved to: $OUTPUT_FILE"

# Initialize output file with header
cat > "$OUTPUT_FILE" << 'EOF'
# Session Persistence Diagnosis Report

**Generated:** $(date)
**System:** $(uname -a)
**Issue:** OAuth login succeeds but session is not persisted/recognized

## Summary

This report contains comprehensive analysis of session persistence issues after successful OAuth authentication to identify why users can login infinitely without being recognized as logged in.

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

# Test 1: Database Analysis - User Creation
add_section "Database Analysis - User Creation"
echo -e "${YELLOW}Checking database for user creation...${NC}"

db_analysis=""

if docker compose exec -T db psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
    db_analysis="✅ **Database Connection:** Successful\n\n"
    
    # Check auth schema tables
    auth_tables=$(docker compose exec -T db psql -U postgres -c "\dt auth.*;" 2>/dev/null | head -20 || echo "Could not list auth tables")
    db_analysis="${db_analysis}**Auth Schema Tables:**\n$auth_tables\n\n"
    
    # Check users table structure
    users_structure=$(docker compose exec -T db psql -U postgres -c "\d auth.users;" 2>/dev/null | head -30 || echo "Could not describe users table")
    db_analysis="${db_analysis}**Users Table Structure:**\n$users_structure\n\n"
    
    # Count total users
    total_users=$(docker compose exec -T db psql -U postgres -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' \n' || echo "0")
    db_analysis="${db_analysis}**Total Users Count:** $total_users\n\n"
    
    # List recent users (if any)
    if [ "$total_users" -gt 0 ]; then
        recent_users=$(docker compose exec -T db psql -U postgres -c "SELECT id, email, provider, created_at, updated_at, email_confirmed_at, last_sign_in_at FROM auth.users ORDER BY created_at DESC LIMIT 5;" 2>/dev/null || echo "Could not fetch recent users")
        db_analysis="${db_analysis}**Recent Users:**\n$recent_users\n\n"
        
        # Check user metadata
        user_metadata=$(docker compose exec -T db psql -U postgres -c "SELECT id, raw_user_meta_data, user_metadata FROM auth.users ORDER BY created_at DESC LIMIT 3;" 2>/dev/null || echo "Could not fetch user metadata")
        db_analysis="${db_analysis}**User Metadata:**\n$user_metadata\n\n"
    else
        db_analysis="${db_analysis}❌ **No users found in database** - This is the main issue!\n\n"
    fi
    
    # Check identities table
    identities_count=$(docker compose exec -T db psql -U postgres -t -c "SELECT COUNT(*) FROM auth.identities;" 2>/dev/null | tr -d ' \n' || echo "0")
    db_analysis="${db_analysis}**Identities Count:** $identities_count\n\n"
    
    if [ "$identities_count" -gt 0 ]; then
        recent_identities=$(docker compose exec -T db psql -U postgres -c "SELECT user_id, provider, provider_id, identity_data, created_at FROM auth.identities ORDER BY created_at DESC LIMIT 3;" 2>/dev/null || echo "Could not fetch identities")
        db_analysis="${db_analysis}**Recent Identities:**\n$recent_identities\n\n"
    fi
    
else
    db_analysis="❌ **Database Connection:** Failed"
fi

add_result "$db_analysis"

# Test 2: Session Management Analysis
add_section "Session Management Analysis"
echo -e "${YELLOW}Analyzing session management...${NC}"

session_analysis=""

if docker compose exec -T db psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
    # Check sessions table
    sessions_count=$(docker compose exec -T db psql -U postgres -t -c "SELECT COUNT(*) FROM auth.sessions;" 2>/dev/null | tr -d ' \n' || echo "0")
    session_analysis="**Active Sessions Count:** $sessions_count\n\n"
    
    if [ "$sessions_count" -gt 0 ]; then
        active_sessions=$(docker compose exec -T db psql -U postgres -c "SELECT id, user_id, created_at, updated_at, factor_id, aal, ip, user_agent FROM auth.sessions ORDER BY updated_at DESC LIMIT 5;" 2>/dev/null || echo "Could not fetch sessions")
        session_analysis="${session_analysis}**Active Sessions:**\n$active_sessions\n\n"
    else
        session_analysis="${session_analysis}❌ **No active sessions found**\n\n"
    fi
    
    # Check refresh tokens
    refresh_tokens_count=$(docker compose exec -T db psql -U postgres -t -c "SELECT COUNT(*) FROM auth.refresh_tokens;" 2>/dev/null | tr -d ' \n' || echo "0")
    session_analysis="${session_analysis}**Refresh Tokens Count:** $refresh_tokens_count\n\n"
    
    if [ "$refresh_tokens_count" -gt 0 ]; then
        refresh_tokens=$(docker compose exec -T db psql -U postgres -c "SELECT token, user_id, revoked, created_at, updated_at FROM auth.refresh_tokens ORDER BY updated_at DESC LIMIT 3;" 2>/dev/null || echo "Could not fetch refresh tokens")
        session_analysis="${session_analysis}**Recent Refresh Tokens:**\n$refresh_tokens\n\n"
    fi
    
    # Check flow_state table (OAuth flow tracking)
    flow_state_count=$(docker compose exec -T db psql -U postgres -t -c "SELECT COUNT(*) FROM auth.flow_state;" 2>/dev/null | tr -d ' \n' || echo "0")
    session_analysis="${session_analysis}**Flow State Count:** $flow_state_count\n\n"
    
    if [ "$flow_state_count" -gt 0 ]; then
        recent_flow_states=$(docker compose exec -T db psql -U postgres -c "SELECT id, user_id, provider_type, authentication_method, created_at, updated_at FROM auth.flow_state ORDER BY updated_at DESC LIMIT 3;" 2>/dev/null || echo "Could not fetch flow states")
        session_analysis="${session_analysis}**Recent Flow States:**\n$recent_flow_states\n\n"
    fi
    
else
    session_analysis="❌ **Cannot analyze sessions:** Database not accessible"
fi

add_result "$session_analysis"

# Test 3: OAuth Callback Processing Analysis
add_section "OAuth Callback Processing Analysis"
echo -e "${YELLOW}Analyzing OAuth callback processing...${NC}"

callback_analysis=""

# Check if callback endpoint is accessible
callback_response=$(curl -s --max-time 10 "https://syntropy.cc/auth/callback" 2>/dev/null || echo "")
if [ ! -z "$callback_response" ]; then
    callback_analysis="✅ **Callback Endpoint:** Accessible\n\n"
    
    # Check if it's a valid Next.js page
    if echo "$callback_response" | grep -q "DOCTYPE html" || echo "$callback_response" | grep -q "next"; then
        callback_analysis="${callback_analysis}✅ **Callback Page Type:** Next.js page detected\n\n"
    else
        callback_analysis="${callback_analysis}⚠️  **Callback Page Type:** Unexpected response\n\n"
    fi
else
    callback_analysis="❌ **Callback Endpoint:** Not accessible\n\n"
fi

# Check callback file existence and content
if [ -f "app/auth/callback/page.tsx" ]; then
    callback_analysis="${callback_analysis}✅ **Callback File:** Found at app/auth/callback/page.tsx\n\n"
    
    # Check callback file content for key functions
    callback_content=$(cat "app/auth/callback/page.tsx" 2>/dev/null || echo "Could not read file")
    
    if echo "$callback_content" | grep -q "exchangeCodeForSession"; then
        callback_analysis="${callback_analysis}✅ **Code Exchange:** exchangeCodeForSession found\n"
    else
        callback_analysis="${callback_analysis}❌ **Code Exchange:** exchangeCodeForSession NOT found\n"
    fi
    
    if echo "$callback_content" | grep -q "getSession"; then
        callback_analysis="${callback_analysis}✅ **Session Check:** getSession found\n"
    else
        callback_analysis="${callback_analysis}❌ **Session Check:** getSession NOT found\n"
    fi
    
    if echo "$callback_content" | grep -q "searchParams"; then
        callback_analysis="${callback_analysis}✅ **URL Params:** searchParams handling found\n"
    else
        callback_analysis="${callback_analysis}❌ **URL Params:** searchParams handling NOT found\n"
    fi
    
    callback_analysis="${callback_analysis}\n**Callback File Content:**\n"
    add_result "$callback_analysis"
    add_code_block "typescript" "$callback_content"
    callback_analysis=""
    
else
    callback_analysis="${callback_analysis}❌ **Callback File:** NOT found at app/auth/callback/page.tsx\n\n"
fi

add_result "$callback_analysis"

# Test 4: Auth Service Logs Analysis
add_section "Auth Service Logs Analysis"
echo -e "${YELLOW}Analyzing auth service logs for callback processing...${NC}"

auth_logs_analysis=""

# Get recent auth logs
recent_auth_logs=$(docker compose logs --tail=50 auth 2>/dev/null | grep -E "(callback|oauth|google|login|session|user)" | tail -20 || echo "No relevant auth logs found")
auth_logs_analysis="**Recent Auth Logs (OAuth/Callback related):**\n$recent_auth_logs\n\n"

# Get any error logs
error_logs=$(docker compose logs --tail=100 auth 2>/dev/null | grep -i error | tail -10 || echo "No error logs found")
auth_logs_analysis="${auth_logs_analysis}**Recent Error Logs:**\n$error_logs\n\n"

# Get logs with specific patterns
callback_logs=$(docker compose logs --tail=100 auth 2>/dev/null | grep -E "(callback|code)" | tail -10 || echo "No callback-related logs found")
auth_logs_analysis="${auth_logs_analysis}**Callback Processing Logs:**\n$callback_logs\n"

add_result "$auth_logs_analysis"

# Test 5: Auth Configuration Analysis
add_section "Auth Configuration Analysis"
echo -e "${YELLOW}Analyzing authentication configuration...${NC}"

auth_config_analysis=""

# Check auth service environment variables
auth_env_vars=$(docker compose exec -T auth env 2>/dev/null | grep -E "(GOTRUE_|GOOGLE_|JWT_|SITE_URL|EXTERNAL_URL)" | sort || echo "Could not get auth environment variables")
auth_config_analysis="**Auth Service Environment Variables:**\n$auth_env_vars\n\n"

# Check auth settings endpoint
auth_settings=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null || echo "Could not fetch auth settings")
if echo "$auth_settings" | jq . >/dev/null 2>&1; then
    auth_config_analysis="${auth_config_analysis}**Auth Settings (from API):**\n$auth_settings\n\n"
else
    auth_config_analysis="${auth_config_analysis}**Auth Settings:** Could not fetch or parse\n\n"
fi

# Check auth health
auth_health=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/health" 2>/dev/null || echo "Health endpoint not available")
auth_config_analysis="${auth_config_analysis}**Auth Health Check:**\n$auth_health\n"

add_result "$auth_config_analysis"

# Test 6: Cookie and Session Analysis
add_section "Cookie and Session Analysis"
echo -e "${YELLOW}Analyzing cookie and session configuration...${NC}"

cookie_analysis=""

# Check cookie-related configuration
cookie_config=$(docker compose config | grep -A 30 "auth:" | grep -E "(COOKIE|CORS|SITE_URL)" || echo "No cookie configuration found")
cookie_analysis="**Cookie Configuration:**\n$cookie_config\n\n"

# Test cookie behavior
echo -e "${CYAN}Testing cookie behavior...${NC}"
cookie_test_response=$(curl -c /tmp/test_cookies.txt -b /tmp/test_cookies.txt -s -I "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null || echo "Cookie test failed")
cookie_analysis="${cookie_analysis}**Cookie Test Response:**\n$cookie_test_response\n\n"

if [ -f "/tmp/test_cookies.txt" ]; then
    cookie_content=$(cat /tmp/test_cookies.txt 2>/dev/null || echo "No cookies saved")
    cookie_analysis="${cookie_analysis}**Cookies Received:**\n$cookie_content\n\n"
    rm -f /tmp/test_cookies.txt
fi

# Check CORS headers
cors_headers=$(curl -s -I --max-time 10 -H "Origin: https://syntropy.cc" "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null | grep -E "(Access-Control|CORS|Origin)" || echo "No CORS headers found")
cookie_analysis="${cookie_analysis}**CORS Headers:**\n$cors_headers\n"

add_result "$cookie_analysis"

# Test 7: Frontend Integration Analysis
add_section "Frontend Integration Analysis"
echo -e "${YELLOW}Analyzing frontend integration...${NC}"

frontend_analysis=""

# Check Supabase client configuration
if [ -f "lib/supabase.ts" ] || [ -f "lib/supabase.js" ]; then
    supabase_config_file=$(find . -name "supabase.ts" -o -name "supabase.js" | head -1)
    if [ ! -z "$supabase_config_file" ]; then
        frontend_analysis="✅ **Supabase Config File:** Found at $supabase_config_file\n\n"
        supabase_config_content=$(cat "$supabase_config_file" 2>/dev/null || echo "Could not read file")
        frontend_analysis="${frontend_analysis}**Supabase Config Content:**\n"
        add_result "$frontend_analysis"
        add_code_block "typescript" "$supabase_config_content"
        frontend_analysis=""
    else
        frontend_analysis="❌ **Supabase Config File:** Not found\n\n"
    fi
else
    frontend_analysis="❌ **Supabase Config File:** Not found in common locations\n\n"
fi

# Check main page for auth state checking
if [ -f "app/page.tsx" ]; then
    frontend_analysis="${frontend_analysis}✅ **Main Page File:** Found\n\n"
    main_page_content=$(cat "app/page.tsx" 2>/dev/null | head -100 || echo "Could not read file")
    
    if echo "$main_page_content" | grep -q "useAuth\|getSession\|auth.user"; then
        frontend_analysis="${frontend_analysis}✅ **Auth State Check:** Auth state checking found in main page\n\n"
    else
        frontend_analysis="${frontend_analysis}❌ **Auth State Check:** No auth state checking found in main page\n\n"
    fi
    
    frontend_analysis="${frontend_analysis}**Main Page Content (first 100 lines):**\n"
    add_result "$frontend_analysis"
    add_code_block "typescript" "$main_page_content"
    frontend_analysis=""
else
    frontend_analysis="${frontend_analysis}❌ **Main Page File:** Not found\n\n"
fi

# Check for auth hook or provider
auth_hook_files=$(find . -name "*auth*" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) | grep -E "(hook|provider|context)" | head -5)
if [ ! -z "$auth_hook_files" ]; then
    frontend_analysis="${frontend_analysis}**Auth Related Files Found:**\n$auth_hook_files\n\n"
    
    # Show content of first auth file
    first_auth_file=$(echo "$auth_hook_files" | head -1)
    if [ ! -z "$first_auth_file" ]; then
        auth_file_content=$(cat "$first_auth_file" 2>/dev/null | head -50 || echo "Could not read file")
        frontend_analysis="${frontend_analysis}**Auth File Content ($first_auth_file - first 50 lines):**\n"
        add_result "$frontend_analysis"
        add_code_block "typescript" "$auth_file_content"
        frontend_analysis=""
    fi
else
    frontend_analysis="${frontend_analysis}❌ **Auth Files:** No auth hooks or providers found\n\n"
fi

add_result "$frontend_analysis"

# Test 8: Network Flow Analysis
add_section "Network Flow Analysis"
echo -e "${YELLOW}Analyzing network flow during OAuth...${NC}"

network_analysis=""

# Test OAuth flow step by step
echo -e "${CYAN}Testing OAuth flow steps...${NC}"

# Step 1: Initial OAuth URL generation
oauth_url_response=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>/dev/null)
if echo "$oauth_url_response" | grep -q "accounts.google.com"; then
    network_analysis="✅ **Step 1 - OAuth URL Generation:** Success\n"
    oauth_url=$(echo "$oauth_url_response" | grep -o 'https://accounts.google.com[^"]*' | head -1)
    network_analysis="${network_analysis}**Generated OAuth URL:** $oauth_url\n\n"
else
    network_analysis="❌ **Step 1 - OAuth URL Generation:** Failed\n\n"
fi

# Step 2: Test callback URL structure
network_analysis="${network_analysis}**Step 2 - Callback URL Analysis:**\n"
network_analysis="${network_analysis}Expected callback: https://syntropy.cc/auth/callback\n"
network_analysis="${network_analysis}Actual callback endpoint: $(curl -s -o /dev/null -w "%{http_code}" "https://syntropy.cc/auth/callback" 2>/dev/null)\n\n"

# Step 3: Check API endpoints availability
api_endpoints=("/auth/v1/settings" "/auth/v1/user" "/auth/v1/token")
network_analysis="${network_analysis}**Step 3 - API Endpoints Check:**\n"
for endpoint in "${api_endpoints[@]}"; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "https://api.syntropy.cc$endpoint" 2>/dev/null || echo "000")
    network_analysis="${network_analysis}$endpoint: HTTP $status_code\n"
done

add_result "$network_analysis"

# Test 9: Session Cookie Analysis
add_section "Session Cookie Analysis"
echo -e "${YELLOW}Analyzing session cookie behavior...${NC}"

session_cookie_analysis=""

# Test session creation flow
echo -e "${CYAN}Testing session cookie flow...${NC}"

# Create a test session request
session_test_response=$(curl -s -c /tmp/session_test.txt -b /tmp/session_test.txt --max-time 10 "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null || echo "Session test failed")
session_cookie_analysis="**Session Test Response:**\n$session_test_response\n\n"

if [ -f "/tmp/session_test.txt" ]; then
    session_cookies=$(cat /tmp/session_test.txt 2>/dev/null || echo "No session cookies")
    session_cookie_analysis="${session_cookie_analysis}**Session Cookies:**\n$session_cookies\n\n"
    rm -f /tmp/session_test.txt
else
    session_cookie_analysis="${session_cookie_analysis}**Session Cookies:** None created\n\n"
fi

# Check domain and security settings
cookie_domain_test=$(docker compose config | grep -A 50 "auth:" | grep -E "(COOKIE_DOMAIN|COOKIE_SECURE|COOKIE_SAME_SITE)" || echo "No cookie domain settings found")
session_cookie_analysis="${session_cookie_analysis}**Cookie Domain Settings:**\n$cookie_domain_test\n"

add_result "$session_cookie_analysis"

# Test 10: Real-time Debugging
add_section "Real-time Flow Debugging"
echo -e "${YELLOW}Performing real-time OAuth flow debugging...${NC}"

realtime_analysis=""

echo -e "${CYAN}Starting real-time log capture...${NC}"

# Start background log capture
docker compose logs -f auth > /tmp/realtime_auth_logs.log 2>&1 &
log_pid=$!

sleep 2

# Simulate OAuth flow
echo -e "${CYAN}Simulating OAuth flow...${NC}"
oauth_simulation=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" >/dev/null 2>&1 && echo "OAuth simulation successful" || echo "OAuth simulation failed")

sleep 3

# Stop log capture
kill $log_pid 2>/dev/null
wait $log_pid 2>/dev/null

# Analyze captured logs
if [ -f "/tmp/realtime_auth_logs.log" ]; then
    realtime_logs=$(tail -20 /tmp/realtime_auth_logs.log 2>/dev/null || echo "No real-time logs captured")
    realtime_analysis="**Real-time OAuth Flow Logs:**\n$realtime_logs\n\n"
    rm -f /tmp/realtime_auth_logs.log
else
    realtime_analysis="**Real-time Logs:** Could not capture\n\n"
fi

realtime_analysis="${realtime_analysis}**OAuth Simulation Result:** $oauth_simulation\n"

add_result "$realtime_analysis"

# Test 11: Root Cause Analysis
add_section "Root Cause Analysis and Recommendations"
echo -e "${YELLOW}Performing root cause analysis...${NC}"

root_cause_analysis="### 🔍 **ROOT CAUSE ANALYSIS**\n\n"

# Analyze user creation
if [ "$total_users" -eq 0 ]; then
    root_cause_analysis="${root_cause_analysis}❌ **CRITICAL ISSUE: No users in database**\n"
    root_cause_analysis="${root_cause_analysis}   - OAuth redirects successfully but users are not being created\n"
    root_cause_analysis="${root_cause_analysis}   - This indicates callback processing failure\n\n"
else
    root_cause_analysis="${root_cause_analysis}✅ **Users found in database:** $total_users\n\n"
fi

# Analyze sessions
if [ "$sessions_count" -eq 0 ]; then
    root_cause_analysis="${root_cause_analysis}❌ **CRITICAL ISSUE: No active sessions**\n"
    root_cause_analysis="${root_cause_analysis}   - Even if users exist, no sessions are being created/maintained\n"
    root_cause_analysis="${root_cause_analysis}   - This indicates session management failure\n\n"
else
    root_cause_analysis="${root_cause_analysis}✅ **Active sessions found:** $sessions_count\n\n"
fi

# Analyze callback processing
if [ ! -f "app/auth/callback/page.tsx" ]; then
    root_cause_analysis="${root_cause_analysis}❌ **CRITICAL ISSUE: Callback page missing**\n"
    root_cause_analysis="${root_cause_analysis}   - No callback processing implementation\n\n"
elif ! grep -q "exchangeCodeForSession" "app/auth/callback/page.tsx" 2>/dev/null; then
    root_cause_analysis="${root_cause_analysis}❌ **CRITICAL ISSUE: Incomplete callback processing**\n"
    root_cause_analysis="${root_cause_analysis}   - Callback page exists but doesn't process OAuth codes\n\n"
else
    root_cause_analysis="${root_cause_analysis}✅ **Callback processing implemented**\n\n"
fi

# Generate specific recommendations
root_cause_analysis="${root_cause_analysis}### 🎯 **SPECIFIC ISSUES IDENTIFIED**\n\n"

if [ "$total_users" -eq 0 ]; then
    root_cause_analysis="${root_cause_analysis}1. **User Creation Failure:**\n"
    root_cause_analysis="${root_cause_analysis}   - OAuth succeeds but users are not created in auth.users table\n"
    root_cause_analysis="${root_cause_analysis}   - Check callback processing and database permissions\n\n"
fi

if [ "$sessions_count" -eq 0 ]; then
    root_cause_analysis="${root_cause_analysis}2. **Session Management Failure:**\n"
    root_cause_analysis="${root_cause_analysis}   - No sessions are being created or maintained\n"
    root_cause_analysis="${root_cause_analysis}   - Check cookie configuration and domain settings\n\n"
fi

root_cause_analysis="${root_cause_analysis}### 🔧 **RECOMMENDED ACTIONS**\n\n"
root_cause_analysis="${root_cause_analysis}1. **Immediate Actions:**\n"
root_cause_analysis="${root_cause_analysis}   - Fix callback processing implementation\n"
root_cause_analysis="${root_cause_analysis}   - Verify database permissions and connectivity\n"
root_cause_analysis="${root_cause_analysis}   - Check cookie and session configuration\n\n"
root_cause_analysis="${root_cause_analysis}2. **Testing Actions:**\n"
root_cause_analysis="${root_cause_analysis}   - Monitor auth logs during login attempt\n"
root_cause_analysis="${root_cause_analysis}   - Verify OAuth code exchange in callback\n"
root_cause_analysis="${root_cause_analysis}   - Test session persistence across page reloads\n\n"

root_cause_analysis="${root_cause_analysis}### 📋 **CRITICAL METRICS**\n\n"
root_cause_analysis="${root_cause_analysis}- **Users in database:** $total_users\n"
root_cause_analysis="${root_cause_analysis}- **Active sessions:** $sessions_count\n"
root_cause_analysis="${root_cause_analysis}- **Callback implementation:** $([ -f "app/auth/callback/page.tsx" ] && echo "Present" || echo "Missing")\n"
root_cause_analysis="${root_cause_analysis}- **Code exchange logic:** $(grep -q "exchangeCodeForSession" "app/auth/callback/page.tsx" 2>/dev/null && echo "Present" || echo "Missing")\n"
root_cause_analysis="${root_cause_analysis}- **Database connectivity:** $(docker compose exec -T db psql -U postgres -c "SELECT 1;" >/dev/null 2>&1 && echo "OK" || echo "Failed")\n"

add_result "$root_cause_analysis"

# Final output
echo -e "\n${GREEN}✅ Session Persistence Diagnosis completed!${NC}"
echo -e "${GREEN}📝 Report saved to: $OUTPUT_FILE${NC}"
echo -e "\n${YELLOW}📤 Send this file to your LLM for comprehensive analysis.${NC}"
echo -e "${BLUE}💡 The report contains detailed information to identify why sessions are not persisting after OAuth login.${NC}"

# Show summary in terminal
echo -e "\n${PURPLE}📊 QUICK SUMMARY:${NC}"
echo -e "Users in DB: $([ "$total_users" -gt 0 ] && echo "${GREEN}$total_users${NC}" || echo "${RED}$total_users${NC}")"
echo -e "Active Sessions: $([ "$sessions_count" -gt 0 ] && echo "${GREEN}$sessions_count${NC}" || echo "${RED}$sessions_count${NC}")"
echo -e "Callback Page: $([ -f "app/auth/callback/page.tsx" ] && echo "${GREEN}Present${NC}" || echo "${RED}Missing${NC}")"