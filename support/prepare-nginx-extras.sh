#!/bin/bash

set -e

source ./nginx-prep.sh

function get_fresh_tempdir () {
    local tempdir="$(mktemp -t nginx_build_XXXX)"
    rm -rf $tempdir
    mkdir -p $tempdir
    echo "$tempdir"
}

pushd "$(get_fresh_tempdir)"

S3_BUCKET='heroku-nginx-extras'
PREFIX_DIR='/tmp/nginx'
NGINX_DIR="$(create_nginx_build_directory)"
NGINX_BUILD="$NGINX_DIR-heroku.tar.gz"

vulcan build -v -s $NGINX_DIR -o $NGINX_BUILD -p $PREFIX_DIR -c "./full_build.sh && make install"

# Requires s3cmd installed
s3cmd put --acl-public --rr $NGINX_BUILD s3://$S3_BUCKET

popd