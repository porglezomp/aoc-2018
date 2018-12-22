:- set_prolog_flag(verbose, silent).
:- prompt(_, '').
:- dynamic before/2.
:- dynamic task/1.

use_module(library(readutil)).

read_lines(Stream, []) :- at_end_of_stream(Stream).
read_lines(Stream, [Line|Lines]) :-
    read_line_to_codes(Stream, Line, _),
    read_lines(Stream, Lines).

% Step Y must be finished before step L can begin.
% 0    *    1         2         3     *
% 0123456789012345678901234567890123456
add_relation([
    83,116,101,112,32,A,32,109,117,115,
    116,32,98,101,32,102,105,110,105,115,
    104,101,100,32,98,101,102,111,114,101,
    32,115,116,101,112,32,B,32,99,97,
    110,32,98,101,103,105,110,46,10]) :-
    assert(before(A, B)),
    (task(A) ; assert(task(A))),
    (task(B) ; assert(task(B))).

has_prec(Ls, X) :- member(Y, Ls), before(Y, X).
toposort([], []).
toposort(Xs, [H|T]) :-
  exclude(has_prec(Xs), Xs, Exposed),
  member(H, Exposed),
  select(H, Xs, Rest),
  min_list(Exposed, H),
  toposort(Rest, T).

?- open('input/day7', read, Stream),
   read_lines(Stream, Lines),
   maplist(add_relation, Lines),
   findall(X, task(X), Tasks), !,
   toposort(Tasks, Sorted),
   string_codes(Message, Sorted),
   writeln(Message),
   halt.

% write_edge([Os, A, B]) :-
%   write(Os, "  "), write(Os, A), write(Os, " -> "), writeln(Os, B).
%
% ?- open("day7.dot", write, Os),
%    findall([Os, A, B], before(A, B), Xs),
%    writeln(Os, "digraph G {"),
%    maplist(write_edge, Xs),
%    writeln(Os, "}").
