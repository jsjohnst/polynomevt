#!/usr/bin/perl

## Franziska B Hinkelmann
## Brandilyn Stigler
## Michael Stillman
## Hussein Vastani

use CGI qw( :standard );
use Fcntl qw( :flock );

use strict;

## set this to 1 for really ugly debug messages and 0 for no debug messages
my $DEBUG = 0;

sub make_file_prefix () {
    #get the clients ip address
    #$file_prefix = $ENV{'REMOTE_ADDR'};
    my $file_prefix =~ s/\./\-/g;
    my ( $sec, $min, $hr ) = localtime();
    $file_prefix = $file_prefix . '-' . $sec . '-' . $min . '-' . $hr;

    #$file_prefix = $sec.'-'.$min.'-'.$hr;
    $file_prefix = 'files' . $file_prefix;
    return $file_prefix;
    
}

#set paths for M2, etc. for the server to use
#$ENV{'PATH'}='/usr/local/bin:/bin:/etc:/usr/bin:/usr/local/Macaulay2-1.1';
$ENV{'PATH'}
    =
    '/opt/local/bin:/usr/local/bin:/bin:/etc:/usr/bin:/usr/local/:/Applications/Macaulay2-1.2/bin';

#$ENV{'LD_LIBRARY_PATH'}='/usr/local/lib/graphviz';

#include files with subroutines
require "create_input_data.pl";
require "make_m2_string_from_array.pl";
require "discretize_data.pl";
require "is_data_consistent.pl";
require "generate_wiring_diagram.pl";
require "split_input_data_into_multiple_files.pl";
require "concat_files.pl";
require "gfan.pl";
require "run_stochastic_simulation.pl";
require "error_check.pl";

print header,
    start_html(
    -title  => 'Polynome Web Interface',
    -script => { -language => 'JavaScript', -src => 'tutorial.js' }
    );
print start_multipart_form(
    -name     => 'form1',
    -method   => "POST",
    -onSubmit => "return validate()"
);

print "<div style=\"font-family:Verdana,Arial\">
    <div id=\"tipDiv\" style=\"position:absolute; visibility:hidden; z-index:100\"></div>
    <table background=\"gradient.gif\" width=\"100%\"  border=\"0\" cellpadding=\"0\" cellspacing=\"10\">
        <tr><td align=\"center\" colspan=\"2\"><b><font size=\"5\">Polynome: Discrete System Identification</font></b>
            <p>If this is your first time, please read the <a href=\"tutorial.html\" target=\"_blank\">tutorial</a>.
            It is important that you follow the format specified in the tutorial.<br>
            Make your selections and provide inputs (if any) in the form below and click Generate to run the software.<br>
        </td></tr>
        <tr><td>
            <table align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\">
                <tr><td>
                    <table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\">
                        <tr valign=\"top\"><td bgcolor=\"#FF8000\" nowrap><strong><font color=\"#FFFFFF\">Input Specification</font></strong></td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\"><strong>Type of Data</strong></font></td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\">Number of nodes: </font>";
print textfield(
    -name       => 'n_nodes',
    -value      => 3,
    -size       => 2,
    -maxlength  => 2);
print "<a href=\"tutorial.html#N\" onmouseover=\"doTooltip(event,0)\" onmouseout=\"hideTip()\">
                            <font size=\"1\">what is this?</font></a>
                        </td></tr>
<!--
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\"><strong>Type of Model</strong></font>
                            <a href=\"tutorial.html#U\" onmouseover=\"doTooltip(event,4)\" onmouseout=\"hideTip()\">
                            <font size=\"1\">what is this?</font></a>
                        </td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\">Select the type of polynomial dynamical system to be generated:<br>
                            <input type=\"radio\" name=\"is_deterministic_model\" value=\"Deterministic\" checked=\"checked\" />Deterministic<br />
                            <input type=\"radio\" name=\"is_deterministic_model\" value=\"Stochastic\" />Stochastic<br />
                        </td></tr>
-->
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\"><strong>Type of Simulation</strong></font>
                            <a href=\"tutorial.html#U\" onmouseover=\"doTooltip(event,4)\" onmouseout=\"hideTip()\">
                            <font size=\"1\">what is this?</font></a>
                        </td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\">";

### FBH For some reason -value is used to label the ceck
### box
### print checkbox_group( -name=>'has_sequential_update',
### -value=>'true', -label=>'Simulate the state space
### using an update schedule');
print checkbox_group(
    -name  => 'has_sequential_update',
    -value => 'Simulate the state space using an update schedule?',
    -label => 'Simulate the state space using an update schedule?'
);
print " 
            			    <br>&nbsp;&nbsp;&nbsp;&nbsp; - Enter update schedule separated by spaces
                            <input type=\"text\" name=\"update_schedule\"  size=\"20\" /><br>
			                &nbsp;&nbsp;&nbsp;&nbsp; - If none is entered, then the nodes will be simulated in parallel.</font>
                        </td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td bgcolor=\"#FF8000\" nowrap>
                            <b><font color=\"#FFFFFF\">Output Options<span style=\"background-color:#808080\"></span></font></b>&nbsp;&nbsp;&nbsp;
                        </td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap>
                            <font size=\"2\">Select output to view and file format.&nbsp;
                            <a href=\"tutorial.html#G\" onmouseover=\"doTooltip(event,6)\" onmouseout=\"hideTip()\">
                            <font size=\"1\">what is this?</font></a><br>";
