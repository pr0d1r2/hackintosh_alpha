#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`

umask 077
export SBUSERNAME=`whoami`
export SBUID=$(id -u $SBUSERNAME)
export SBGID=$(id -g $SBUSERNAME)
echo Username $SBUSERNAME - UserID $SBUID GroupID $SBGID

case $1 in
  [1-9]g | [1-9][0-9]g | [1-9][0-9][0-9]g | [1-9][0-9][0-9][0-9]g)
    VAULT_SIZE="$1"
    ;;
esac

case $VAULT_SIZE in
  "")
    echo "Please give vault size in gigabytes:"
    read VAULT_SIZE_INPUT
    VAULT_SIZE="${VAULT_SIZE_INPUT}g"
    ;;
esac

case $VAULT_SIZE in
  [1-9]g | [1-9][0-9]g | [1-9][0-9][0-9]g | [1-9][0-9][0-9][0-9]g)
    ;;
  *)
    echo "Invalid vault size. Aborting."
    exit 1
    ;;
esac

cd $HOME

echo
echo "Please use same password as you have for login."
echo

if [ ! -f "$SBUSERNAME".sparsebundle ]; then
  hdiutil create \
    -size $VAULT_SIZE \
    -encryption -agentpass \
    -uid $SBUID -gid $SBGID \
    -mode 0700 -fs "HFS+J" -type SPARSEBUNDLE -layout SPUD \
    -volname "$SBUSERNAME" "$SBUSERNAME".sparsebundle || exit $?
else
  echo "Vault already exist: $SBUSERNAME.sparsebundle"
  exit 8472
fi

chown -R "$SBUSERNAME":staff "$SBUSERNAME".sparsebundle || exit $?

mkdir sbdest || exit $?
hdiutil attach \
  -owners on -mountpoint sbdest \
  -stdinpass "$SBUSERNAME".sparsebundle || exit $?

rsync -avxHE ./ sbdest/ \
  --exclude="$SBUSERNAME".sparsebundle/ --exclude="sbdest/" || exit $?

hdiutil detach sbdest || exit $?
rmdir sbdest || exit $?

USER_PLIST="/private/var/db/dslocal/nodes/Default/users/$SBUSERNAME.plist"
sudo cp "$USER_PLIST" \
  "$USER_PLIST.backup-`date "+%Y-%m-%d--%H-%M-%S"`" || exit $?
sudo plutil -convert xml1 "$USER_PLIST" || exit $?
cat $D_R/setup_filevault_legacy.diff | \
  sed -e "s/SBUSERNAME/$SBUSERNAME/g" | \
  sudo patch $USER_PLIST || exit $?
sudo plutil -convert binary1 "$USER_PLIST" || exit $?

echo
echo "Now:"
echo "- log out"
echo "- log in"
echo "- log out"
echo
echo "If you see 'Recovering disk space ...' message you are done"
echo
