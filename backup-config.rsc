##
##   Automatically backup router's config and upload it to FTP server(s)
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   created: 2014-03-09
##   updated: 2015-12-05
##   tested on: RouterOS 6.33.1 / multiple HW devices
##


########## Set variables

## Base filename
:local filename "daily-backup-myroutername"

## FTP server 1 for upload
:local ftp1Address      "ftp-1-hostname"
:local ftp1User         "ftp-1-username"
:local ftp1Password     "ftp-1-password"
:local ftp1Path         "ftp-1-path"

## FTP server 2 for upload - if second server is not used, just comment lines bellow 
:local ftp2Address      "ftp-2-hostname"
:local ftp2User         "ftp-2-username"
:local ftp2Password     "ftp-2-password"
:local ftp2Path         "ftp-2-path"


########## Do the stuff

## Get currrent RouterOS version
:local myVer [/system package update get installed-version];

## Append version number to filename (to not overwrite backups from older RouterOS versions)
:set filename ($filename . "-" . $myVer);

## Backup & Export config to local file
/system backup save name="$filename"
/export file="$filename"

## Upload to .backup to FTP 1
/tool fetch address=$ftp1Address src-path="$filename.backup" user=$ftp1User  mode=ftp password=$ftp1Password dst-path=($ftp1Path . $filename . ".backup") upload=yes port=21

## Upload to .rsc to FTP 1
/tool fetch address=$ftp1Address src-path="$filename.rsc" user=$ftp1User  mode=ftp password=$ftp1Password dst-path=($ftp1Path . $filename . ".rsc") upload=yes port=21


:if ([:len $ftp2Address] != 0)  do={

## Upload to .backup to FTP 2
/tool fetch address=$ftp2Address src-path="$filename.backup" user=$ftp2User  mode=ftp password=$ftp2Password dst-path=($ftp2Path . $filename . ".backup") upload=yes port=21

## Upload to .rsc to FTP 2
/tool fetch address=$ftp2Address src-path="$filename.rsc" user=$ftp2User  mode=ftp password=$ftp2Password dst-path=($ftp2Path . $filename . ".rsc") upload=yes port=21

}


## Log
:log info ("Configuration backup created on router $[/system identity get name].")     