print checkbox_group(
    -name  => 'show_wiring_diagram',
    -value => 'Wiring diagram',
    -label => 'Wiring diagram'
);
print "&nbsp;&nbsp;&nbsp;
                            <select name=\"wiring_diagram_format\">
                                <option value=\"*.gif\">*.gif</option>
                                <option value=\"*.jpg\">*.jpg</option>
                                <option value=\"*.png\">*.png</option>
                                <option value=\"*.ps\">*.ps</option>
                            </select>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp";
print checkbox_group(
    -name  => 'show_discretized_data',
    -value => 'Show Discretized data',
    -label => 'Show Discretized data'
);
print "<br>";
print checkbox_group(
    -name  => 'show_statespace',
    -value => 'State space graph',
    -label => 'State space graph'
);
print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <select name=\"statespace_format\">
                                <option value=\"*.gif\">*.gif</option>
                                <option value=\"*.jpg\">*.jpg</option>
                                <option value=\"*.png\">*.png</option>
                                <option value=\"*.ps\">*.ps</option>
                            </select>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp";
print checkbox_group(
    -name  => 'show_functions',
    -value => 'Show functions for Polynomial dynamical system',
    -label => 'Show functions for Polynomial dynamical system'
);
print "<br>";
print checkbox_group(
    -name  => 'show_probabilities',
    -value => 'Print probabilities in state space',
    -label => 'how
                        probabilities on the state space\?'
);

print "<br>
                            </font>
                        </td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                    </table>
                </td></tr>
            </table>
        </td>
        <td>
            <table cellSpacing=\"0\" cellPadding=\"1\" align=\"left\" bgColor=\"#ababab\" border=\"0\">
                <tr><td>
                    <table cellSpacing=\"0\" cellPadding=\"1\" width=\"100%\" bgColor=\"#ffffcc\" border=\"0\">
                        <tr vAlign=top><td nowrap bgColor=\"#ff8000\"><strong><font color=\"#ffffff\">Input Data</font></strong></td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><font size=\"2\">Upload data file: </font>
                            <input type=\"file\" name=\"input_file\"  />&nbsp;
                            <a href=\"tutorial.html#F\" onmouseover=\"doTooltip(event,2)\" onmouseout=\"hideTip()\">
                            <font size=\"1\">what is this?</font></a>
                        </td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr><td><div align=\"center\"><b>OR</b> <font size=\"2\" color=\"#006C00\">(Edit data below)</font></div></td></tr>
                        <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
                        <tr valign=\"top\"><td nowrap><div align=\"center\">";
print textarea(
    -name    => 'input_data',
    -default => '1.2  2.3  3.4
1.1  1.2  1.3
2.2  2.3  2.4
0.1  0.2  0.3',
    -rows    => 8,
    -columns => 50
);
print "</td></tr>
       <tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>
        </table>
        </td></tr>
        </table>
        </td></tr>
        <tr>
        <td>
        </td>
        </tr>
        <tr><td align=\"center\" colspan=\"2\">
            <input type=\"submit\" name=\"button_name\" value=\"Generate\" /> <br><font color=\"#006C00\"><br>
            <i>Output will be displayed below.
            <b>Note</b>: Computation time depends on data size and internet connection.
            </i></font>
        </td></tr>
    </table>
</div>
<div>
    <input type=\"hidden\" name=\".cgifields\" value=\"show_wiring_diagram\" />
    <input type=\"hidden\" name=\".cgifields\" value=\"show_probabilities\" />
    <input type=\"hidden\" name=\".cgifields\" value=\"update_box\" />
    <input type=\"hidden\" name=\".cgifields\" value=\"show_statespace\" />
</div>";
print end_form;

# log user access
open( ACCESS, ">>access" ) or die("Failed to open file for writing");
flock( ACCESS, LOCK_EX ) or die("Could not get exclusive lock $!");
print ACCESS ( $ENV{REMOTE_ADDR} );
system("date >>access");
flock( ACCESS, LOCK_UN ) or die("Could not unlock file $!");
close(ACCESS);

my $p_value                = 2;
my $n_nodes                = param('n_nodes');
my $is_deterministic_model = param('is_deterministic_model');
    # values Deterministic, Stochastic

# to generate the model, synchronuous updates are used, but the user can
# choose to simulate the model using sequential updates
my $has_sequential_update = param('has_sequential_update');
    # "Simulate the state space using an update schedule" if sequential update, otherwise synchronuous update
    # This will be changed once we find out, why value instead of label is
    # printed to html form for check boxes
my $update_schedule = param('update_schedule');
    # if has_sequential_update is true, this is a string
    # of the form e.g. "1 3 4 2 5" (indices start at 1, and should include all 1..$n_nodes values in some order).

