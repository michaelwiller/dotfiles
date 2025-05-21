if [ -d /Applications/Wave.app ]; then
    wsh_cmd="~/Library/Application\ Support/waveterm/bin/wsh"
    alias v="$wsh_cmd edit"
    #alias wae="$wsh_cmd edit"
    #alias wap="$wsh_cmd view"
    #alias waw="$wsh_cmd web open"
    #alias wa='echo "wae (edit), wap (preview), waw (open URL)"'
fi