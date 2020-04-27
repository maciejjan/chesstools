#!/usr/bin/perl

use Curses;
use utf8;

use Chess::Rep;
use Chess::PGN::Parse;

use constant {
  WHITE_ON_LIGHT => 1,
  WHITE_ON_DARK => 2,
  BLACK_ON_LIGHT => 3,
  BLACK_ON_DARK => 4,
  MOVE_NUMBER => 5
};

my %PCS = (
  0x01 => '♟', 0x02 => '♞', 0x04 => '♚',
  0x08 => '♝', 0x10 => '♜', 0x20 => '♛'
);

# TODO (for v 0.1)
# - "k" jumps a move back
# - scrolling of the move list
# - showing comments under the board
# - variants
# - opening a file from CLI argument
# TODO: input -- two modes:
# - "normal" - input the fields like they are on the keyboard
# - "expert":
#   ASDFJKL: = ABCDEFGH
#   QWERUIOP = 12345678
#   CVBNM    = RNBQK
#   e.g. vje = Nf3
#        jr = e4
#        ju = e5
#        vdi = Nc6

my $pos = new Chess::Rep;

my $pgn = new Chess::PGN::Parse "$ARGV[0]"
  || die "Could not open file: $ARGV[0]";
$pgn->read_game();
$pgn->parse_game({save_comments => 'yes', comments_struct => 'array'});

my $moves = $pgn->moves;
my $comments = $pgn->comments;

for my $k (keys %$comments) {
  print $k." ".(join ";", @{$comments->{$k}})."\n";
}

sub draw_board {
  my $pos = shift;
  my $win = shift;
  my $x = shift;
  my $y = shift;
  for (my $i = 0; $i < 8; $i++) {
    for (my $j = 0; $j < 8; $j++) {
      my $piece = $pos->get_piece_at($i << 4 | $j);
      my $col = 1 + ($i+$j+1) % 2 + ($piece < 0x80)*2;
      $win->attron(COLOR_PAIR($col));
      my $pc = $piece ? $PCS{$piece & 0x7F} : " ";
      $win->addstring($y+7-$i, $x+3*$j, " $pc ");
    }
  }
}

sub draw_moves {
  my $moves = shift;
  my $cur_move = shift;
  my $win = shift;
  my $x = shift;
  my $y = shift;
  my $cur = "1. ";
  my ($cx, $cy) = ($x, $y);
  my ($maxy, $maxx);
  $win->getmaxyx($maxy, $maxx);
  for (my $i = 0; $i <= $#$moves; $i++) {
    my $mn = int($i/2+1).".";
    if ($i % 2 == 0) {
      if ($cx + length("$mn $moves->[$i] $moves->[$i+1]") > $maxx) {
        $cx = $x;
        $cy++;
        last if $cy > $y+7;
      }
      $win->attron(COLOR_PAIR(MOVE_NUMBER));
      $win->addstring($cy, $cx, "$mn");
      $win->attroff(COLOR_PAIR(MOVE_NUMBER));
      $cx += length($mn) + 1;
    } 
    if ($i+1 == $cur_move) { $win->attron(A_REVERSE); }
    $win->addstring($cy, $cx, $moves->[$i]);
    $cx += length($moves->[$i]) + 1;
    if ($i+1 == $cur_move) { $win->attroff(A_REVERSE); }
  }
}

my $win = new Curses;

initscr;
raw;
keypad($win, 1);
noecho();
curs_set(0);

start_color;
use_default_colors;

init_pair(WHITE_ON_LIGHT, 231, 178);
init_pair(WHITE_ON_DARK, 231, 94);
init_pair(BLACK_ON_LIGHT, 0, 178);
init_pair(BLACK_ON_DARK, 0, 94);
init_pair(5, COLOR_RED, -1);

my $moves = $pgn->moves;
my $comments = $pgn->comments;
my $cur_move = 0;

my ($c, $key);
while (!($c eq 'q')) {
  $win->clear;
  draw_board($pos, $win, 1, 0);
  $win->attroff(COLOR_PAIR(1));
  draw_moves($moves, $cur_move, $win, 26, 0);
  my $cm2 = int($cur_move/2+0.5) . ($cur_move % 2 == 1 ? "w" : "b");
  if (defined($comments->{$cm2})) {
    my $j = 0;
    for $c (@{$comments->{$cm2}}) {
      $win->addstring(9+$j, 0, $c);
      $j++;
    }
  }

  ($c, $key) = $win->getchar();
  if ($c eq 'j') {
    $pos->go_move($moves->[$cur_move++]);
  }
}

endwin;
