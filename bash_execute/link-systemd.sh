SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR" > /dev/null 2>&1
(
	cd $(cdr_exedir)/../systemd
	for service in *; do
		if [ ! -f "$SYSTEMD_USER_DIR/$service" ]; then
			ln -s $(pwd)/$service "$SYSTEMD_USER_DIR/" && cdr_log $(cdr_colorize $COL_GREEN "Linked $service")
		fi
	done
)
