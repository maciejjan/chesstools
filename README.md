# chesstools

This package provides a suite of minimalist tools for chess study following the
UNIX philosophy. Each of the tools does only one thing and they can be easily
combined with each other as well as with other system tools using pipes.

The following tools are currently provided:
- **drawboard** reads a position in FEN notation from the standard input and
  draws it,
- **makemoves** reads moves and outputs the resulting position (also checking
  whether the moves are valid),
- **pgnvi** is a curses-based editor for PGN files, allowing for browsing,
  searching, commenting and writing games. A more elaborate description is
  given below.

The tools use existing Perl modules for manipulating chess data, namely
`Chess::Rep` and `Chess::PGN::Parse`, wherever possible.

# Installation

TODO

# Examples

The simplest useful pipe is:
```
makemoves | drawboard
```
which allows for typing in moves and seeing them on the board.

When using such pipes interactively, beware of the buffering of I/O streams,
which will prevent the next tool in the pipe from receiving the input
immediately. Some system tools have flags to disable buffering, for example
`sed -u`.

The following pipe reads the move using Polish piece abbreviations, e.g. G =
goniec = bishop:

```
sed -u 'y/KHWGS/KQRBN/' | makemoves | drawboard
```

For non-interactive and non-subprocess use, e.g. if you want to see one
specific position, you might want to use `drawboard` with the `-l` flag, which
will prevent it from terminating when the input stream is closed:
```
echo "d4 Nf6 c4 e6 Nf3 b6 e3 Bb7" | makemoves | drawboard -l
```

# pgnvi

TODO

# Author

Maciej Janicki

