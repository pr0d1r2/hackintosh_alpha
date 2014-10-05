#!/bin/sh

REPO="https://raw.githubusercontent.com/pr0d1r2/hackintosh_alpha"
NAME="setup_filevault_legacy"

cd ~/Downloads

curl $REPO/master/$NAME.diff -o $NAME.diff || exit $?
curl $REPO/master/$NAME.sh -o $NAME.sh || exit $?
sh $NAME.sh || exit $?
