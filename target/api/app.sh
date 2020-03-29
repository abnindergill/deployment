
LISTEN_PORT="$1"
PATH="$2"

java --DServer.port="${LISTEN_PORT}" -jar "${PATH}"