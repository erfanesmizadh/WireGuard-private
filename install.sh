#!/bin/bash
# ===============================================
# 🎯 WireGuard Full Manager (Iran & Outside)
# ===============================================

# رنگ‌ها
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RED="\e[31m"
PURPLE="\e[35m"
RESET="\e[0m"

KEY_DIR="/etc/wireguard"

clear
echo -e "${CYAN}====================================${RESET}"
echo -e "${GREEN}   🎉 WireGuard Full Manager 🎉   ${RESET}"
echo -e "${CYAN}====================================${RESET}\n"

# =============================
# نصب WireGuard
# =============================
install_wireguard() {
    echo -e "${BLUE}🚀 نصب WireGuard روی سیستم...${RESET}"
    sudo apt update && sudo apt install -y wireguard
    echo -e "${GREEN}✅ نصب کامل شد!${RESET}"
    sleep 1
}

# =============================
# ساخت کلید
# =============================
create_keys() {
    SERVER=$1  # iran یا outside
    echo -e "${YELLOW}🔑 ساخت کلید برای $SERVER...${RESET}"
    sudo mkdir -p $KEY_DIR
    sudo wg genkey | tee $KEY_DIR/${SERVER}_private.key | wg pubkey > $KEY_DIR/${SERVER}_public.key
    echo -e "${GREEN}✅ کلیدها ساخته شدند:${RESET}"
    echo -e "Private Key: $(sudo cat $KEY_DIR/${SERVER}_private.key)"
    echo -e "Public Key:  $(sudo cat $KEY_DIR/${SERVER}_public.key)"
    sleep 2
}

# =============================
# پیکربندی ایران
# =============================
config_iran() {
    echo -e "${CYAN}🌍 پیکربندی WireGuard ایران${RESET}"
    read -p "کلید خصوصی ایران: " PRIV_KEY
    read -p "کلید عمومی خارج: " PUB_KEY
    read -p "Address (مثال: 10.200.100.2/30, fd5a:40cb:954c::2/64): " ADDR
    read -p "ListenPort (مثال: 51820): " PORT
    read -p "MTU (مثال: 1372): " MTU
    read -p "Endpoint خارج (مثال: 5.57.38.140:51820): " ENDPOINT

    sudo tee $KEY_DIR/wg-iran.conf > /dev/null <<EOL
[Interface]
PrivateKey = $PRIV_KEY
Address = $ADDR
ListenPort = $PORT
MTU = $MTU
Table = off

[Peer]
PublicKey = $PUB_KEY
AllowedIPs = 10.200.100.1/32, fd5a:40cb:954c::1/128
Endpoint = $ENDPOINT
PersistentKeepalive = 25
EOL

    echo -e "${GREEN}✅ فایل wg-iran.conf ساخته شد${RESET}"
    sleep 1
}

# =============================
# پیکربندی خارج
# =============================
config_outside() {
    echo -e "${CYAN}🌍 پیکربندی WireGuard خارج${RESET}"
    read -p "کلید خصوصی خارج: " PRIV_KEY
    read -p "کلید عمومی ایران: " PUB_KEY
    read -p "Address (مثال: 10.200.100.1/30, fd5a:40cb:954c::1/64): " ADDR
    read -p "ListenPort (مثال: 51820): " PORT
    read -p "MTU (مثال: 1372): " MTU
    read -p "Endpoint ایران (مثال: 172.239.109.73:51820): " ENDPOINT

    sudo tee $KEY_DIR/wg-outside.conf > /dev/null <<EOL
[Interface]
PrivateKey = $PRIV_KEY
Address = $ADDR
ListenPort = $PORT
MTU = $MTU
Table = off

[Peer]
PublicKey = $PUB_KEY
AllowedIPs = 10.200.100.2/32, fd5a:40cb:954c::2/128
Endpoint = $ENDPOINT
PersistentKeepalive = 25
EOL

    echo -e "${GREEN}✅ فایل wg-outside.conf ساخته شد${RESET}"
    sleep 1
}

# =============================
# مدیریت سرویس
# =============================
manage_wg() {
    echo -e "${PURPLE}🔧 مدیریت سرویس WireGuard${RESET}"
    echo "1) روشن کردن ایران"
    echo "2) خاموش کردن ایران"
    echo "3) ریستارت ایران"
    echo "4) روشن کردن خارج"
    echo "5) خاموش کردن خارج"
    echo "6) ریستارت خارج"
    read -p "انتخاب شما: " WG_OPT

    case $WG_OPT in
        1) sudo wg-quick up wg-iran;;
        2) sudo wg-quick down wg-iran;;
        3) sudo wg-quick down wg-iran; sudo wg-quick up wg-iran;;
        4) sudo wg-quick up wg-outside;;
        5) sudo wg-quick down wg-outside;;
        6) sudo wg-quick down wg-outside; sudo wg-quick up wg-outside;;
        *) echo -e "${RED}گزینه نامعتبر!${RESET}";;
    esac
    sleep 1
}

# =============================
# نمایش کلیدها
# =============================
show_keys() {
    echo -e "${CYAN}🗝️ نمایش کلیدها${RESET}"
    for SERVER in iran outside; do
        echo -e "${YELLOW}--- $SERVER ---${RESET}"
        [ -f $KEY_DIR/${SERVER}_private.key ] && echo -e "Private Key: $(sudo cat $KEY_DIR/${SERVER}_private.key)" || echo "Private Key: ندارد"
        [ -f $KEY_DIR/${SERVER}_public.key ] && echo -e "Public Key:  $(sudo cat $KEY_DIR/${SERVER}_public.key)" || echo "Public Key: ندارد"
        echo ""
    done
    read -p "برای ادامه Enter را بزنید..."
}

# =============================
# منو اصلی
# =============================
while true; do
    clear
    echo -e "${CYAN}==============================${RESET}"
    echo -e "${GREEN}   🛠 WireGuard Full Menu 🛠   ${RESET}"
    echo -e "${CYAN}==============================${RESET}"
    echo -e "${YELLOW}1) نصب WireGuard"
    echo -e "2) ساخت کلید ایران"
    echo -e "3) ساخت کلید خارج"
    echo -e "4) پیکربندی ایران"
    echo -e "5) پیکربندی خارج"
    echo -e "6) مدیریت سرویس WireGuard"
    echo -e "7) نمایش کلیدها"
    echo -e "q) خروج${RESET}"
    read -p "انتخاب شما: " CHOICE

    case $CHOICE in
        1) install_wireguard;;
        2) create_keys iran;;
        3) create_keys outside;;
        4) config_iran;;
        5) config_outside;;
        6) manage_wg;;
        7) show_keys;;
        q|Q) exit 0;;
        *) echo -e "${RED}گزینه نامعتبر!${RESET}"; sleep 1;;
    esac
done
