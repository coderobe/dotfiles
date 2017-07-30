SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR" > /dev/null 2>&1
(
	cd "${SYSTEMD_USER_DIR}"
	for service in *; do
		REALPATH="$(readlink -f ${service})"
		if [ -L "${service}" ] && [ ! -f "${REALPATH}" ]; then
			rm "${service}" && cdr_log $(cdr_colorize $COL_RED "Unlinked orphan ${service} (No ${REALPATH})")
			systemctl --user daemon-reload
		fi
		unset REALPATH
	done
)
