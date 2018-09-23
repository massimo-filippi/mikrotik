##
##   Send a message to Slack on DHCP Bound
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   based on: http://jeremyhall.com.au/mikrotik-routeros-slack-messaging-hack/
##   created: 2018-09-23
##   updated: 2018-09-23
##
##  usage:
##  use this script as DHCP Lease Script
##


:global leaseBound
:global leaseServerName
:global leaseActMAC
:global leaseActIP


# Do the stuff on Bind

:if ($leaseBound = 1) do={
  /ip dhcp-server lease {
    :foreach i in [find dynamic address=$leaseActIP] do={

      :local hostName [/ip dhcp-server lease get $i host-name];

      :global SlackChannel "#my-channel"
      :global SlackMessage "New guest connected to *My wifi name*"
      :global SlackMessageAttachements "[{\"fields\": [{\"title\": \"Host name\",\"value\": \"$hostName\",\"short\": false},{\"title\": \"IP\",\"value\": \"$leaseActIP\",\"short\": false},{\"title\": \"MAC\",\"value\": \"$leaseActMAC\",\"short\": false}],\"color\": \"#F35A00\",\"mrkdwn_in\":[\"text\",\"pretext\"]}]";

      /system script run "Message To Slack";

    }
  }
}
