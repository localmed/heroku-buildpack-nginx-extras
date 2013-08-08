#!/bin/bash

NGINX_URL='http://nginx.org/download/nginx-1.4.1.tar.gz'
NGINX_INCLUDES=(
"ipv6"
"http_addition_module"
"http_degradation_module"
"http_flv_module"
"http_gzip_static_module"
"http_mp4_module"
"http_random_index_module"
"http_realip_module"
"http_secure_link_module"
"http_ssl_module"
"http_stub_status_module"
"http_sub_module"
"http_dav_module"
"http_xslt_module"
"http_spdy_module"
)

NGINX_DEPENDENCIES=("pcre|https://s3.amazonaws.com/heroku-nginx-extras/pcre-8.33.tar.gz")

NGINX_MODULES=(
"https://s3.amazonaws.com/heroku-nginx-extras/ngx_devel_kit-0.2.18.tar.gz"
"https://s3.amazonaws.com/heroku-nginx-extras/ngx_http_auth_request_module-a29d74804ff1.tar.gz"
"https://s3.amazonaws.com/heroku-nginx-extras/set-misc-nginx-module-0.22rc8.tar.gz"
)
NGINX_CONTRIB_DIR="contrib"


function create_nginx_build_directory () {
    local nginx_dir="$(basename $NGINX_URL '.tar.gz')"
    local contrib_dir="$nginx_dir/$NGINX_CONTRIB_DIR"
    _get_file $NGINX_URL "./"
    
    for mod in "${NGINX_MODULES[@]}"; do
        _get_file $mod $contrib_dir
    done
    
    for dep in "${NGINX_DEPENDENCIES[@]}"; do
        local url="${dep##*|}"
        _get_file $url $contrib_dir
    done
    
    create_build_script "$nginx_dir/full_build.sh"
    echo "$nginx_dir"
}

function create_build_script () {
    local script_path="$1"
    local prefix='--prefix=$PREFIX_DIR'
    local includes="$(create_includes_config)"
    local dependencies="$(create_dependencies_config)"
    local modules="$(create_modules_config)"
    local configure_cmd="./configure $prefix $includes $dependencies $modules"
    
    cat >> $script_path <<EOF
PREFIX_DIR=$PREFIX_DIR
$configure_cmd
make
EOF
    chmod +x $script_path
}

function create_dependencies_config () {
    local deps=()
    for d in "${NGINX_DEPENDENCIES[@]}"; do
        local name="${d%%|*}"
        local url="${d##*|}"
        local dep_path="$NGINX_CONTRIB_DIR/$(basename $url '.tar.gz')"
        deps=("${deps[@]}" "--with-$name=$dep_path")
    done
    echo "${deps[*]}"
}

function create_includes_config () {
    local includes=$(printf -- "--with-%s "  "${NGINX_INCLUDES[@]}")
    echo "$includes"
}

function create_modules_config () {
    local modules=()
    for mod in "${NGINX_MODULES[@]}"; do
        local dep_path="$NGINX_CONTRIB_DIR/$(basename $mod '.tar.gz')"
        modules=("${modules[@]}" "--add-module=$dep_path")
    done
    echo "${modules[*]}"
}

function _get_file () {
    local url="$1"
    local dir="$2"
    
    wget -O - -P $dir $url | tar xzf - -C $dir 
}