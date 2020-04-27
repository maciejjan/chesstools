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

our %PCS = (
  0x01 => '♟', 0x02 => '♞', 0x04 => '♚',
  0x08 => '♝', 0x10 => '♜', 0x20 => '♛'
);

our %GAME = (
  pos => undef,
  positions => undef,
  moves => undef,
  comments => undef,
  cur => undef,
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

$GAME{pos} = new Chess::Rep;

my $pgn = new Chess::PGN::Parse "$ARGV[0]"
  || die "Could not open file: $ARGV[0]";
$pgn->read_game();
$pgn->parse_game({save_comments => 'yes', comments_struct => 'array'});

$GAME{moves} = $pgn->moves;
$GAME{comments} = $pgn->comments;
$GAME{cur} = 0;

my $pos = new Chess::Rep;
$GAME{positions} = [$pos->get_fen];
for (my $i = 0; $i <= $#{$GAME{moves}}; $i++) {
  $pos->go_move($GAME{moves}->[$i]);
  push @{$GAME{positions}}, $pos->get_fen;
}

sub draw_board {
  my $win = shift;
  my $x = shift;
  my $y = shift;
  for (my $i = 0; $i < 8; $i++) {
    for (my $j = 0; $j < 8; $j++) {
      my $piece = $GAME{pos}->get_piece_at($i << 4 | $j);
      my $col = 1 + ($i+$j+1) % 2 + ($piece < 0x80)*2;
      $win->attron(COLOR_PAIR($col));
      my $pc = $piece ? $PCS{$piece & 0x7F} : " ";
      $win->addstring($y+7-$i, $x+3*$j, " $pc ");
    }
  }
}

sub draw_moves {
  my $win = shift;
  my $x = shift;
  my $y = shift;
  my ($cx, $cy) = ($x, $y);
  my ($maxy, $maxx);
  $win->getmaxyx($maxy, $maxx);
  for (my $i = 0; $i <= $#{$GAME{moves}}; $i++) {
    my $mn = int($i/2+1).".";
    if ($i % 2 == 0) {
      if ($cx + length("$mn $GAME{moves}->[$i] $GAME{moves}->[$i+1]") > $maxx) {
        $cx = $x;
        $cy++;
        last if $cy > $y+7;
      }
      $win->attron(COLOR_PAIR(MOVE_NUMBER));
      $win->addstring($cy, $cx, "$mn");
      $win->attroff(COLOR_PAIR(MOVE_NUMBER));
      $cx += length($mn) + 1;
    } 
    if ($i+1 == $GAME{cur}) { $win->attron(A_REVERSE); }
    $win->addstring($cy, $cx, $GAME{moves}->[$i]);
    $cx += length($GAME{moves}->[$i]) + 1;
    if ($i+1 == $GAME{cur}) { $win->attroff(A_REVERSE); }
  }
}

sub draw_comments {
  my $win = shift;
  my $x = shift;
  my $y = shift;

  my $cm2 = int($GAME{cur}/2+0.5) . ($GAME{cur} % 2 == 1 ? "w" : "b");
  if (defined($GAME{comments}->{$cm2})) {
    my $j = 0;
    for $c (@{$GAME{comments}->{$cm2}}) {
      $win->addstring($y+$j, $x, $c);
      $j++;
    }
  }
}

sub draw {
  my $win = shift;

  $win->clear;
  draw_board($win, 1, 0);
  $win->attroff(COLOR_PAIR(1));
  draw_moves($win, 26, 0);
  draw_comments($win, 0, 9);
}

sub key_pressed {
  my $c = shift;
  my $key = shift;

  if ($c eq 'g') {
    $GAME{cur} = 0;
    $GAME{pos}->set_from_fen($GAME{positions}->[$GAME{cur}]);
  } elsif ($c eq 'G') {
    $GAME{cur} = $#{$GAME{moves}}+1;
    $GAME{pos}->set_from_fen($GAME{positions}->[$GAME{cur}]);
  } elsif ($c eq 'j') {
    if ($GAME{cur} <= $#{$GAME{moves}}) { $GAME{cur}++; }
    $GAME{pos}->set_from_fen($GAME{positions}->[$GAME{cur}]);
  } elsif ($c eq 'k') {
    if ($GAME{cur} > 0) { $GAME{cur}--; }
    $GAME{pos}->set_from_fen($GAME{positions}->[$GAME{cur}]);
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
init_pair(MOVE_NUMBER, COLOR_RED, -1);

my ($c, $key);
while (!($c eq 'q')) {
  draw $win;
  ($c, $key) = $win->getchar();
  key_pressed $c, $key;
}

endwin;
