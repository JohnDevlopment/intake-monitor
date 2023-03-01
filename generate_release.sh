#!/bin/sh

PROJECTNAME=intake-monitor

onquit() {
    rm $tmp
    test $clear && {
        clear
        echo cleared
    }
    echo done
}

dlg="dialog --clear --title `basename $0`"

version=
prerelease=
arch=
clear=`false`

# Open temp file
tmp=$(mktemp)

# Call onquit on exit
trap onquit EXIT

# Get version
$dlg --inputbox "Version Number:" 5 10 2> $tmp

if [ $? -eq 1 ]; then
    # cancel
    clear=`true`
    echo 'aborted'
    exit
fi

version=`cat $tmp`

# Prerelease
$dlg --yesno "Is this a prerelease?" 5 50

if [ $? -eq 0 ]; then
    # yes
    $dlg --inputbox "Prerelase Name:" 5 10 2> $tmp
    prerelease=`cat $tmp`
    prerelease="-$prerelease"
fi

# Arch
$dlg --menu "Choose Arch:" 15 40 10 linux "Linux/X11" windows "Windows Desktop" html5 "HTML5" 2> $tmp

if [ $? -eq 1 ]; then
    # cancel
    clear=`true`
    echo 'aborted'
    exit
fi

arch=`cat $tmp`

# Dialogs are done, so clear the screen
clear

# Remove temp file
rm $tmp

zipfile="${PROJECTNAME}-v$version${prerelease}_$arch.zip"
srcdir="$PWD"

# Make temp directory and delete it after exit
tdir=$(mktemp -d)
trap "rm -f -r $tdir" EXIT

on_error() {
    rm -f -r $tdir
    exit 1
}
set -e

# Make directory if it doesn't exist
mkdir -p "$srcdir/releases"

# Make archive and move it to the 'releases' directory
cp bin/$arch/* $tdir/
cd $tdir
zip --no-dir-entries -T $zipfile *
mv -v $zipfile "$srcdir/releases/"
