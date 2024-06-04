#!/bin/sh
# Docker entrypoint (pid 1), run as root
[ "$1" = "redis-server" ] || exec "$@" || exit $?

# Make sure that database is owned by user redis
[ "$(stat -c %U /data)" = redis ] || chown -R redis /data

# Drop root privilege (no way back), exec provided command as user redis
cmd=exec; for i; do cmd="$cmd '$i'"; done
#exec su - redis /bin/sh -c "$cmd"
exec su - redis /bin/sh -c "$cmd"
