#!/usr/bin/perl
# made by Edoardo Mantovani, 2020

#This example script can be used inside the WirelessCan as small CLI
#it sets the wireless card into monitor mode though airmon-ng and sniff with Net::Pcap, after inserted the input, it catch the packets, wrote the (shannon) entropy linked to the $packet intro a file and finally, create a chart file representing the data


### the TOTAL packet capture is set to 55.000

use strict;
use warnings;
use Net::Pcap;
use Chart::Clicker;
use Shannon::Entropy qw/ entropy/;

no strict 'refs';


sub WPA_CLI(){
  require Net::Wireless::802_11::WPA::CLI;
  my $wpa_cli = Net::Wireless::802_11::WPA::CLI->new(); 
  $wpa_cli->scan();
  foreach ( $wpa_cli->scan_results() ){
    if(! ($_ =~ ":" ) ){
      print $_->{ssid} . "  " . $_->{signallevel};
      print "\n";
  }
    }
}
&WPA_CLI();
my $Network = <STDIN>;
chop( $Network );

my $pcap_err = '';
my $pcap_device;
sub search_interface(){
  require Net::Interface;
  foreach( Net::Interface->interfaces() ){
    if($_ =~ "wl"){
       $pcap_device = $_;
}
    if( $_ =~ "mon" ){
      return $_;
      last;
     }
   }
}

sleep(1);

&search_interface();
`sudo airmon-ng start $pcap_device `;

my $pcap = pcap_open_live( &search_interface(), 1024, 1, 0, \$pcap_err ) or die $!;

open(HASH, '>', $Network);

pcap_loop( $pcap, 55000, \&print_pkt, "");
my $X;
my @X;
my @Length_info;
sub print_pkt(){
  my ( $data, $head, $packet ) = @_;
  foreach( @_ ){
    if( $_ =~ $Network ){
    $X++;
    push @X, entropy( $packet );
    print  HASH entropy( $packet );
    print  HASH " $packet \n";
    print entropy( $packet );
    print "\n";
}
    }
  }


sub shut_up_mon(){
  require Net::Interface;
  foreach(Net::Interface->interfaces() ){
    if( $_ =~ "mon" ){
      `airmon-ng stop $_ `;
     }
}
  }

&shut_up_mon();

close(HASH);
my $res = ( ($X / 55000) * 100 );
print "Packet captured are the $res %\n";
sleep(2);

my $Chart = Chart::Clicker->new(
            height => 1200,
            width  => 2400,
);
$Chart->add_data( 'length', \@X );
my $file = $Network . ".png";
$Chart->write_output( $file );
sleep(1);

