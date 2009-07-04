########################################
# DVD MODULE
# this function reads input functions from file or text area and writes the input functions into $clientip.datafile.txt
########################################

sub run_dvd()
{
#	if($option_box eq "All trajectories from all possible initial states")
#	{
		print "<font color=blue><b>ANALYSIS OF THE STATE SPACE</b></font>"." [m = ".$p_value.", n = ".$n_nodes;

		print "] <br>";
		if($p_value**$n_nodes >= 7000000000000)
		{
			print "<font color=red><i>Sorry. Unable to compute statistics for very large networks. It is suggested you download the standalone version which has no limitations</i></font><br>";
		}
		else
		{
			if($statespace eq "State space graph")
			{
				
				system("perl count-comps-final.pl -p $filename $p_value $n_nodes $clientip $update_box_param $update_value $SSformat"); 		
				if(-e "$clientip.out.$SSformat")
				{
					print  "<A href=\"$clientip.out.$SSformat\" target=\"_blank\"><font color=red><i>Click to view the state space graph.</i></font></A><br>";
				}
			}
			else
			{
				system("perl count-comps-final.pl $filename $p_value $n_nodes $clientip $update_box_param $update_value $SSformat");
			}
              `rm -f -R $clientip`;
      		  `rm -f $clientip.out.dot`;
		}
#	}
#	else
#	{
#		print "<font color=blue><b>Computing Trajectory of the given initialization</b></font>"." [m = ".$p_value.", n = ".$n_nodes."] <br>";
#	   if( ($trajectory_value ne null) &&( $trajectory_value ne "") )
#	   {
#		    $trajectory_value =~ s/^\s+|\s+$//g;; #remove all leading and trailing white spaces
#			$trajectory_value =~  s/(\d+)\s+/$1 /g; #remove extra white space between the numbers
#			$trajectory_value =~ s/ /_/g;
#			if($statespace eq "State space graph")
#			{
#				system("perl sim.pl $filename $p_value $n_nodes $trajectory_value $clientip yes $update_box_param $update_value $SSformat");
#				if(-e "$clientip.graph.$SSformat")
#				{
#					print  "<A href=\"$clientip.graph.$SSformat\" target=\"_blank\"><font color=red><i>Click to view the trajectory.</i></font></A><br>";
#				}
#			}
#			else
#			{
#				system("perl sim.pl $filename $p_value $n_nodes $trajectory_value $clientip no $update_box_param $update_value $SSformat");
#			}
#		}
#		else
#		{
#			print "<br><font color=red>Sorry. Cannot accept null input for initialization field</font><br>";
#			die("Program quitting. Empty value for initialization field");
#		}
#
#	}
}

########################################
# end of run_dvd
########################################


1; # need to end with a true value                    
                    

