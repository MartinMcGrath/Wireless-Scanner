#!/usr/bin/perl
# Made by Edoardo Mantovani, 2020

#If appear some errors related to the wpa_cli/wpa_supplicant please, execute:
# sudo wpa_supplicant -dd -Dnl80211,wext -i wlo1 -c /etc/wpa_supplicant/wpa_supplicant.conf 
# NOTE: wlo1 can be substituted to your wireless interface

our $VERSION = '0.032';
sub BEGIN{

no strict;
use File::chmod qw( chmod );

if(! ( -e 'Executor.pl' ) ){ # check if Executor.pl exists, if not..
my $Executor_Script = ''; #insert the script into the ' '

open (EXECUTOR, '>', 'Executor.pl'); 
print EXECUTOR "#!/usr/bin/perl \n";
print EXECUTOR "$Executor_Script\n";
close EXECUTOR;
chmod("u+x", 'Executor.pl'); # like chmod +x <file>
}
 
if(! ( -e 'screen.txt') ){
  open(SCREEN, '>', 'screen.txt');
  print SCREEN "focus up\n";
  print SCREEN "title 'Wireless scanner'\n";
  print SCREEN "screen perl WirelessCan\n";
  print SCREEN "split\n";
  print SCREEN "resize -b +7 \n";
  print SCREEN "focus bottom\n";
  print SCREEN "title 'Wireless Sender'\n";
  print SCREEN "focus down\n";
  print SCREEN "screen perl Executor.pl \n";
  close SCREEN;
  ` screen -c 'screen.txt' `; 
  }
}

sub END{

use strict;
no strict 'refs';
no strict 'subs';
use File::Path 'rmtree';
use Term::Multiplexed qw( multiplexed ); 
use Term::ANSIColor qw(colored);
use Net::Bluetooth qw( get_remote_devices ); # Bluetooth detector utility
use Net::Wireless::802_11::WPA::CLI; # wireless WPA_SUPPLICANT interface

if( multiplexed ){ # detect if the code is running in a multiplexed screen

rmtree('screen.txt');  
#rmtree('Executor.pl');

my $scan = Net::Wireless::802_11::WPA::CLI->new();

my $x = 0;
my @BSSID;
sub Wireless_Scan(){
  $scan->scan();
  foreach ( $scan->scan_results() ){
    if($_ =~ /:/){
      push @BSSID, $_;
    }else{
       if(length($_->{ssid}) != 25){
         while(length($_->{ssid}) != 25){    # leverage the distance between the SSID and the '|' 
            chop($_->{ssid}) if (length($_->{ssid}) > 25);
            $_->{ssid} .= " " if (length($_->{ssid}) < 25);
            }
          } 
     print  colored(['red'], $_->{ssid}, '   |  ', colored(['cyan'],$BSSID[$x]), ' ', colored(['green'], $_->{frequency}), ' ', colored(['yellow'], $_->{flags}), "\n"); # print various informations in a fashion/colored way
     $x++; 
}  
  
  }

}
my $Bluetooth_Devices = get_remote_devices();
my $counter = 0;
sub Bluetooth_Scan(){
    $counter++;
    if( int( $counter % 50 ) ){
	foreach( keys %$Bluetooth_Devices ){
	    print $Bluetooth_Devices->{ $_ };
	    print "\n";
	}
  }
  }
while(1){
  printf "\033c"; # clear completely the screen
  sleep (1); # upload frequency
  print colored(['bold blue'], "Wireless Scan\n");
  print colored(['bold green'], "SSID                           BSSID                  SECURITY\n");  # Wireless columns
  print &Wireless_Scan(); 
  print colored(['bold blue'], "Bluetooth Scan\n");
  print colored(['bold green'], "Name                            Address\n"); # Bluetooth columns
  print &Bluetooth_Scan();
      }
   }

}

=head1 NAME

Wireless::Scanner - a small utility which scan near Bluetooth and Wifi networks

=cut

=head1 VERSION

current Version is the 0.02

=cut

=head1 INSTALLATION

To install this module, run the following commands:

perl Makefile.PL

make

// make test (STILL IN BETA, SKIPPING FOR NOW..)

make install

=cut

=head1 MAIN USAGE

sudo perl WirelessCan

 [ no args for now :( ]

=cut

=head1 DESCRIPTION

DETAILS   

As the name suggests, this script scan the near networks, both bluetooth and wireless are shown in a pretty formatted output.

I have uploaded an additional script 'Executor.pl', which can be used as CLI in the lower part of the screen.

for additional info see the comments in the script.

(the script need also the linux screen utility for the 'splitting screen feature').


=cut 

=head1 AUTHOR

Edoardo Mantovani
 
=cut

=head1 NOTE

   - The documentation will added during the project uodates, this is only an alpha, in future will be even more complex
   - Probably the bluetooth scan won't work, I am still working on it, BLE devices aren't recognized because I haven't found any BLE compatible module.
   - The script hasn't a Makefile.PL or make, for building the dependencies execute only the "install-deps.sh" script.

=cut
=head1 TODO

  - speed up the first part
  - make an android version ( android chips doesn't support monitor mode )
  - add more "Executor" scripts
  - create a WPA_CLI error auto-detection against errors like: "Could not connect to wpa_supplicant ... "

=cut
=head1 FUTURE INTENTIONS

  The perl programming language has a wide variety of libraries, it has a good Networking distribution but, excluding the Net::Bluetooth library,
  the bluetooth support doesn't exist.
  In a non-too-remote future I would like to built a library for controlling bluetooth 3.0 and BLE standard, I have some ideas related about the C library  which will be used. 

=cut  

=head1 FOR REQUESTS

EMAIL ME :)

=cut

=head1 COPYRIGHT

       Copyright (c) 2020 Edoardo Mantovani, All Rights Reserved.
 
       This library is free software; you can redistribute it and/or modify it
       under the same terms as Perl itself, either Perl version 5 or, at your
       option, any later version of Perl you may have available (perl and glue
       code).
 
       This library is free software; you can redistribute it and/or modify it
       under the terms of the GNU Lesser General Public License as published
       by the Free Software Foundation; either version 2 of the License, or
       (at your option) any later version.
 
       This library is distributed in the hope that it will be useful, but
       WITHOUT ANY WARRANTY; without even the implied warranty of
       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
       General Public License for more details.




=cut
1;  
