##
##   Automatically upgrade RouterOS and Firmware
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   based on: http://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS
##   created: 2014-12-05
##   updated: 2019-01-26
##   tested on: RouterOS 6.43.8 / multiple HW devices
##


########## Set variables

## Update channel can take values before 6.43.8: bugfix    | current | development | release-candidate
## Update channel can take values after  6.43.8: long-term | stable  | development | testing
:local updChannel       "stable"

## Notify via Slack
:local notifyViaSlack   true
:global SlackChannel    "#log"

## Notify via E-mail
:local notifyViaMail    true
:local email            "your@email.com"


########## Upgrade firmware

## Let's check for updated firmware

:local rebootRequired false
/system routerboard

:if ( [get current-firmware] != [get upgrade-firmware]) do={

   ## New version of firmware available, let's upgrade

   ## Notify via Log
   :log info ("Upgrading firmware on router $[/system identity get name] from $[/system routerboard get current-firmware] to $[/system routerboard get upgrade-firmware]")

   ## Notify via Slack
   :if ($notifyViaSlack) do={
       :global SlackMessage "Upgrading firmware on router *$[/system identity get name]* from $[/system routerboard get current-firmware] to *$[/system routerboard get upgrade-firmware]*";
       :global SlackMessageAttachements  "";
       /system script run "Message To Slack";
   }

   ## Notify via E-mail
   :if ($notifyViaMail) do={
       /tool e-mail send to="$email" subject="Upgrading firmware on router $[/system identity get name]" body="Upgrading firmware on router $[/system identity get name] from $[/system routerboard get current-firmware] to $[/system routerboard get upgrade-firmware]"
   }

   ## Upgrade (it will no reboot, we'll do it later)
   upgrade
   :set rebootRequired true

}


########## Upgrade RouterOS

## Check for update
/system package update
set channel=$updChannel
check-for-updates

## Wait on slow connections
:delay 15s;

## Important note: "installed-version" was "current-version" on older Roter OSes
:if ([get installed-version] != [get latest-version]) do={

   ## Notify via Log
   :log info ("Upgrading RouterOS on router $[/system identity get name] from $[/system package update get installed-version] to $[/system package update get latest-version] (channel:$[/system package update get channel])")

   ## Notify via Slack
   :if ($notifyViaSlack) do={
       :global SlackMessage "Upgrading RouterOS on router *$[/system identity get name]* from $[/system package update get installed-version] to *$[/system package update get latest-version] (channel:$[/system package update get channel])*";
       :global SlackMessageAttachements  "";
       /system script run "Message To Slack";
   }

   ## Notify via E-mail
   :if ($notifyViaMail) do={
       /tool e-mail send to="$email" subject="Upgrading RouterOS on router $[/system identity get name]" body="Upgrading RouterOS on router $[/system identity get name] from $[/system package update get installed-version] to $[/system package update get latest-version] (channel:$[/system package update get channel])"
   }

   ## Wait for mail to be sent & upgrade
   :delay 15s;
   install

} else={

    :if ($rebootRequired) do={
        # Firmware was upgraded, but not RouterOS, so we need to reboot to finish firmware upgrade

        ## Notify via Slack
        :if ($notifyViaSlack) do={
            :global SlackMessage "Rebooting...";
            :global SlackMessageAttachements  "";
            /system script run "Message To Slack";
        }

        /system reboot

    } else={

        # No firmware nor RouterOS upgrade available, nothing to do, just log info
        :log info ("No firmware nor RouterOS upgrade found.")

        ## Notify via Slack
        :if ($notifyViaSlack) do={
            :global SlackMessage "No firmware nor RouterOS upgrade found.";
            :global SlackMessageAttachements  "";
            /system script run "Message To Slack";
        }
    }
}
