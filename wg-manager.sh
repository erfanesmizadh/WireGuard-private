#!/bin/bash

source config/defaults.conf
source lib/colors.sh
source lib/logger.sh
source lib/checks.sh
source lib/network.sh
source actions/generate_keys.sh
source actions/create_iran.sh
source actions/create_outside.sh

check_root
check_os

echo -e "${YELLOW}
===========================
 WireGuard PRO Manager
===========================
${NC}"

echo "1) Install WireGuard"
echo "2) Generate Keys"
echo "3) Create Iran Config"
echo "4) Create Outside Config"
echo "5) Enable Forwarding"
echo "6) Status"
echo "0) Exit"

read -p "Select: " c
case $c in
  2) generate_keys ;;
  3) read -p "Outside IP: " OUTSIDE_IP; create_iran ;;
  4) read -p "Iran IP: " IRAN_IP; create_outside ;;
  5) enable_forwarding ;;
  6) wg show ;;
esac
