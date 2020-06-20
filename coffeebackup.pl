#!/usr/bin/perl

# Set these for your situation
my $MTDIR = "/home/cmowner/CoffeeMud";
my $BACKUPDIR = "/home/cmowner/backups";
my $SQLDUMPDIR = "$BACKUPDIR/sqldump/";
my $TARCMD = "/bin/tar czf";

#-------------------
# No changes below here...
#-------------------
my $VERSION = "1.2";

print "CoffeeBackup.pl version $VERSION\n";
print "========================\n";
if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/coffeebackup-5.tgz")
{
	unlink("$BACKUPDIR/coffeebackup-5.tgz")  or warn "Could not unlink $BACKUPDIR/coffeebackup-5.tgz: $!";
}
if (-f "$BACKUPDIR/coffeebackup-4.tgz")
{
	rename("$BACKUPDIR/coffeebackup-4.tgz", "$BACKUPDIR/coffeebackup-5.tgz");
}
if (-f "$BACKUPDIR/coffeebackup-3.tgz")
{
	rename("$BACKUPDIR/coffeebackup-3.tgz", "$BACKUPDIR/coffeebackup-4.tgz");
}
if (-f "$BACKUPDIR/coffeebackup-2.tgz")
{
	rename("$BACKUPDIR/coffeebackup-2.tgz", "$BACKUPDIR/coffeebackup-3.tgz");
}
if (-f "$BACKUPDIR/coffeebackup-1.tgz")
{
	rename("$BACKUPDIR/coffeebackup-1.tgz", "$BACKUPDIR/coffeebackup-2.tgz");
}
print "Done\nCreating New Backup: ";
system("$TARCMD $BACKUPDIR/coffeebackup-1.tgz $MTDIR");
print "Done\nMoving Existing MySQL data: ";
if (-f "$SQLDUMPDIR/coffeemud.sql-5.gz")
{
	unlink("$SQLDUMPDIR/coffeemud.sql-5.gz")  or warn "Could not unlink $SQLDUMPDIR/coffeeimud.sql-5.gz: $!";
}
if (-f "$SQLDUMPDIR/coffeemud.sql-4.gz")
{
	rename("$SQLDUMPDIR/coffeemud.sql-4.gz", "$SQLDUMPDIR/coffeemud.sql-5.gz");
}
if (-f "$SQLDUMPDIR/coffeemud.sql-3.gz")
{
	rename("$SQLDUMPDIR/coffeemud.sql-3.gz", "$SQLDUMPDIR/coffeemud.sql-4.gz");
}
if (-f "$SQLDUMPDIR/coffeemud.sql-2.gz")
{
	rename("$SQLDUMPDIR/coffeemud.sql-2.gz", "$SQLDUMPDIR/coffeemud.sql-3.gz");
}
if (-f "$SQLDUMPDIR/coffeemud.sql-1.gz")
{
	rename("$SQLDUMPDIR/coffeemud.sql-1.gz", "$SQLDUMPDIR/coffeemud.sql-2.gz");
}
if (-f "$SQLDUMPDIR/coffeemud.sql.gz")
{
	rename("$SQLDUMPDIR/coffeemud.sql.gz", "$SQLDUMPDIR/coffeemud.sql-1.gz");
}
print("Done!\n");
exit 0;
