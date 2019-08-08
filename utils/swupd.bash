MIRROR_URL=https://download.clearlinux.org
LATEST_VER=$(curl --fail --silent --show-error "$MIRROR_URL"/latest)
LATEST_FORMAT=$(curl --fail --silent --show-error "$MIRROR_URL/update/$LATEST_VER/format")
SWUPD_CERT=$(mktemp)
curl --fail --silent --show-error --output "$SWUPD_CERT" "$MIRROR_URL/releases/$LATEST_VER/clear/Swupd_Root.pem"
