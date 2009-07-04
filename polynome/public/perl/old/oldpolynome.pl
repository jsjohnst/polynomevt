#!/usr/bin/perl

## Hussein Vastani 
## Franziska Hinkelmann
## Brandilyn Stigler

use CGI qw( :standard );
use Fcntl qw( :flock );

#get the clients ip address
$clientip = $ENV{'REMOTE_ADDR'};
$clientip =~ s/\./\-/g;
($sec,$min,$hr) = localtime();
$clientip = $clientip.'-'.$sec.'-'.$min.'-'.$hr;
#$clientip = $sec.'-'.$min.'-'.$hr;

#set path for M2 for the server to use
$ENV{'PATH'}='/usr/local/bin:/bin:/etc:/usr/bin:/usr/local/Macaulay2-1.1';
#$ENV{'LD_LIBRARY_PATH'}='/usr/local/lib/graphviz';

print header, start_html( -title=>'Polynome Web Interface', -script=>{-language=>'JavaScript',-src=>'tutorial.js'});
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");

open (FILE,"./polynome.html"); 
#open (FILE,"/home/httpd/htdocs/polymath.vbi.vt.edu/polynome/polynome.html"); 
@file = <FILE>;
close(FILE);
foreach $line (@file) {
	print "$line";
}

print end_form;

open(ACCESS, ">>access") or die("Failed to open file for writing");
flock(ACCESS, LOCK_EX) or die ("Could not get exclusive lock $!");
print ACCESS ($ENV{REMOTE_ADDR});
system("date >>access");
flock(ACCESS, LOCK_UN) or die ("Could not unlock file $!");
close(ACCESS);

$p_value = 2;
$n_nodes = param('n_nodes');
$discretize_box = param('discretize_box');
$update_box = param('update_box');
$update_seq = param('update_seq');
$update_schedule = param('update_schedule');
$upload_file = upload('upload_file');
$edit_data = param('edit_data');
$option_box = param('option_box');
$trajectory_value = param('trajectory_value');
$data = param('data');
$depgraph = param('depgraph');
$DGformat = param('DGformat');
$statespace = param('statespace');
$SSformat = param('SSformat');
$stochastic = param('stochastic'); 	# if set, probabilities are drawn in state space

########################
# Is this needed?
########################
$trajectory_box = param('trajectory_box');

$updstoch_flag = "0";
$updsequ_flag= "0";
my $bytesread = "";
my $buffer = "";
 
$DEBUG = 0;

$fileuploaded = 0;
$SSformat =~ s/\*\.//;
$DGformat =~ s/\*\.//;
print "hello<br>" if ($DEBUG);
if($p_value && $n_nodes)
{
	create_input_data();
	set_update_type();
	if($option_box eq "All trajectories from all possible initial states")
	{
		print "<font color=blue><b>ANALYSIS OF THE STATE SPACE</b></font>"." [m = ".$p_value.", n = ".$n_nodes;
		if($fileuploaded == 1)
		{
			print ", file path = ". $upload_file;
		}
		print "] <br>";
		if($p_value**$n_nodes >= 10000)
		{
			print "<font color=red><i>Sorry. Unable to compute statistics for very large networks. It is suggested you download the standalone version which has no limitations</i></font><br>";
		}
		else
		{
			# Set flag for creating the dependency graph and whether to print
			# the probabilities in the phase space
			($depgraph eq "Dependency graph") ? {$depgraph = 1} : {$depgraph=0};
			($stochastic eq "Print probabilities") ? {$stochastic = 1} : {$stochastic = 0 };

			# Calling the wrapper script dvd_stochastic_runner.pl, which in
			# turn calls DVDCore routines
			system("perl dvd_stochastic_runner.pl $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic $filename"); 		
			if($statespace eq "State space graph")
			{
				if(-e "$clientip.out.$SSformat")
				{
					print  "<A href=\"$clientip.out.$SSformat\" target=\"_blank\"><font color=red><i>Click to view the state space graph.</i></font></A><br>";
				}
			}
		`rm -f -R $clientip`;
		`rm -f $clientip.out.dot`;
		}
	  #if(-e "$clientip.out1.$DGformat")
	  if(-e "$clientip.out1.$SSformat")
		{
				print  "<A href=\"$clientip.out1.$DGformat\" target=\"_blank\"><font color=red><i>Click to view the dependency graph.</i></font></A><br>";
				`rm -f $clientip.out1.dot` if(!$DEBUG); 
				`rm -f $clientip.out2.dot` if(!$DEBUG);
		}
	}
	else
	{
	   print "<font color=blue><b>Computing Trajectory of the given initialization</b></font>"." [m = ".$p_value.", n = ".$n_nodes."] <br>";
	   if( ($trajectory_value ne null) &&( $trajectory_value ne "") )
	   {
		    $trajectory_value =~ s/^\s+|\s+$//g;; #remove all leading and trailing white spaces
			$trajectory_value =~  s/(\d+)\s+/$1 /g; #remove extra white space between the numbers
			$trajectory_value =~ s/ /_/g;
			if($statespace eq "State space graph")
			{
				system("perl sim.pl $filename $p_value $n_nodes $trajectory_value $clientip yes $update_box_param $update_schedule $SSformat");
				if(-e "$clientip.graph.$SSformat")
				{
					print  "<A href=\"$clientip.graph.$SSformat\" target=\"_blank\"><font color=red><i>Click to view the trajectory.</i></font></A><br>";
				}
			}
			else
			{
				system("perl sim.pl $filename $p_value $n_nodes $trajectory_value $clientip no $update_box_param $update_schedule $SSformat");
			}
		}
		else
		{
			print "<br><font color=red>Sorry. Cannot accept null input for initialization field iii</font><br>";
			die("Program quitting. Empty value for initialization field");
		}
	}
    `rm -f $clientip.datafile.txt` if (!$DEBUG); 
    `rm -f Bool-$clientip.datafile.txt` if (!$DEBUG);

}

