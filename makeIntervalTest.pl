#!/usr/bin/perl 

use strict;

# global number of subintervals
our $n = 5;

# array [min,max] divided into $n subintervals of equal lenght
our $subIntervalLength;

# Global array, interval [min, max] split into n intervals
our @_array;

sub in_interval {
  my $number = $_[0];
  #print "in in_interval $number\n";
  for (my $i = 1; $i <= $n; $i++) {
    if ( $number <= $_array[$i] ) {
      return $i;
    }
  } 
  print "Error, needs to be called with number between $_array[0] and $_array[$n]\n";
  return -1;
}

sub make_threshold_with {
  
  my ($my_min, $my_max) = @_;
  if ($my_max - $my_min >= 1.5*$subIntervalLength) {
    print "$my_min and $my_max are too far away.";
    return;
  }

  # if (within the same interval) do nothing
  if ( in_interval($my_min) == in_interval($my_max) ) {
    # nothing do to
    return @_array;
  }

  my @my_array = @_array;
  my $interval;
  my $diff = $my_max - $my_min;
  my $boundaryInBetween = in_interval( $my_min );
  # if (diff > $subIntervalLength) make [min, max] an interval, adjoining ones: one gets
  # bigger, one gets smaller
  if ( $diff > $subIntervalLength) {
    my $min_interval = in_interval( $my_min );
    my $max_interval = in_interval( $my_max );
    if ( $max_interval - $min_interval == 1 ) {
      my $min_diff = $my_array[$boundaryInBetween-1] - $my_min;
      my $max_diff = $my_array[$boundaryInBetween+1] - $my_max;
      if ( $min_diff > $max_diff ) { 
        $my_array[$boundaryInBetween] = $my_min;
      } else {
        $my_array[$boundaryInBetween] = $my_max;
      }
    }
    elsif ( $max_interval - $min_interval == 2 ) {
      $_array[$min_interval] = $my_min;
      $_array[$max_interval-1] = $my_max;
    }
  # if (diff < $subIntervalLength)  but not within same interval
  } else { 
    my $min_diff = $my_array[$boundaryInBetween] - $my_min;
    my $max_diff = $my_max - $my_array[$boundaryInBetween];
    if ( $diff < $subIntervalLength/2) {
      # find out which one is closer
      # to boundary and make that a new boundary  
      if ( $min_diff > $max_diff ) { 
        $my_array[$boundaryInBetween] = $my_max;
      } else {
        $my_array[$boundaryInBetween] = $my_min;
      }
    } else {  #if ( $subIntervalLength/2 < diff < $subIntervalLength) 
      # make my_min and my_max new boundariess
      if ( $min_diff > $max_diff ) {
        $my_array[$boundaryInBetween-1] = $my_min;
        $my_array[$boundaryInBetween] = $my_max;
      } else { 
        $my_array[$boundaryInBetween] = $my_min;
        $my_array[$boundaryInBetween+1] = $my_max;
      } 
    }
  }
  return @my_array;
}

sub compare_arrays {
  my ($first, $second) = @_;
  no warnings;  # silence spurious -w undef complaints
    return 0 unless @$first == @$second;
  for (my $i = 0; $i < @$first; $i++) {
    return 0 if $first->[$i] != $second->[$i];
  }
  return 1;
}

sub my_print {
  my ($my_min, $my_max) = ($_[0], $_[1]);
  print "$my_min $my_max:\t ";
  my @my_array = make_threshold_with( $my_min, $my_max );
  unless( compare_arrays( \@my_array, \@_array ) ){
    print "@my_array\n";
  } else { 
    print "equal\n";
  }
}

# initialize array as equidistant partition of [min, max]
sub init_array {
  my ($my_min, $my_max) = @_;

  $_array[0] = $my_min;
  $subIntervalLength = ($my_max - $my_min) / $n;
  for (my $i = 1; $i <= $n; $i++) {
    $_array[$i] = $my_min + $subIntervalLength * $i;
  }

}

print "Hello world!\n";

# these are the min and max concentration for the gene in all
# timecourses/steady states
my $my_min = .1;
my $my_max = .8;

init_array($my_min, $my_max);
print "For this example we use the array: @_array.\n";
my_print(.2, .22);
my_print(.19, .21);
my_print ( .18, .26); 
my_print ( .19, .22);
my_print ( .1, .21);
my_print ( .19, .41);
my_print ( .19, .28);
my_print ( .11, .21);
my_print ( .11, .28);
my_print ( .11, .33);
my_print ( .19, .41);
my_print ( .35, .42);
my_print ( .65, .75);
my_print ( .71, .80);
my_print ( .14, .27);
my_print ( .82, .99);


my $my_min = .1;
my $my_max = .6;

init_array($my_min, $my_max);
print "\n \n \n For this example we use the array: @_array.\n";
my_print(.2, .22);
my_print(.19, .21);
my_print ( .18, .26); 
my_print ( .19, .22);
my_print ( .1, .21);
my_print ( .19, .28);
my_print ( .11, .21);
my_print ( .11, .18);
my_print ( .11, .23);
my_print ( .19, .31);
my_print ( .35, .42);
my_print ( .14, .27);
my_print ( .19, .41);
my_print ( .82, .82);


