#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Application server - basic test
# -----------------
#
# Author      :   Salvador Teran
#
# Requirements:   bundle application-server
#

WEB_ROOT="/var/www"

@test "copy and update httpd configuration" {
    cp -r /usr/share/defaults/httpd/ /etc/
    cat > /etc/httpd/conf.modules.d/helloworld.conf << EOF
WSGIScriptAlias /helloworld /var/www/wsgi-scripts/helloworld.wsgi
<Directory /var/www/wsgi-scripts>
Require all granted
</Directory>
EOF
    mkdir -p ${WEB_ROOT}/wsgi-scripts
    cat > ${WEB_ROOT}/wsgi-scripts/helloworld.wsgi << EOF
def application(environ, start_response):
    status = '200 OK'
    output = b'Hello World!'

    response_headers = [('Content-type', 'text/plain'),
                        ('Content-Length', str(len(output)))]
    start_response(status, response_headers)

    return [output]
EOF
    chown -R httpd:httpd ${WEB_ROOT}
    chmod +x ${WEB_ROOT}/wsgi-scripts/helloworld.wsgi
    systemctl daemon-reload
    systemctl start httpd
    curl http://localhost/helloworld | grep "Hello World!"
}
