##
##   Send message to Slack
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   based on: http://jeremyhall.com.au/mikrotik-routeros-slack-messaging-hack/
##   created: 2017-08-21
##   updated: 2018-09-22
##
##  usage:
##  in another script, first setup global variable then call this script:
##
##  :global SlackMessage "my message"
##  :global SlackChannel "#my-channel"
##  :global SlackMessageAttachements "url encoded attachements or empty string for none"
##  /system script run MessageToSlack;
##
##  PS: unfortunately, right now there is no better way to pass script parameters than via global variables
##


:global SlackChannel;
:global SlackMessage;
:global SlackMessageAttachements;

:local botname [/system identity get name];
:local token "xoxp-your-token-here"
:local iconurl https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-12-08/16227284950_0c4cfc4b66e68c6273ad_48.jpg


## Replace ASCII characters with URL encoded characters
## Call this function:  $urlEncode "string to encode"

:global urlEncode do={

  :local string $1;
  :local stringEncoded "";

  :for i from=0 to=([:len $string] - 1) do={
    :local char [:pick $string $i]
    :if ($char = " ")  do={ :set $char "%20" }
    :if ($char = "\"") do={ :set $char "%22" }
    :if ($char = "#")  do={ :set $char "%23" }
    :if ($char = "\$") do={ :set $char "%24" }
    :if ($char = "%")  do={ :set $char "%25" }
    :if ($char = "&")  do={ :set $char "%26" }
    :if ($char = "+")  do={ :set $char "%2B" }
    :if ($char = ",")  do={ :set $char "%2C" }
    :if ($char = "-")  do={ :set $char "%2D" }
    :if ($char = ":")  do={ :set $char "%3A" }
    :if ($char = "[")  do={ :set $char "%5B" }
    :if ($char = "]")  do={ :set $char "%5D" }
    :if ($char = "{")  do={ :set $char "%7B" }
    :if ($char = "}")  do={ :set $char "%7D" }
    :set stringEncoded ($stringEncoded . $char)
  }
  :return $stringEncoded;
}

:local channel [$urlEncode $SlackChannel];
:local message [$urlEncode $SlackMessage];
:local attachements [$urlEncode $SlackMessageAttachements];


## Send the message to Slack

/tool fetch url="https://slack.com/api/chat.postMessage?token=$token&channel=$channel&text=$message&icon_url=$iconurl&as_user=false&username=$botname&attachments=$SlackMessageAttachements";
