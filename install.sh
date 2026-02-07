#!/usr/bin/env bash
set -e

echo "🔥 WireGuard Auto Setup Script (Iran / Outside Server) 🔥"
echo ""

# --- سوال از کاربر برای مشخص کردن نوع سرور ---
read -p "سرور شما کجاست؟ [iran/outside]: " SERVER_TYPE
SERVER_TYPE=${SERVER_TYPE,,}  # lowercase

# --- نصب WireGuard ---
echo "📦 نصب WireGuard..."
sudo apt update
sudo apt install -y wireguard

# --- مسیر ذخیره کلیدها ---
KEY_DIR="/etc/wireguard"
sudo mkdir -p $KEY_DIR

# --- تولید یا استفاده از کلیدها ---
if [ "$SERVER_TYPE" == "iran" ]; then
    PRIVATE_KEY_FILE="$KEY_DIR/iran_private.key"
    PUBLIC_KEY_FILE="$KEY_DIR/iran_public.key"
    PEER_PUBLIC_KEY_FILE="$KEY_DIR/outside_public.key"
elif [ "$SERVER_TYPE" == "outside" ]; then
    PRIVATE_KEY_FILE="$KEY_DIR/outside_private.key"
    PUBLIC_KEY_FILE="$KEY_DIR/outside_public.key"
    PEER_PUBLIC_KEY_FILE="$KEY_DIR/iran_public.key"
else
    echo "نوع سرور نامعتبر است! باید 'iran' یا 'outside' باشد."
    exit 1
fi

# --- تولید کلیدها اگر موجود نیستند ---
if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    echo "🔑 تولید کلید خصوصی و عمومی..."
    sudo wg genkey | sudo tee $PRIVATE_KEY_FILE | sudo wg pubkey | sudo tee $PUBLIC_KEY_FILE
else
    echo "کلیدها قبلاً موجود است."
fi

# نمایش کلیدها
echo "کلید خصوصی:"
sudo cat $PRIVATE_KEY_FILE
echo "کلید عمومی:"
sudo cat $PUBLIC_KEY_FILE

# --- سوال برای کلید عمومی Peer ---
read -p "کلید عمومی سرور مقابل را وارد کنید: " PEER_PUBLIC_KEY

# --- سوال برای IP ها ---
read -p "آدرس IP محلی (مثال: 172.21.31.2/30 برای ایران، 172.21.31.1/30 برای خارج): " LOCAL_IP
read -p "آدرس IP Peer (مثال: 172.21.31.1/32 برای ایران، 172.21.31.2/32 برای خارج): " PEER_IP

# --- سوال برای IPv6 (اختیاری) ---
read -p "آدرس IPv6 محلی (مثال: fd5a:40cb:954c::2/64) یا خالی برای نادیده گرفتن: " LOCAL_IPV6
read -p "آدرس IPv6 Peer (مثال: fd5a:40cb:954c::1/128) یا خالی برای نادیده گرفتن: " PEER_IPV6

# --- سوال برای پورت ---
read -p "پورت WireGuard (مثال: 51820): " WG_PORT

# --- سوال برای Endpoint ---
if [ "$SERVER_TYPE" == "iran" ]; then
    read -p "آدرس IP یا دامنه سرور خارج: " PEER_ENDPOINT
elif [ "$SERVER_TYPE" == "outside" ]; then
    read -p "آدرس IP یا دامنه سرور ایران: " PEER_ENDPOINT
fi

# --- ساخت فایل کانفیگ ---
CONFIG_FILE="$KEY_DIR/wg-$SERVER_TYPE.conf"
echo "ساخت فایل کانفیگ: $CONFIG_FILE"

sudo bash -c "cat > $CONFIG_FILE <<EOF
[Interface]
PrivateKey = $(sudo cat $PRIVATE_KEY_FILE)
Address = $LOCAL_IP$( [ -n "$LOCAL_IPV6" ] && echo ", $LOCAL_IPV6" )
ListenPort = $WG_PORT
MTU = 1372

[Peer]
PublicKey = $PEER_PUBLIC_KEY
AllowedIPs = $PEER_IP$( [ -n "$PEER_IPV6" ] && echo ", $PEER_IPV6" )
Endpoint = $PEER_ENDPOINT:$WG_PORT
PersistentKeepalive = 25
EOF"

echo "✅ فایل کانفیگ ساخته شد."

# --- فعال کردن تونل ---
echo "فعال کردن WireGuard..."
sudo wg-quick up wg-$SERVER_TYPE
sudo systemctl enable wg-quick@wg-$SERVER_TYPE

# --- نمایش وضعیت ---
echo "وضعیت WireGuard:"
sudo wg show

echo "🎉 نصب و کانفیگ WireGuard کامل شد."
