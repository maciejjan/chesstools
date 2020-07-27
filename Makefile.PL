use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'chesstools',
  VERSION       => '0.2.1-alpha',
  EXE_FILES     => ["bin/drawboard", "bin/makemoves", "bin/pgnindex",
                    "bin/pgnvi"],
  PREREQ_PM     => {
    "Chess::Rep"                    => 0,
    "Chess::PGN::Parse"             => 0,
    "Chess::PGN::Parse::FileHandle" => 0,
    "Curses"                        => 0,
    "Tk"                            => 0,
    "Tk::PNG"                       => 0,
    "Try::Tiny"                     => 0,
    "Pod::Usage"                    => 0,
  }
);
