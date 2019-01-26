##
##   Automatically backup router's config and upload it to FTP server(s)
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   created: 2014-03-09
##   updated: 2019-01-26
##   tested on: RouterOS 6.43.8 / multiple HW devices
##


########## Set variables

## Base filename
:local filename         "daily-backup-myroutername"

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

## Log to Slack
:local notifyViaSlack   true
:global SlackChannel    "#log"


########## Message to Slack

:if ($notifyViaSlack) do={
    :global SlackMessage "Creating configuration backup on router *$[/system identity get name]*";
    :global SlackMessageAttachements  "";
    /system script run "Message To Slack";
}


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


########## Message to Slack

:if ($notifyViaSlack) do={
    :global SlackMessage "Backup upload to FTP *$ftp1Address*";
    :global SlackMessageAttachements  "";
    /system script run "Message To Slack";
}


########## Upload to secondary FTP

:if ([:len $ftp2Address] != 0)  do={

    ## Upload to .backup to FTP 2
    /tool fetch address=$ftp2Address src-path="$filename.backup" user=$ftp2User  mode=ftp password=$ftp2Password dst-path=($ftp2Path . $filename . ".backup") upload=yes port=21

    ## Upload to .rsc to FTP 2
    /tool fetch address=$ftp2Address src-path="$filename.rsc" user=$ftp2User  mode=ftp password=$ftp2Password dst-path=($ftp2Path . $filename . ".rsc") upload=yes port=21

    :if ($notifyViaSlack) do={
        :global SlackMessage "Backup upload to FTP *$ftp2Address*";
        :global SlackMessageAttachements  "";
        /system script run "Message To Slack";
    }
}


## Log
:log info ("Configuration backup created on router $[/system identity get name].")


########## Message to Slack

:if ($notifyViaSlack) do={
    :global SlackMessage "Configuration backup on router *$[/system identity get name]* done";
    :global SlackMessageAttachements  "";
    /system script run "Message To Slack";
}
