##
##   Automatically Upgrade RouterOS and Firmware
##   script by Maxim Krusina, maxim@mfcc.cz
##   based on: http://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS
##   created: 2014-12-05
##   updated: 2014-12-13
##

/system package update
check-for-updates

## Waint on slow connections
:delay 15s;

:if ( [get current-version] != [get latest-version]) do={ 

   ## New version of RouterOS available, let's upgrade

   /tool e-mail send to="maxim@mfcc.cz" subject="Upgrading RouterOS on router $[/system identity get name]" body="Upgrading RouterOS on router $[/system identity get name] from $[/system package update get current-version] to $[/system package update get latest-version]"

   ## Wait for mail to be send
   :delay 15s;
   upgrade

} else={

   ## RouterOS latest, let's check for updated firmware

   /system routerboard

   :if ( [get current-firmware] != [get upgrade-firmware]) do={ 

      ## New version of firmware available, let's upgrade

      /tool e-mail send to="maxim@mfcc.cz" subject="Upgrading firmware on router $[/system identity get name]" body="Upgrading firmware on router $[/system identity get name] from $[/system routerboard get current-firmware] to $[/system routerboard get upgrade-firmware]"

      ## Wait for mail to be send
      :delay 15s;
      upgrade

      ## Wait for upgrade, then reboot
      :delay 180s;
      /system reboot

   }
}
