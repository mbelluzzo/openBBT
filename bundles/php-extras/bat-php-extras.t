#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# PHP - extras test
# -----------------
#
# Author      :   Auke Kok
#
# Requirements:   bundle php-extras
#

#
# * verify php is present among its phpinfo
#
@test "Test every available dynamic PHP module" {
    PHPINDEX=$(mktemp /tmp/XXXXX.php)
    find /usr/lib64/extensions/no-debug-non-zts-*/ -type f -exec basename {} \; | while read -r mod; do
        echo -n "${mod}: "
        # shellcheck disable=SC2028
        echo "<?php  print(\"ok\\n\");  ?>" > "${PHPINDEX}"
        base=$(basename "${mod}" .so)
        php -derror_reporting=-1 -d extension="${base}" -f "${PHPINDEX}"
    done
}
