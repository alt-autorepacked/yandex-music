#!/bin/sh

COMMON_VERSION="0.4.0"

epm tool eget https://raw.githubusercontent.com/alt-autorepacked/common/v$COMMON_VERSION/common.sh
. ./common.sh
rm common.sh
# . ../common/common.sh

_package="yandex-music"

# epm install asar --auto
# cp yandex-music.sh /etc/eepm/repack.d/yandex-music.sh

arch="$(epm print info --debian-arch)"

GITHUB_REPO="cucumber-sp/yandex-music-linux"
GITHUB_SUFFIX="*_$arch.deb"

download_version=$(_check_version_from_github)
remote_version=$(_check_version_from_remote)

if [ "$remote_version" != "$download_version" ]; then
    _download_from_github
    _add_repo_suffix
    TAG="v$download_version"
    _create_release
    echo "Release created: $TAG"
else
    echo "No new version to release. Current version: $download_version"
fi