#print end_html();

# this function reads input functions from file or text area and writes the input functions into $clientip.datafile.txt
sub create_input_data()
{
    open (OUTFILE, ">$clientip.datafile.txt");
	if($upload_file)
	{
	  $fileuploaded = 1;
      flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
      while($bytesread=read($upload_file, $buffer, 1024))
      {
            print OUTFILE $buffer;
      }
      flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
	  close $upload_file;
	}
	else  # user has not uploaded any file. so use the textarea value
	{
	  if($edit_data)
	  {
		#read value from editfunctions and print it to outfile
		#flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
		print OUTFILE $edit_data;
		flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
	  }
	  else # no functions provided
	   {
		print "<font color=\"red\">Error: No functions provided. Please upload a function file or type in your functions in the edit box</font><br>";
		close(OUTFILE);
		die("No function file provided by user");
	   }
	}	
    close(OUTFILE);

	#remove any ^M characters
    `perl -pi -e 's/\r//g' "$clientip.datafile.txt"`;
    $buffer = "";  
	$filename = "$clientip.datafile.txt";

	if($discretize_box eq "Raw")
    {
		discretize_data();
	}
}

sub discretize_data()
{
	print "discretize_data<br>" if ($DEBUG);
#	system("perl translator.pl $clientip.functionfile.txt $clientip.trfunctionfile.txt $n_nodes");

#$discretize_command = "M2 Discretize.m2 --silent -q -e \\\"discretize({\\\"$clientip.datafile.txt\\\"}, 2);exit 0;\\\"" ;
print  "<A href=\"$clientip.datafile.txt\" target=\"_blank\">test.</A><br><br>";
system("M2 Discretize.m2 --silent -q -e \\\"discretize({\\\"$clientip.datafile.txt\\\"}, 2);exit 0;\\\"");
#system($discretize_command);
#`M2 Discretize.m2 --silent -q -e \"discretize({\\\"$clientip.datafile.txt\\\"}, 2);exit 0;\"`;

#system("ls>files.txt");

#system("M2 --silent -e \"f=openOut \\\"brandy2\\\";f<<\\\"hi\\\";f<<close;exit 0;\"");

#system("M2 --silent -q test.m2 < test.txt");
#system("M2 test.txt -e \"exit 0\"");
#`M2 --silent -q test.m2 < test.txt`;
$filename = "brandy";

#`$discretize_command`;
	$filename = "Bool-$clientip.datafile.txt";
	if(-e $filename)
	{
		print  "<A href=\"$filename\" target=\"_blank\"><font color=green><i>Discretization was successful.</i></font></A><br><br>";
	}
	else
	{
		print "<font color=red>Discretization was unsuccessful</font><br>";
#		`rm -f $clientip.datafile.txt`;
		die("Discretization unsuccessful");
	}
}

sub set_update_type()
{
	$update_box_param = "";
	if($update_box eq 'Update_stochastic')
	{
		 #print "Update Stochastic<br>";
	   $update_box_param = "updstoch";
	   $updstoch_flag = "1";
	   $update_schedule = "0";
	}
	 if($update_box eq 'Sequential')
	{
		#print "$update_box<br>";
	   $update_box_param = "async";
	   $updsequ_flag = "1";
	   if( ($update_schedule ne null) &&( $update_schedule ne "") )
	   {
		   $update_schedule =~ s/^\s+|\s+$//g; #remove all leading and trailing white spaces
		   $update_schedule =~  s/(\d+)\s+/$1 /g; # remove extra spaces in between the numbers
		   $update_schedule =~ s/ /_/g;
		   #print "$update_schedule";
	   }
	   else
	   {
		 print "<br><font color=red>Sorry. Cannot accept null input for update schedule field</font><br>";
		 die("Program quitting. Empty value for update schedule field");
	   }
	}
	else
	{
		$update_box_param = "parallel";
		$update_schedule = "0";
	}
}

print end_html();

