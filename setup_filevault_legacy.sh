#!/bin/sh

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
