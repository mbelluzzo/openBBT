#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# PHP - basic test
# -----------------
#
# Author      :   Salvador Fuentes
#
# Requirements:   bundle php-basic
#

#
# * verify php is present among its phpinfo
#
@test "Load php file information to verify it's present" {
    PHPINDEX=$(mktemp /tmp/XXXXX.php)
    echo "<?php  phpinfo();  ?>" > $PHPINDEX
    php $PHPINDEX 2>/dev/null| grep -q "PHP Version"
}

#
# * verify that php loads desired data
#
@test "php shows the date" {
    PHPDATE=$(mktemp /tmp/XXXXX.php)
    cat > $PHPDATE << EOF
<?php
date_default_timezone_set('America/Mexico_City');
echo 'Today is ' . date('Y-m-d h:i:s l');
?>
EOF
    php $PHPDATE | egrep "Today is [0-9]+-[0-9][0-9]+"
}
