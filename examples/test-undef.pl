use strict;
use warnings;

use PDL;
use PDL::Parallel::threads qw(retrieve_pdl);
use PDL::Parallel::threads::SIMD qw(barrier_sync launch_simd);
my $piddle = zeroes(20);
$piddle->share_as('test');
undef($piddle);

my $N_threads = 5;

use PDL::NiceSlice;
launch_simd($N_threads, sub {
	my $tid = shift;
	my $piddle = retrieve_pdl('test');
	
	print "Thread id $tid says the piddle is $piddle\n";
	barrier_sync;

	my $N_data_to_fix = $piddle->nelem / $N_threads;
	my $idx = sequence($N_data_to_fix) * $N_threads + $tid;
	$piddle($idx) .= $tid;
	barrier_sync;
	
	print "After set, thread id $tid says the piddle is $piddle\n";
	barrier_sync;
	
	$piddle->set($tid, 0);
	barrier_sync;
	
	print "Thread id $tid says the piddle is now $piddle\n";
});


print "Final piddle value is $piddle\n";