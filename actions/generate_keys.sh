generate_keys() {
  mkdir -p keys
  wg genkey | tee keys/iran_private.key | wg pubkey > keys/iran_public.key
  wg genkey | tee keys/outside_private.key | wg pubkey > keys/outside_public.key
  ok "Keys generated"
}
