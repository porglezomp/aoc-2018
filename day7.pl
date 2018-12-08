:- set_prolog_flag(verbose, silent), prompt(_, '').

use_module(library(readutil)).

read_lines(Stream, []) :- at_end_of_stream(Stream).
read_lines(Stream, [Line|Lines]) :-
    read_line_to_codes(Stream, Line, _),
    read_lines(Stream, Lines).

% Step Y must be finished before step L can begin.
% 0    *    1         2         3     *
% 0123456789012345678901234567890123456
read_pair([83,116,101,112,32,A,32,109,117,115,
           116,32,98,101,32,102,105,110,105,115,
           104,101,100,32,98,101,102,111,114,101,
           32,115,116,101,112,32,B,32,99,97,
           110,32,98,101,103,105,110,46,10], A, B).

?- read_lines(user_input, Lines),
   maplist(read_pair, Lines, As, Bs),
   writeln(As), writeln(Bs).
