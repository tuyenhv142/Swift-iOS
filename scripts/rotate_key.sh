#!/bin/bash
# ============================================
# Script: rotate_key.sh
# Usage:  ./scripts/rotate_key.sh <new_api_key>
#
# 1. Updates Secrets.plist with the new key
# 2. Verifies the key can fetch a pre-auth token
# 3. Prints reminder to rotate on server first
# ============================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths relative to project root
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SECRETS_FILE="$PROJECT_DIR/TaiwanFoodFinder/Config/Secrets.plist"
BASE_URL="${BASE_URL:-http://localhost:8765/api}"

if [ $# -ne 1 ]; then
    echo -e "${RED}Usage: $0 <new_api_key>${NC}"
    echo "Example: $0 my_new_secret_key_2026"
    exit 1
fi

NEW_KEY="$1"

echo -e "${YELLOW}============================================"
echo " API Key Rotation"
echo "============================================"
echo -e "${NC}"
echo ""

# --- Pre-flight check ---
echo -e "${YELLOW}[1/4] Checking current Secrets.plist...${NC}"
if [ ! -f "$SECRETS_FILE" ]; then
    echo -e "${RED}ERROR: Secrets.plist not found at $SECRETS_FILE${NC}"
    exit 1
fi
OLD_KEY=$(/usr/libexec/PlistBuddy -c "Print :API_KEY" "$SECRETS_FILE" 2>/dev/null || echo "NOT_FOUND")
echo "  Current key: ${OLD_KEY:0:8}..."

# --- Verify new key against server ---
echo ""
echo -e "${YELLOW}[2/4] Testing new key against API...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 \
    -X POST "$BASE_URL/auth/token" \
    -H "Content-Type: application/json" \
    -d "{\"ApiKey\":\"$NEW_KEY\"}" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}✓ Server accepted new key (HTTP $HTTP_CODE)${NC}"
else
    echo -e "  ${RED}✗ Server rejected new key (HTTP $HTTP_CODE)${NC}"
    echo -e "  ${RED}  Rotate the key on the SERVER first, then re-run this script.${NC}"
    exit 1
fi

# --- Update Secrets.plist ---
echo ""
echo -e "${YELLOW}[3/4] Updating Secrets.plist...${NC}"
/usr/libexec/PlistBuddy -c "Set :API_KEY $NEW_KEY" "$SECRETS_FILE"
echo -e "  ${GREEN}✓ Secrets.plist updated${NC}"

# --- Revoke old key on server (manual step) ---
echo ""
echo -e "${YELLOW}[4/4] Next steps:${NC}"
echo "  ✓ Local Secrets.plist updated to new key"
echo "  ⚠  Manually revoke old key on the server:"
echo "       Old key: ${OLD_KEY:0:8}... (first 8 chars)"
echo ""
echo -e "${GREEN}Done. New key is active locally.${NC}"
echo -e "${GREEN}Rebuild the app to pick up the change.${NC}"
