on is_running(processName)
	tell application "System Events" to (name of processes) contains processName
end is_running

set appName to ("Sonos")

tell application appName to quit

repeat 100 times -- max 10 seconds loop
	delay 0.1
	if is_running(appName) is false then
		tell application appName to activate
		exit repeat
	end if
end repeat