my $input_file = upload('input_file');
my $input_data = param('input_data');

### FBH I have no idea what this is used for?!
### $option_box = param('option_box');
### $trajectory_value = param('trajectory_value');

my $show_discretized_data = param('show_discretized_data');
my $show_wiring_diagram   = param('show_wiring_diagram');
my $wiring_diagram_format = param('wiring_diagram_format');
my $show_statespace       = param('show_statespace');
    ### FBH for now, the statespace is always created, but only when
    ### $show_statespace is set, the link is reported to the user

my $statespace_format  = param('statespace_format');
my $show_probabilities = param('show_probabilities');
    # if set, probabilities are drawn in state space

my $show_functions = param('show_functions');


#check routines
# p_value, n_nodes: are they numbers and allowed numbers?
# is # of nodes equal to # of columns in data? is data in number format
# print out number of lines in data

# if sequential update is chosen, is the updateschedule valid?
# check for number of elements in schedule
# sort -u the array, then a[1]=1 and a[n]=n
# warning if update schedule but not sequential update


# remove . from file format
$statespace_format     =~ s/\*\.//;
$wiring_diagram_format =~ s/\*\.//;

if ( $p_value && $n_nodes ) {
    my $file_prefix = make_file_prefix();
    $input_file
        = create_input_datafile( $file_prefix, $input_file, $input_data );
        unless (data_has_correct_format( $n_nodes, $input_file ) ) {
            print "<font color=red>Please correct your data.</font><br>";
            print "<font color=red>Exiting.</font><br>";
            exit 1;
        }
    my @list_of_input_files = split_input_data_into_multiple_files( $input_file );
    my @list_of_discretized_datafiles
        = discretize_data( \@list_of_input_files, $p_value, $file_prefix );

    my $discretized_datafile = concat_files( \@list_of_discretized_datafiles,
    $file_prefix. ".input.txt" );
    if ($discretized_datafile ) {
        if ($show_discretized_data) {
            print
                "<A href=\"$discretized_datafile\" target=\"_blank\"><font color=green><i>Discretization was successful.</i></font></A><br><br>";
        }
        else {
            print
                "<font color=green><i>Discretization was successful.</i></font><br><br>";
        }
    }
    else {
        print "<font color=red>Discretization was unsuccessful</font><br>";
        die("Discretization unsuccessful");
    }
    
    


    if ( $show_wiring_diagram && !$show_statespace && !$show_functions ) {
        my $wiring_diagram_filename;

        ## if only the wiring diagram but not the functions are needed, minsets()
        ## is used
        if ( is_data_consistent( \@list_of_discretized_datafiles, $p_value, $n_nodes ) )
        {
            if ( $n_nodes <= 10 ) {
                $wiring_diagram_filename
                    = generate_wiring_diagram( \@list_of_discretized_datafiles,
                    $p_value, $n_nodes, $wiring_diagram_format, $file_prefix );
            }
            else {
                $wiring_diagram_filename
                    = minsets_generate_wiring_diagram( \@list_of_discretized_datafiles,
                    $p_value, $n_nodes, $wiring_diagram_format, $file_prefix );
            }
        }
        else {
            print
                "<font color=red>The data are inconsistent. Please check the input data.</font><br>";
        }
        if ($wiring_diagram_filename) {
            print
                "<A href=\"$wiring_diagram_filename\" target=\"_blank\"><font color=green><i>Wiring diagram.</i></font></A><br><br>";
        }

        # else there's no wiring diagram -> problem

    }
    elsif ( $show_statespace || $show_functions ) {
        ## if the funtions are needed, sgfan() is used

#        if($is_deterministic_model eq "Deterministic")
#        {
#            if($n_nodes <= 10)
#            {
#                ea();
#            }
#            else
#            {
#                if(!is_data_consistent($discretized_datafile,$p_value,$n_nodes))
#                {
#                    make_consistent();
#                }
#                minsets();
#            }
#
#            run_deterministic_simulation();
#        }
#        else
#        {

        if ( $n_nodes <= 10 ) {
    
            if (is_data_consistent( \@list_of_discretized_datafiles, $p_value, $n_nodes))
            {
                my $function_file
                    = sgfan( \@list_of_discretized_datafiles, $p_value,
                    $n_nodes, $file_prefix );
                if ( $function_file && $show_functions ) {
                    print "<A href=\"$function_file\" target=\"_blank\"><font
                    color=green><i>Functions.</i></font></A><br>";
                }
                run_stochastic_simulation(
                    $p_value, $n_nodes, $file_prefix,
                    $show_wiring_diagram, $wiring_diagram_format,
                    $show_statespace,     $statespace_format,
                    $show_probabilities, $function_file
                );
            }
            else {
                # make_consistent();
                print
                    "<font color=red>The data are inconsistent. Please check the input data.</font><br>";
            }
        }
        else {
            print "Cannot have more than 10 nodes at this time.<br>";
        }
    }
}

print end_html();

