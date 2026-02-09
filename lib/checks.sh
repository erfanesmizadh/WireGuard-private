check_root() {
  [[ $EUID -ne 0 ]] && fail "Run as root" && exit 1
}

check_os() {
  command -v apt &>/dev/null || {
    fail "Only Debian/Ubuntu supported"
    exit 1
  }
}
