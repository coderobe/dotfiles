#!/usr/bin/env bash

if [ -d "${SYSTEMD_USER_DIR}" ] && [ "${CDR_WSL}" == 0 ]; then
(
	cd "${SYSTEMD_USER_DIR}" &&
	for service in *; do
		REALPATH="$(readlink -f "${service}")"
		if [ -L "${service}" ] && [ ! -f "${REALPATH}" ]; then
			rm "${service}" && cdr_log "$(cdr_colorize "$COL_RED" "Unlinked orphan ${service} (No ${REALPATH})")"
			systemctl --user daemon-reload
		fi
		unset REALPATH
	done
)
fi
