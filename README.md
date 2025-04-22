# CoffeeBackup backup script for Coffee MUD (1.8.0)
Creates a backup of your Coffee MUD folder

Official support sites: [Official Github Repo](https://github.com/fstltna/CoffeeBackup) - [Official Forum](https://pocketmud.com/index.php/forum/server-utils)  - [Official Download Area](https://pocketmud.com/index.php/download-upload/category/4-servers)
![Coffee MUD Sample Screen](https://pocketmud.com/coffee_mud.png) 

---

1. Edit the settings at the top of coffeebackup.pl if needed
2. create a cron job like this:

        1 1 * * * /home/cmowner/CoffeeBackup/coffeebackup.pl

3. This will back up your Coffee MUD installation at 1:01am each day, and keep the last 5 backups.

4. Edit the backup config:
 	Run a manual backup and it will ask you for the mysql config info. If you need to reconfigure it use the "-prefs" command-line option

---

To set up offsite backups:

1. Make sure ssh-keygen is installed: "apt install ssh-keygen"
2. Run "ssh-keygen" and when asked for the password just press enter twice
3. Run "ssh-copy-id -i ~/.ssh/id_rsa.pub your-destination-server" - This will ask you for your remote password. This is normal.
4. Run "coffeebackup -prefs" and update the backup fields
5. Rerun the backup and it should try and upload the files to your remote site.

If you need more help visit https://PocketMUD.com/
