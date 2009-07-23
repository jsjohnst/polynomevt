########################################
# DVD2 MODULE
########################################

$MAX_NET_SIZE = 1024;    # 2^10

sub run_stochastic_simulation()
{
    my ($p_value, $n_nodes, $file_prefix, $show_wiring_diagram, $wiring_diagram_format, $show_statespace,
    $statespace_format, $show_probabilities, $function_file, $http_base_path) = @_;
#	if($option_box eq "All trajectories from all possible initial states")
#	{
		print "<font color=blue><b>ANALYSIS OF THE STATE SPACE</b></font>"." [p = ".$p_value.", n = ".$n_nodes;
		print "] <br>";
		if($p_value**$n_nodes > $MAX_NET_SIZE) 
		{
			print "<font color=red><i>Sorry. Unable to compute statistics for very large networks. It is suggested you download the standalone version which has no limitations</i></font><br>";
		}
		else
		{
			# Set flag for creating the dependency graph and whether to print
			# the probabilities in the phase space
			($show_wiring_diagram) ? {$show_wiring_diagram = 1} : {$show_wiring_diagram=0};
			($show_probabilities) ? {$show_probabilities = 1} : {$show_probabilities = 0 };


			# Calling the wrapper script dvd_stochastic_runner.pl, which in
			# turn calls DVDCore routines

$update_schedule = 0;
$updstoch_flag = "0";
$updsequ_flag  = "0";
			#print("perl dvd_stochastic_runner.pl $n_nodes $p_value 1 $updstoch_flag $file_prefix $statespace_format $show_wiring_diagram $updsequ_flag $update_schedule $show_probabilities 1 0 $function_file"); 
			system("perl dvd_stochastic_runner.pl $n_nodes $p_value 1 $updstoch_flag $file_prefix $statespace_format $show_wiring_diagram $updsequ_flag $update_schedule $show_probabilities 1 0 $function_file"); 

			if($show_statespace)
			{
				if(-e "$file_prefix.out.$statespace_format")
				{
#print "\n not alright";
					print  "<A href=\"$http_base_path$file_prefix.out.$statespace_format\"
                    target=\"_blank\"><font color=green><i>Click to view the state space graph.</i></font></A><br>";
				}
			}
#		`rm -f -R $file_prefix`;
#		`rm -f $file_prefix.out.dot`;
		}

	  #if(-e "$file_prefix.wiring-diagram.$wiring_diagram_format")
	  if(-e "$file_prefix.wiring-diagram.$statespace_format")
		{
				print  "<A href=\"$http_base_path$file_prefix.wiring-diagram.$wiring_diagram_format\"
                target=\"_blank\"><font color=green><i>Click to view the
                wiring diagram.</i></font></A><br>";
				`rm -f $file_prefix.wiring-diagram.dot` if(!$DEBUG); 
				`rm -f $file_prefix.out2.dot` if(!$DEBUG);
		}
#	}
#	else
#	{
#	   print "<font color=blue><b>Computing Trajectory of the given initialization</b></font>"." [m = ".$p_value.", n = ".$n_nodes."] <br>";
#	   if( ($trajectory_value ne null) &&( $trajectory_value ne "") )
#	   {
#		    $trajectory_value =~ s/^\s+|\s+$//g;; #remove all leading and trailing white spaces
#			$trajectory_value =~  s/(\d+)\s+/$1 /g; #remove extra white space between the numbers
#			$trajectory_value =~ s/ /_/g;
#			if($statespace eq "State space graph")
#			{
#				system("perl sim.pl $filename $p_value $n_nodes $trajectory_value $file_prefix yes $update_box_param $update_schedule $statespace_format");
#				if(-e "$file_prefix.graph.$statespace_format")
#				{
#					print  "<A href=\"$file_prefix.graph.$statespace_format\" target=\"_blank\"><font color=red><i>Click to view the trajectory.</i></font></A><br>";
#				}
#			}
#			else
#			{
#				system("perl sim.pl $filename $p_value $n_nodes $trajectory_value $file_prefix no $update_box_param $update_schedule $statespace_format");
#			}
#		}
#		else
#		{
#			print "<br><font color=red>Sorry. Cannot accept null input for initialization field iii</font><br>";
#			die("Program quitting. Empty value for initialization field");
#		}
#	}

}



1; # need to end with a true value                    
                    

