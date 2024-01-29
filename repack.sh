#!/bin/sh

epm tool eget https://raw.githubusercontent.com/alt-autorepacked/common/v0.3.0/common.sh
. ./common.sh
# . ../common/common.sh

_package="yandex-music"

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    armhf)
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

_download() {
    _repo="cucumber-sp/yandex-music-linux"
    _suffix="*.$arch.rpm"
    url=$(epm tool eget --list --latest https://github.com/$_repo/releases "$_suffix")
    real_download_url=$(epm tool eget --get-real-url $url)
    epm -y repack $real_download_url
    for file in YandexMusic*.rpm; do
        newname=$(echo "$file" | sed 's/YandexMusic/yandex-music/')
        mv "$file" "$newname"
    done
}

download_version=$(_check_version_from_github "cucumber-sp/yandex-music-linux" "*.$arch.rpm")
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