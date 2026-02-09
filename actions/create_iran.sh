create_iran() {
cat > configs/wg-iran.conf <<EOF
[Interface]
PrivateKey = $(cat keys/iran_private.key)
Address = ${WG_IRAN_IPV4}, ${WG_IRAN_IPV6}
ListenPort = ${WG_PORT}
MTU = ${WG_MTU}

[Peer]
PublicKey = $(cat keys/outside_public.key)
AllowedIPs = ${WG_OUTSIDE_IPV4%/*}, ${WG_OUTSIDE_IPV6%/*}
Endpoint = ${OUTSIDE_IP}:${WG_PORT}
PersistentKeepalive = ${KEEPALIVE}
EOF
ok "wg-iran.conf created"
}
