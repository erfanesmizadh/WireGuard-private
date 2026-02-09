log() {
  echo -e "${BLUE}[WG]${NC} $1"
}

ok() {
  echo -e "${GREEN}[OK]${NC} $1"
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
}
