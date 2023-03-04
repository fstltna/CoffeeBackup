#!/usr/bin/perl

# Set these for your situation
my $MTDIR = "/home/cmowner/CoffeeMud";
my $BACKUPDIR = "/home/cmowner/backups";
my $TARCMD = "/bin/tar czf";
my $SQLDUMPCMD = "/usr/bin/mysqldump";
my $VERSION = "1.5.0";
my $OPTION_FILE = "/home/cmowner/.cmbackuprc";
my $LATESTFILE = "$BACKUPDIR/coffeemud.sql-1";
my $DOSNAPSHOT = 0;
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

sub DumpMysql
{
	my $DUMPFILE = $_[0];
	if (! -f $OPTION_FILE)
	{
		print "Unable to open '$OPTION_FILE'. Please create it with your mysql data in this format:\n";
		print "First line - mysql user\nSecond line = mysql-password\n";
		print "--- Press Enter To Continue: ";
		my $entered = <STDIN>;
		exit 0;
	}
	ReadPrefs();

	print "Backing up MYSQL data: ";
	if (-f "$DUMPFILE")
	{
		unlink("$DUMPFILE");
	}
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
	system("$SQLDUMPCMD  --user=$MYSQLUSER --password=$MYSQLPSWD --result-file=$DUMPFILE coffeemud");
	print "\n";
}

if (defined $CMDOPTION)
{
	if ($CMDOPTION ne "-snapshot")
	{
		print "Unknown command line option: '$CMDOPTION'\nOnly allowed option is '-snapshot'\n";
		exit 0;
	}
}

sub SnapShotFunc
{
	print "Backing up java files: ";
	if (-f "$BACKUPDIR/snapshot.tgz")
	{
		unlink("$BACKUPDIR/snapshot.tgz");
	}
	system("$TARCMD $BACKUPDIR/snapshot.tgz $MTDIR > /dev/null 2>\&1");
	print "\nBackup Completed.\nBacking up MYSQL data: ";
	if (-f "$BACKUPDIR/snapshot.sql")
	{
		unlink("$BACKUPDIR/snapshot.sql");
	}
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
	DumpMysql("$BACKUPDIR/snapshot.sql");
	print "\n";
}

#-------------------
# No changes below here...
#-------------------

if ((defined $CMDOPTION) && ($CMDOPTION eq "-snapshot"))
{
	$DOSNAPSHOT = -1;
}

print "CoffeeBackup.pl version $VERSION\n";
if ($DOSNAPSHOT == -1)
{
	print "Running Manual Snapshot\n";
}
print "==============================\n";

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
if ($DOSNAPSHOT == -1)
{
	SnapShotFunc();
	exit 0;
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
if (-f "$BACKUPDIR/coffeemud.sql-5")
{
	unlink("$BACKUPDIR/coffeemud.sql-5")  or warn "Could not unlink $BACKUPDIR/coffeemud.sql-5: $!";
}
if (-f "$BACKUPDIR/coffeemud.sql-4")
{
	rename("$BACKUPDIR/coffeemud.sql-4", "$BACKUPDIR/coffeemud.sql-5");
}
if (-f "$BACKUPDIR/coffeemud.sql-3")
{
	rename("$BACKUPDIR/coffeemud.sql-3", "$BACKUPDIR/coffeemud.sql-4");
}
if (-f "$BACKUPDIR/coffeemud.sql-2")
{
	rename("$BACKUPDIR/coffeemud.sql-2", "$BACKUPDIR/coffeemud.sql-3");
}
if (-f "$BACKUPDIR/coffeemud.sql-1")
{
	rename("$BACKUPDIR/coffeemud.sql-1", "$BACKUPDIR/coffeemud.sql-2");
}
DumpMysql($LATESTFILE);
print("Done!\n");
exit 0;
