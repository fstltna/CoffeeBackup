#!/usr/bin/perl

# Set these for your situation
my $MTDIR = "/home/cmowner/CoffeeMud";
my $BACKUPDIR = "/home/cmowner/backups";
my $SQLDUMPDIR = "$BACKUPDIR/sqldump/";
my $TARCMD = "/bin/tar czf";
my $SQLDUMPCMD = "/usr/bin/mysqldump";
my $VERSION = "1.3";
my $OPTION_FILE = "/home/cmowner/.cmbackuprc";

my $MYSQLUSER = "";
my $MYSQLPSWD = "";

# Get if they said a option
my $CMDOPTION = shift;

sub ReadPrefs
{
	my $LineCount = 0;
	open(my $fh, '<:encoding(UTF-8)', $OPTION_FILE)
		or die "Could not open file '$OPTION_FILE' $!";

	while (my $row = <$fh>)
	{
		chomp $row;
		if ($LineCount == 0)
		{
			$MYSQLUSER = $row;
		}
		if ($LineCount == 1)
		{
			$MYSQLPSWD = $row;
		}
		$LineCount += 1;
	}
	close($fh);
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
}

if (defined $CMDOPTION)
{
	if ($CMDOPTION ne "-snapshot")
	{
		print "Unknown command line option: '$CMDOPTION'\nOnly allowed option is '-snapshot'\n";
		exit 0;
	}
	print "CoffeeBackup.pl version $VERSION\n";
	print "Running Manual Snapshot\n";
	print "========================\n";
	if (! -f $OPTION_FILE)
	{
		print "Unable to open '$OPTION_FILE'. Please create it with your mysql data in this format:\n";
		print "First line - mysql user\nSecond line = mysql-password\n";
		print "--- Press Enter To Continue: ";
		my $entered = <STDIN>;
		exit 0;
	}
	print "Backing up java files: ";
	if (-f "$BACKUPDIR/snapshot.tgz")
	{
		unlink("$BACKUPDIR/snapshot.tgz");
	}
	system("$TARCMD $BACKUPDIR/snapshot.tgz $MTDIR > /dev/null 2>\&1");
	print "\nBackup Completed.\nBacking up MYSQL data: ";
	if (-f "$SQLDUMPDIR/snapshot.sql")
	{
		unlink("$SQLDUMPDIR/snapshot.sql");
	}
	ReadPrefs();
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
	system("$SQLDUMPCMD  --user=$MYSQLUSER --password=$MYSQLPSWD --result-file=$SQLDUMPDIR/snapshot.sql coffeemud");

	print "\n";
	print "--- Press Enter To Continue: ";
	my $entered = <STDIN>;
	exit 0;
}

#-------------------
# No changes below here...
#-------------------

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
	unlink("$SQLDUMPDIR/coffeemud.sql-5.gz")  or warn "Could not unlink $SQLDUMPDIR/coffeemud.sql-5.gz: $!";
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
