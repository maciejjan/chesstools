# TODO

## pgnvi

- creating a new file and adding a new game
- non-standard starting positions (the `FEN` tag)
- searching and filtering game lists
- improvements in the tree view:
  - compress nodes with only one child
- scrolling of the move list
- implement "redo"
- fixing numerous bugs
- rebinding keys (including the append mode keyboard)
- customizability in general
- more user-friendly UI
- (?) interface to UCI chess engines (e.g. Stockfish)
- save non-standard tags
- much more...

### Bugs

- if a board window is closed, pgnvi still tries to write to the pipe and
  crashes
- sometimes when hitting `b` in the game view, the board doesn't open (or opens
  and closes immediately?) and the editor exits the game view
- lines are not truncated in the list view
- game screen crashes on an illegal move
- adding variant + delete-and-append from the first move of the variant --
  the variant's identifier (first move) is not updated

## drawboard

- some rudimentary customization, e.g. square colors

