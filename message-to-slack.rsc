##
##   Send message to Slack
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   based on: http://jeremyhall.com.au/mikrotik-routeros-slack-messaging-hack/
##   created: 2017-08-21
##   updated: 2017-08-21
##
##  usage:
##  generate your API token here: https://api.slack.com/docs/oauth-test-tokens
##  (more information here: http://jeremyhall.com.au/mikrotik-routeros-slack-messaging-hack/)
##  in another script, first setup global variable then call this script:
##
##  :global message "Test message"
##  /system script run message-to-slack;
##


:global message;
:global messageencoded "";

:local botname "MikroTik"
:local channel "%23test"
:local token "xoxp-your-token-here"
:local iconurl https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-12-08/16227284950_0c4cfc4b66e68c6273ad_48.jpg


#replace ASCII characters with URL encoded characters

:for i from=0 to=([:len $message] - 1) do={
  :local char [:pick $message $i]
  :if ($char = " ") do={
   :set $char "%20"
 }
  :if ($char = "-") do={
    :set $char "%2D"
  }
  :if ($char = "#") do={
    :set $char "%23"
  }
  :if ($char = "+") do={
    :set $char "%2B"
  }
  :set messageencoded ($messageencoded . $char)
}

/tool fetch url="https://slack.com/api/chat.postMessage?token=$token&channel=$channel&text=$messageencoded&icon_url=$iconurl&as_user=false&username=$botname";
