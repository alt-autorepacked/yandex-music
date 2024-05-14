#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-music
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt 

electron_version=$(strings "$BUILDROOT/$PRODUCTDIR/electron/electron" | grep "Electron v" | awk '{print $2}' | cut -d'v' -f2 | cut -d'.' -f1)
add_unirequires "electron$electron_version"

remove_dir "$PRODUCTDIR/electron"

subst "s|/usr/lib/yandex-music|$PRODUCTDIR|g" "$BUILDROOT/usr/bin/yandex-music"
subst "s|$PRODUCTDIR/electron/electron|electron$electron_version|g" "$BUILDROOT/usr/bin/yandex-music"
