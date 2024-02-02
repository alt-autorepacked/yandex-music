#!/bin/sh

. /etc/os-release

ORG_NAME=alt-autorepacked
BASE_REMOTE_URL=https://github.com/$ORG_NAME

_get_suffix() {
    if [ -n "$ALT_BRANCH_ID" ]; then
        suffix=".$ALT_BRANCH_ID"
    else
        suffix=".$(epm print info -r)"
    fi
    echo ".$(epm print info -a)$suffix.rpm"
}

_check_version_from_remote() {
    suffix="*$(_get_suffix)"
    url=$(epm --quiet tool eget -q --list --latest $BASE_REMOTE_URL/$_package/releases "$suffix")
    filename="${url##*/}"
    version=$(echo $filename | grep -oP '\K[0-9]+\.[0-9]+\.[0-9]+')
    echo $version
}

_check_version_from_download() {
    search="*$(_get_suffix)"
    echo $(rpm -qp --queryformat '%{VERSION}' $search)
}

_add_repo_suffix() {
    if [ -n "$ALT_BRANCH_ID" ]; then
        suffix=".$ALT_BRANCH_ID"
    else
        suffix=".$(epm print info -r)"
    fi
    for file in *.rpm; do
        if [ ! -f "$file" ]; then
            continue
        fi
        base="${file%.rpm}"
        new_filename="${base}${suffix}.rpm"
        mv "$file" "$new_filename"
    done
}

_create_release() {
    suffix="*$(_get_suffix)"
    gh release create $TAG -R $ORG_NAME/$_package --notes "[CI] automatic release"
    gh release upload $TAG -R $ORG_NAME/$_package $suffix
}

_version_grep="\d+\.\d+\.\d+"

_get_version_from_download_url() {
    url=$(epm tool eget --get-real-url $_download_url)
    echo $url | grep -oP '\d+\.\d+\.\d+' | head -n 1
}

_check_version_from_github() {
    _repo=$1
    _suffix=$2
    _version_grep=${3:-"\d+\.\d+\.\d+"}
    url=$(epm tool eget --list --latest https://github.com/$_repo/releases "$_suffix")    
    echo $url | grep -oP $_version_grep | head -n 1
}