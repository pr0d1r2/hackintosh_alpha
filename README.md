# hackintosh_alpha

Documentation and tools useful when building Hackintoshes.

## Setup legacy FileVault

```
curl https://raw.githubusercontent.com/pr0d1r2/hackintosh_alpha/master/setup_filevault_legacy_snippet.sh > setup_filevault_legacy_snippet.sh && sh setup_filevault_legacy_snippet.sh
```

## Fix Bluetooth audio lag

You do that simply by restarting core audio daemon (see: http://www.reddit.com/r/osx/comments/2ppk47/fix_bluetooth_audio_lag_or_volume_issues_in_osx/):
```
sudo killall coreaudiod
```

To simplify that do:
```
sudo visudo
```

Add this line at end:
```
YourUserName ALL=NOPASSWD:/usr/bin/killall coreaudiod
```

Then create automator application with `sudo killall coreaudiod` following steps in http://stackoverflow.com/questions/281372/executing-shell-scripts-from-the-os-x-dock

Then add this application to your dock (or where you like).
