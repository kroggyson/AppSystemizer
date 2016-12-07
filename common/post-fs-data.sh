#!/system/bin/sh
MODDIR=${0%/*}

STOREDLIST=${MODDIR}/extras/appslist.conf
#STOREDLIST=/data/data/net.loserskater.appsystemizer/appslist.conf

apps=(
"com.google.android.apps.nexuslauncher,NexusLauncherPrebuilt,priv-app,1"
"com.google.android.apps.wallpaper,WallpaperPickerGooglePrebuilt,app,1"
"com.google.android.apps.tycho,Tycho,app,1"
)

LOGFILE=/cache/magisk.log
log_print() {
  echo $1
  echo "AppSys: $1" >> $LOGFILE
  log -p i -t AppSys "$1"
}

[ -s $STOREDLIST ] && eval apps="($(<${STOREDLIST}))" && log_print "Loaded apps list from $STOREDLIST."  || log_print "Failed to load apps list from $STOREDLIST."

for line in "${apps[@]}"; do 
  IFS=',' read canonical name path status <<< $line
  [ -z "$canonical" ] && continue
  [ -z "$path" ] && path='priv-app'
  if [ "$status" = "1" -a "$(echo /data/app/${canonical}-*)" != "/data/app/${canonical}-*" ]; then
  	if [[ ( ( -n "$name" && ! -d /system/${path}/${name} ) || ( -z "$name" && ! -f /system/${path}/${canonical}.apk ) ) && \
  	( ( -n "$name" && ! -d ${MODDIR}/system/${path}/${name} ) || ( -z "$name" && ! -f ${MODDIR}/system/${path}/${canonical}.apk ) ) ]]; then
    	for i in /data/app/${canonical}-*/base.apk; do
	      if [ "$i" != "/data/app/${canonical}-*/base.apk" ]; then
	      	[ -n "$name" ] && newname="${name}/${name}" || newname="${canonical}"
	      	mkdir -p ${MODDIR}/system/${path}/${name} 2>/dev/null
	      	cp -f $i ${MODDIR}/system/${path}/${newname}.apk && log_print "Copy ${MODDIR}/${path}/${newname}.apk" || log_print "Copy Fail: $i ${MODDIR}/system/${path}/${newname}.apk"
	      	chown 0:0 ${MODDIR}/system/${path}/${name}
	      	chmod 0755 ${MODDIR}/system/${path}/${name}
	      	chown 0:0 ${MODDIR}/system/${path}/${newname}.apk
	      	chmod 0644 ${MODDIR}/system/${path}/${newname}.apk
	      fi
    	done
  	fi
  fi
  if [ "$status" != "1" -a "$(echo /data/app/${canonical}-*)" != "/data/app/${canonical}-*" ]; then
  	[ -n "$name" -a -d ${MODDIR}/system/${path}/${name} ] && rm -rf ${MODDIR}/system/${path}/${name} && log_print "Unsystemizing $name."
  	[ -z "$name" -a -f ${MODDIR}/system/${path}/${canonical}.apk ] && rm -rf ${MODDIR}/system/${path}/${name} && log_print "Unsystemizing $canonical.apk."
  fi
done
