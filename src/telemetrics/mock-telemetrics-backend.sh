#!/usr/bin/sh

#
# Mock HTTP server to remove the need for a telemetrics
# backend server.
#

PORT=8080

socat -v TCP-LISTEN:${PORT},crlf,reuseaddr,fork SYSTEM:"
echo HTTP/1.1 200 OK;
echo Content-Type\: text/plain;
echo;
echo \"Server: \$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\";
echo \"Client: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\";
"
