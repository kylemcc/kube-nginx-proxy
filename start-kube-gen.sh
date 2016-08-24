#!/bin/bash

set -e
sleep 1
kube-gen -watch -type pods -type services -wait 2s:10s -post-cmd 'nginx -s reload' /app/sites.tmpl /etc/nginx/conf.d/sites.conf
