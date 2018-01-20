#!/usr/bin/env bash

if [ "$(ls -A "${CDR_SYSTEMD_DIR}")" ] && [ "${CDR_WSL}" == 0 ]; then
(
		mkdir -p "${SYSTEMD_USER_DIR}" > /dev/null 2>&1
		cd "${CDR_SYSTEMD_DIR}" &&
		for service in *; do
			if [ ! -f "${SYSTEMD_USER_DIR}/${service}" ]; then
				ln -s "$(pwd)/${service}" "${SYSTEMD_USER_DIR}/" && cdr_log "$(cdr_colorize "$COL_GREEN" "Linked ${service}")"
				systemctl --user daemon-reload
			fi
		done
)
fi
