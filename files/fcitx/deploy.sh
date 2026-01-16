state_file="$CACHE_HOME/rime_deploy_state"
current_config_path="$CONFIG_SOURCE"
previous_config_path=$(cat "$state_file" 2>/dev/null || echo "")
RIME_DIR="$DATA_HOME/fcitx5/rime"

if [[ "$current_config_path" != "$previous_config_path" ]]; then
	mkdir -p "$RIME_DIR"
	rm -rf "$RIME_DIR/build"

	echo "Deploying Rime data..."
	"$LIBRIME_BIN" --build "$RIME_DIR" "$RIME_ICE_PATH" "$RIME_DIR/build" || echo "Warning: Rime deployer finished with errors..."

	echo "$current_config_path" >"$state_file"

	if "$PGREP_BIN" -x fcitx5 >/dev/null; then
		echo "Reloading Fcitx5..."
		"$FCITX_REMOTE_BIN" -r || echo "Warning: Failed to reload Fcitx5..."
	fi
fi