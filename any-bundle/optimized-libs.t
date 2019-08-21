#!/usr/bin/env bats

setup() {
	MISSING_LIBS_FILE="$(mktemp)"
}

@test "Optimized libraries are installed with their corresponding standard libraries" {
	OPTIMIZED_LIB_DIRS=(/usr/lib64/haswell/avx512_1 /usr/lib64/haswell)
	STANDARD_LIB_DIR=/usr/lib64
	for OPTIMIZED_LIB_DIR in "${OPTIMIZED_LIB_DIRS[@]}"; do
		find "$OPTIMIZED_LIB_DIR" -mindepth 1 -maxdepth 1 ! -type d ! -iname '*openblas*' -print0 | while IFS= read -r -d $'\0' OPTIMIZED_LIB_PATH; do
			OPTIMIZED_LIB_NAME="$(basename "$OPTIMIZED_LIB_PATH")"
			STANDARD_LIB_PATH="$STANDARD_LIB_DIR"/"$OPTIMIZED_LIB_NAME"
			if ! [ -e "$STANDARD_LIB_PATH" ]; then
				echo "Installed library: $OPTIMIZED_LIB_PATH, but missing library: $STANDARD_LIB_PATH"
			fi
		done
	done > "$MISSING_LIBS_FILE"
	cat "$MISSING_LIBS_FILE"
	[ ! -s "$MISSING_LIBS_FILE" ]
}

teardown() {
	rm -f "$MISSING_LIBS_FILE"
}
