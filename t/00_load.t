BEGIN { $| = 1; print "1..30\n"; }
END {print "not ok 1\n" unless $loaded;}
use Algorithm::FEC;
$loaded = 1;

use File::Temp;

my $fec = new Algorithm::FEC 3, 5, 70;

my $test = 0;

sub ok($) {
   $test++;
   print $_[0] ? "ok $test\n" : "not ok $test\n";
}

my @files = map {
   $fd = tmpfile ();
   syswrite $fd, $_ x 70;
   $_ < 2 ? $fd : [$fd, 0];
} 1..3;

ok 1;

$fec->set_blocks (\@files);

ok 1;

my @blk;

for (0..4) {
   ok 1;

   $blk[$_] = $fec->encode ($_);
}

ok ($blk[0] eq "1" x 70);
ok ($blk[1] eq "2" x 70);
ok ($blk[2] eq "3" x 70);
ok ($blk[3] eq "%" x 70);
ok ($blk[4] eq "Y" x 70);

for ([[0,1,2],[0,1,2]],
     [[0,2,1],[0,2,1]],
     [[0,2,3],[0,2,1]],
     [[4,3,1],[0,2,1]]) {
   my ($idx1, $idx2) = @$_;

   my @blks;

   ok 1;
   my $i;
   for (@$idx1) {
     $blks[$i++] = $_ < 3 ? $files[$_] : $blk[$_];
   }

   $fec->decode (\@blks, $idx1);

   ok 1;

   ok ("@$idx1" eq "@$idx2");

   $i = 0;
   for (@$idx1) {
      $i++;
      next if ref $blks[$_];
      ok ($i x 70 eq $blks[$_]);
   }
}

ok 1;

my $a = "a" x 70;
my $b = "b" x 70;

$fec->copy ($b, $a);

ok $a eq $b;
ok $a eq "b" x 70;

