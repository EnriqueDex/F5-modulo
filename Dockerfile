FROM ubuntu:16.10

use BigIP::ParseConfig;
 
# Module initialization
my $bip = new BigIP::ParseConfig( '/config/bigip.conf' );
 
# Iterate over pools
foreach my $pool ( $bip->pools() ) {
    # Iterate over pool members
    foreach my $member ( $bip->members( $pool ) ) {
        # Change port from 80 to 443
        if ( $member /^(\d+\.\d+\.\d+\.\d+):80/ ) {
            push @members, "$1:443";
            my $change = 1;
        }
    }
    # Commit the change above (80->443)
    if ( $change ) {
        $bip->modify(
            type => 'pool',
            key  => $pool,
            members => [ @members ]
        );
    }
}
 
# Write out a new config file
$bip->write( '/config/bigip.conf.new' );
