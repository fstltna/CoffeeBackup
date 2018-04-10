#!/usr/bin/perl

# Set these for your situation
my $MTDIR = "/home/marisag/CoffeeMud";
my $BACKUPDIR = "/home/marisag/backups";
my $TARCMD = "/bin/tar czf";

#-------------------
# No changes below here...
#-------------------
my $VERSION = "1.0";

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
print("Done!\n");
exit 0;
