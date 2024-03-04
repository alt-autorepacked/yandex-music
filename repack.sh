#!/bin/sh

epm tool eget https://raw.githubusercontent.com/alt-autorepacked/common/v0.3.0/common.sh
. ./common.sh
# . ../common/common.sh

_package="yandex-music"
_repo="cucumber-sp/yandex-music-linux"
arch="$(epm print info --debian-arch)"
_suffix="*_$arch.deb"

_download() {
    url=$(epm tool eget --list --latest https://github.com/$_repo/releases "$_suffix")
    real_download_url=$(epm tool eget --get-real-url $url)
    epm -y repack $real_download_url
}

download_version=$(_check_version_from_github $_repo "$_suffix")
remote_version=$(_check_version_from_remote)

if [ "$remote_version" != "$download_version" ]; then
    _download
    _add_repo_suffix
    TAG="v$download_version"
    _create_release
    echo "Release created: $TAG"
else
    echo "No new version to release. Current version: $download_version"
fi

rm common.sh