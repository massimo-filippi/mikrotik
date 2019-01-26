# MikrtoTik / RouterOS Scripts



## auto-upgrade.rsc

This script is for automatic upgrading of MikroTik routers.
In our environment, I have one MikroTik (at my home) scheduled to upgrade every night,
and all other routers scheduled to upgrade once per week. This is useful to catch possible
troubles on one router and not on all routers at the same time.

Auto-upgrade script will look for a new release in current-channel (production releases),
if there is a new version available, it upgrade itself. When there is no new Router OS available,
it checks for a new firmware - when available, it upgrades firmware.

### Installation

Using Winbox / Web admin (if you are familiar with command line, you already know how to do it :)
- Go to *System / Scripts, Add new*
- Name it, ie. "Auto Upgrade", select required policies (if you are lazy like me, select all boxes)
- Paste source code to *Source* field
- Replace :local email "your@email.com" with your own e-mail
- Save script
- Check, if your MikroTik is configured to send e-mail correctly
- Go to *System / Scheduler, Add New*
- Schedule script regarding your needs. *OnEvent* field should be something like this: */system script run "Auto Upgrade"*



## backup-config.rsc

This script backups your MikroTik's configuration and uploads it to FTP server (or optionally to two FTP servers).
Backup is saved in two different file formats:
- .backup is binary format, useful for restoring config to same hardware (model).
- .rsc is plain text format, useful for editing and possible restoring to a different MikroTik hardware.
Version number is attached to all files, so you always have latest backup from each RouterOS version.
This is very useful when you need to downgrade Router OS for some reason - you have latest working backup for each Router OS version.

### Installation

Using Winbox / Web admin (if you are familiar with command line, you already know how to do it :)
- Go to *System / Scripts, Add new*
- Name it, ie. "Backup Config", select required policies (if you are lazy like me, select all boxes)
- Paste source code to *Source* field
- Edit variables in section *Set variables* regarding your needs
- Save script
- Go to *System / Scheduler, Add New*
- Schedule script regarding your needs. *OnEvent* field should be something like this: */system script run "Backup Config"*
- Test it, your backup files should appear on your FTP(s) servers

Warning: FTP protocol is not encrypted, so all information is transmitted unencrypted! I don't care in my case,
because all data are pushed thru encrypted VPN channels, but the security can be improved here!



## message-to-slack.rsc

This script allow to send messages from RouterOS to Slack channel.
There is no way how to call webhooks from RouterOS, so it uses workaround using /tool fetch command.

### Installation

Slack
- Generate your API token here: https://api.slack.com/docs/oauth-test-tokens
- More information here: http://jeremyhall.com.au/mikrotik-routeros-slack-messaging-hack/

Using Winbox / Web admin (if you are familiar with command line, you already know how to do it :)
- Go to *System / Scripts, Add new*
- Name it, ie. "Message To Slack", select required policies (if you are lazy like me, select all boxes)
- Paste source code to *Source* field
- Edit variables *botname* and *token* in section *Set variables* regarding your needs
- Save script
- Call it from another scripts using:
```
:global SlackMessage "my message"
:global SlackChannel "my-channel"
/system script run "Message To Slack";
```



## dhcp-notify-slack.rsc

This script will send Slack message each time someone (or something) will get lease from your specific DHCP server - like when guest connects to Guests WiFi.

### Installation

Slack
- Generate your API token here: https://api.slack.com/docs/oauth-test-tokens
- More information here: http://jeremyhall.com.au/mikrotik-routeros-slack-messaging-hack/

Using Winbox / Web admin (if you are familiar with command line, you already know how to do it :)
- If not already done, install the *message-to-slack.rsc* script from this repository
- Go to *IP / DHCP Server*
- Click on DHCP server where you want notifications
- Paste source code to *Lease Script* field
- Edit variables *SlackChannel* and *SlackMessage* regarding your needs
- Save settings



Nice MikroTik'ing
Maxim Krušina, Massimo Filippi, s.r.o.
maxim@mfcc.cz
