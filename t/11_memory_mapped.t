use strict;
use warnings;

use Test::More tests => 1;

use PDL;
use PDL::Parallel::threads qw(retrieve_pdls);
use PDL::IO::FastRaw;

my $N_threads = 100;
mapfraw('foo.dat', {Creat => 1, Dims => [$N_threads], Datatype => double})
	->share_as('workspace');

use threads;

# Spawn a bunch of threads that do the work for us
use PDL::NiceSlice;
threads->create(sub {
	my $tid = shift;
	my $workspace = retrieve_pdls('workspace');
	$workspace($tid) .= sqrt($tid + 1);
}, $_) for 0..$N_threads-1;

# Reap the threads
for my $thr (threads->list) {
	$thr->join;
}

my $expected = (sequence($N_threads) + 1)->sqrt;
my $workspace = retrieve_pdls('workspace');
ok(all($expected == $workspace), 'Sharing memory mapped piddles works');

END {
	# Clean up the testing files
	unlink $_ for qw(foo.dat foo.dat.hdr);
}
