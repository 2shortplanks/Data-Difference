#!perl

use Test::More;
use Test::Differences;

BEGIN { use_ok('Data::Difference', 'data_diff'); }

package over;
use overload '""' => sub { $_[0]->{thing} }, fallback => 1;
sub new {
  my $class = shift;
  my $thing = shift;
  return bless { thing => $thing }, $class
}

package main;

my $one = over->new("one");
my $uno = over->new("one");
my $two = over->new("two");

my @tests = (
  {a => undef, b => undef, out => []},
  {a => 1,     b => 2,     out => [{path => [], a => 1, b => 2}]},
  {a => [1, 2, 3], b => [1, 2], out => [{path => [2], a => 3}]},
  {a => [1, 2], b => [1, 2, 3], out => [{path => [2], b => 3}]},
  { a   => {Q => 1, W => 2, E => 3},
    b   => {W => 4, E => 3, R => 5},
    out => [  ##
      {path => ['Q'], a => 1},
      {path => ['R'], b => 5},
      {path => ['W'], a => 2, b => 4},
    ]
  },

  # overload tests

  { a => $one, b => $one, out => [] },
  { a => $one, b => $uno, out => [] },
  { a => $two, b => $one, out => [ { path => [], a => $two, b => $one } ] },

  { a => [$one], b => [$one], out => [] },
  { a => [$one], b => [$uno], out => [] },
  { a => [$two], b => [$one], out => [ { path => [ 0 ], a => $two, b => $one } ] },

  { a => { t => $one }, b => { t => $one }, out => [] },
  { a => { t => $one }, b => { t => $uno }, out => [] },
  { a => { t => $two }, b => { t => $one }, out => [ { path => [ 't' ], a => $two, b => $one } ] },

  { a => "one", b => $one, out => [] },
  { a => $one, b => "one", out => [] },

  { a => ["one"], b => [$one], out => [] },
  { a => [$one], b => ["one"], out => [] },

  { a => { t => "one"}, b => { t => $one }, out => [] },
  { a => { t => $one}, b => { t => "one" }, out => [] },
);

foreach my $t (@tests) {
  eq_or_diff([data_diff($t->{a}, $t->{b})], $t->{out});
}

done_testing();
