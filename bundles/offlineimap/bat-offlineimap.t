#!/usr/bin/env bats
# mail-utils test
# --------------
#
# Author      :   William Douglas
#
# Requirements:   bundle offlineimap

@test "offline-imap usable" {
      # Simple test to verify the runtime dependencies
      # exist at least enough to get version information
      offlineimap -V
}
