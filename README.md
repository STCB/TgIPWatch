# TgIPWatch
Notifies a telegram group on IP change by pinning a message containing the NEW IP


Requirements:
 - Bot is an admin in the group with "Pin Messages" permission
 - jq is installed (for JSON parsing)

## How to use

- Burry the script in a safe path (clone the repo directly in the safe path)
- Create a new bot with the BotFather (https://t.me/BotFather) and place the associated token in the script dedicated var
- Get yourself a group or generate one, and get its group id (Hint: https://stackoverflow.com/questions/32423837/telegram-bot-how-to-get-a-group-chat-id) and put it in the script again
- Add the new bot into the group with admin perms (unless you don't want to pin the messages, then you'll have to edit the script)
- Set your log and ip file paths
- Add something like that in your prefered crontab: ``*/5 * * * * /yourpath/tgipwatch.sh`` (Will check IP changes every 5 minutes)

That's it !
You should get a new pinned message at every IP change.

## KNOWN BUG
When the server has internet problems, the IP file might be loaded with an error message comming from the ping result, and when back on the script will consider passing from an error message to its normal IP as a proper IP change, and pin a false message.
Please open a PR with changes if you want to fix that.

## Thanks

To ChatGPT for generating the script :)
