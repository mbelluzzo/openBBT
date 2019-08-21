#!/usr/bin/env bats

setup() {
	BROKEN_FILE="$(mktemp)"
}

@test "systemd services are not missing supporting files" {
	# This test assumes that the files listed in the service do not contain spaces.
	# Accounting for quoting, and multiple commands separated by a semi-colon, should
	# be done per supported systemd syntax, but is not being done due to complexity.
	# For now, this is a safe operation because no files listed in any service to be
	# executed or read as the environment are quoted and the majority of services do
	# not have multiple commands separated by a semi-colon.
	find /usr/lib/systemd/system -mindepth 1 -maxdepth 1 -name '*.service' -print0 | while IFS= read -d $'\0' -r SERVICE; do
		sed -nr 's_^(Exec\w+|EnvironmentFile)=[+@!]*(/\S+).*$_\2_p' "$SERVICE" | while read -r FILE; do
			if [ -e "$FILE" ] || [[ "$FILE" == *"%"* ]] || grep -Pq "^ConditionPathExists=.*$FILE" "$SERVICE"; then
				continue
			else
				echo "$SERVICE cannot be started/stopped because $FILE does not exist"
			fi
		done
	done > "$BROKEN_FILE"
	cat "$BROKEN_FILE"
	[ ! -s "$BROKEN_FILE" ]
}

teardown() {
	rm -f "$BROKEN_FILE"
}
