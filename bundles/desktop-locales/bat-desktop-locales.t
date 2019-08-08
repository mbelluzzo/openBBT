#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

#
# Author      :   Victor Rodriguez
# Requirements:   bundle desktop-locales

TWD="/tmp/bundles/"

setup () {
  mkdir -p $TWD
  pushd $TWD
  curl -OL https://raw.githubusercontent.com/clearlinux/clr-bundles/master/bundles/desktop-locales
  sed -i '/^$/d;/^#/d' desktop-locales
  popd
}

teardown () {
  rm -rf $TWD
}

@test "bat-desktop-locales get validate content" {
STS=1
pushd $TWD
 while read line; do
 CurLine=$(echo "$line" | awk -F "-" '{print $NF}')
 case $CurLine in
  locales)
   Pack=$(echo "$line" | sed 's/-locales//')
   if [ "$Pack" = "gtk+" ];
    then
      Pack="gtk20"
   fi
   if [ "$Pack" = "iso-codes" ];
    then
      Pack="iso_"
   fi
    LocaleFiles=$(find /usr/share/locale/ -name "*$Pack*")
    if [ -z "$LocaleFiles" ];
    then
    echo $Pack"-locales is Not OK"
   STS=0
  fi
;;
doc)
 Pack=$(echo "$line" | sed 's/-doc//')
 if [ "$Pack" = "gtk+" ];
  then
    Pack="gtk-doc"
 fi
 if [ "$Pack" = "iso-codes" ];
  then
    Pack="iso_"
 fi
 if [ "$Pack" = "gnome-bluetooth" ];
  then
    Pack="bluetooth"
 fi
 DocFiles=$(find /usr/share/ -name "*$Pack*" ! -path "/usr/share/locale/*")
 if [ -z "$DocFiles" ];
 then
  echo $Pack"-doc is Not OK"
  STS=0
 fi
;;
*)
;;
esac
done < desktop-locales
popd
[ $STS -eq 1 ]
}
