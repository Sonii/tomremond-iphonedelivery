#!/bin/sh
IDLIB=/usr/local/lib/libidcc.dylib
PLIST=/System/Library/LaunchDaemons/com.apple.CommCenterClassic.plist 
PLIST1=/tmp/com.apple.CommCenterClassic.plist 

launchctl unload  $PLIST

MODE=$(plutil -key ms-mode /var/mobile/Library/Preferences/com.guilleme.deliveryreports.plist)
if [ -z "$MODE" ]; then
MODE=1
fi

cp $PLIST $PLIST1
LIBRARY=$(plutil -key EnvironmentVariables -key DYLD_INSERT_LIBRARIES $PLIST1 2> /dev/null)

LIBRARY=$(echo $LIBRARY | sed -e "s#${IDLIB}##")
LIBRARY=$(echo $LIBRARY | sed -e 's/^://' -e 's/::/:/' -e "s/:\$//")

if [ "$MODE" -eq "0" ]; then
if [ -n "$LIBRARY" ]; then
	LIBRARY="$LIBRARY:"
fi
LIBRARY="$LIBRARY$IDLIB"
fi
plutil -key EnvironmentVariables -dict $PLIST1 > /dev/null
plutil -key EnvironmentVariables -key DYLD_INSERT_LIBRARIES -setValue $LIBRARY $PLIST1 > /dev/null
if [ -s $PLIST1 ]; then cp $PLIST1 $PLIST; fi
launchctl load $PLIST
