# CoffeeBackup backup script for Coffee MUD (1.1)
Creates a backup of your Coffee MUD folder

Official support sites: [Official Github Repo](https://github.com/fstltna/CoffeeBackup) - [Official Forum](https://pocketmud.com/index.php/forum/server-utils)  - [Official Download Area](https://pocketmud.com/index.php/download-upload/category/4-servers)
![Coffee MUD Sample Screen](https://pocketmud.com/coffee_mud.png) 

---

1. Edit the settings at the top of minebackup.pl if needed
2. create a cron job like this:

        1 1 * * * /root/CoffeeBackup/coffeebackup.pl

3. This will back up your Coffee MUD installation at 1:01am each day, and keep the last 5 backups.

4. This assumes that backupninja is storing the daily backups to /root/backups and it rotates those sql dumps as well.

If you need more help visit https://PocketMUD.com/
