#!/usr/bin/perl

# Set these for your situation
my $MTDIR = "/home/cmowner/CoffeeMud";
my $BACKUPDIR = "/home/cmowner/backups";
my $TARCMD = "/bin/tar czf";
my $SQLDUMPCMD = "/usr/bin/mysqldump";
my $VERSION = "1.8.0";
my $OPTION_FILE = "/home/cmowner/.cmbackuprc";
my $LATESTFILE = "$BACKUPDIR/coffeemud.sql-1";
my $DOSNAPSHOT = 0;
my $MYSQLUSER = "";
my $MYSQLPSWD = "";
my $MYSQLDBNAME = "coffeemud";
my $FILEEDITOR = $ENV{EDITOR};

if ($FILEEDITOR eq "")
{
	$FILEEDITOR = "/usr/bin/nano";
}

my $BACKUPUSER = "";
my $BACKUPPASS = "";
my $BACKUPSERVER = "";
my $BACKUPPATH = "";
my $DEBUG_MODE = "off";

my $templatefile = <<'END_TEMPLATE';
# Put mysql user here
coffeemud
# Put mysql password here
changeme
# Put database name here
coffeemud
# Backup User
backupuser
# Backup Pswd
backuppass
# Backup Server
backupserver
# Backup Path
backuppath
END_TEMPLATE

# Get if they said a option
my $CMDOPTION = shift;

sub PrintDebugCommand
{
        if ($DEBUG_MODE eq "off")
        {
                return;
        }
        my $PassedString = shift;
        print "About to run:\n$PassedString\n";
        print "Press Enter To Run This:";
        my $entered = <STDIN>;
}

sub ReadPrefs
{
	my $LineCount = 0;
	if (! -f $OPTION_FILE)
	{
		open my $fh, '>', "$OPTION_FILE";
		print ($fh $templatefile);
		close($fh);
		system("$FILEEDITOR $OPTION_FILE");
	}

	open(my $fh, '<:encoding(UTF-8)', $OPTION_FILE)
		or die "Could not open file '$OPTION_FILE' $!";

	while (my $row = <$fh>)
	{
		chomp $row;
		if (substr($row, 0, 1) eq "#")
		{
			# Skip comment lines
			next;
		}

		if ($LineCount == 0)
		{
			$MYSQLUSER = $row;
		}
		elsif ($LineCount == 1)
		{
			$MYSQLPSWD = $row;
		}
		elsif ($LineCount == 2)
		{
			$MYSQLDBNAME = $row;
		}
		elsif ($LineCount == 3)
		{
			$BACKUPUSER = $row;
		}
		elsif ($LineCount == 4)
		{
			$BACKUPPASS = $row;
		}
		elsif ($LineCount == 5)
		{
			$BACKUPSERVER = $row;
		}
		elsif ($LineCount == 6)
		{
			$BACKUPPATH = $row;
		}
		$LineCount += 1;
	}
	close($fh);
	if ($MYSQLUSER eq "")
	{
		print "Database username is empty - check the config file with \"coffeebackup.pl -prefs\"\n";
		exit;
	}
	if ($MYSQLPSWD eq "")
	{
		print "Database password is empty - check the config file with \"coffeebackup.pl -prefs\"\n";
		exit;
	}
	if ($MYSQLDBNAME eq "")
	{
		print "Database name is empty - check the config file with \"coffeebackup.pl -prefs\"\n";
		exit;
	}
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
}

sub DumpMysql
{
	my $DUMPFILE = $_[0];

	print "Backing up MYSQL data: ";
	if (-f "$DUMPFILE")
	{
		unlink("$DUMPFILE");
	}
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
	system("$SQLDUMPCMD --user=$MYSQLUSER --password=$MYSQLPSWD --result-file=$DUMPFILE $MYSQLDBNAME");
	print "\n";
}

if (defined $CMDOPTION)
{
	if (($CMDOPTION ne "-snapshot") && ($CMDOPTION ne "-prefs"))
	{
		print "Unknown command line option: '$CMDOPTION'\nOnly allowed options are '-snapshot' and '-prefs'\n";
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
	PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/snapshot.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH\n");
        PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/snapshot.sql $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
        system ("rsync -avz -e ssh $BACKUPDIR/snapshot.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
        system ("rsync -avz -e ssh $BACKUPDIR/snapshot.sql $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
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

if ((defined $CMDOPTION) && ($CMDOPTION eq "-prefs"))
{
	# Edit the prefs file
	print "Editing the prefs file\n";
	if (! -f $OPTION_FILE)
	{
		open my $fh, '>', "$OPTION_FILE";
		print ($fh $templatefile);
		close($fh);
	}
	system("$FILEEDITOR $OPTION_FILE");
	print "Prefs saved - please re-run the backup\n";
	exit 0;
}

ReadPrefs();

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
	unlink("$BACKUPDIR/coffeebackup-5.tgz") or warn "Could not unlink $BACKUPDIR/coffeebackup-5.tgz: $!";
}

my $FileRevision = 4;
while ($FileRevision > 0)
{
	if (-f "$BACKUPDIR/coffeebackup-$FileRevision.tgz")
	{
		my $NewVersion = $FileRevision + 1;
		rename("$BACKUPDIR/coffeebackup-$FileRevision.tgz", "$BACKUPDIR/coffeebackup-$NewVersion.tgz");
	}
	$FileRevision -= 1;
}

print "Done\nCreating New Backup: ";
system("$TARCMD $BACKUPDIR/coffeebackup-1.tgz $MTDIR");
print "Done\nMoving Existing MySQL data: ";
if (-f "$BACKUPDIR/coffeemud.sql-5")
{
	unlink("$BACKUPDIR/coffeemud.sql-5") or warn "Could not unlink $BACKUPDIR/coffeemud.sql-5: $!";
}

$FileRevision = 4;
while ($FileRevision > 0)
{
	if (-f "$BACKUPDIR/coffeemud.sql-$FileRevision")
	{
		my $NewVersion = $FileRevision + 1;
		rename("$BACKUPDIR/coffeemud.sql-$FileRevision", "$BACKUPDIR/coffeemud.sql-$NewVersion");
	}
	$FileRevision -= 1;
}

DumpMysql($LATESTFILE);

if ($BACKUPSERVER ne "")
{
        print "Offsite backup requested\n";
        print "Copying $BACKUPDIR/coffeebackup-1.tgz to $BACKUPSERVER\n";
        PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/coffeebackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH\n");
        PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/coffeemud.sql-1 $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
        system ("rsync -avz -e ssh $BACKUPDIR/coffeebackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
        system ("rsync -avz -e ssh $BACKUPDIR/coffeemud.sql-1 $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
}

print("Done!\n");
exit 0;
