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
next_task(Pending, Tasks, T, Rest) :-
   exclude(has_prec(Pending), Tasks, Exposed),
   min_list(Exposed, T),
   select(T, Tasks, Rest).

toposort([], []).
toposort(Xs, [H|T]) :-
   next_task(Xs, Xs, H, Rest),
   toposort(Rest, T).

add_work(NumWorkers, Pending, Tasks, Jobs, JobsOut, Rest) :-
   % Add new jobs as long as they're available and there's space
   length(Jobs, JobLen), JobLen < NumWorkers,
   next_task(Pending, Tasks, T, RestTasks),
   add_work(NumWorkers, Pending, RestTasks, [job(T, 60 + T - 64) | Jobs], JobsOut, Rest)
 ; Jobs = JobsOut, Tasks = Rest.

work_on(N, job(X, M), job(X, K)) :- K is M - N.
work_queue(_, [], [], [], Time, Time, []).
work_queue(NumWorkers, Pending, Tasks, Jobs, Time, TOut, [X|T]) :-
   add_work(NumWorkers, Pending, Tasks, Jobs, NewJobs, NewTasks), !,
   % Pick a job that will finish soonest (in N seconds)
   select(job(X, N), NewJobs, RestJobs),
   forall(member(job(_, M), RestJobs), N =< M), !,
   % Work on all the other work
   maplist(work_on(N), RestJobs, WorkedJobs),
   % When a job finishes, it potentially exposes new available tasks
   subtract(Pending, [X], NowPending),
   % Continue working with the remaining jobs
   NextTime is Time + N,
   work_queue(NumWorkers, NowPending, NewTasks, WorkedJobs, NextTime, TOut, T).

?- open('input/day7', read, Stream),
   read_lines(Stream, Lines),
   maplist(add_relation, Lines),
   findall(X, task(X), Tasks), !,
   toposort(Tasks, Sorted),
   string_codes(Message, Sorted),
   writeln(Message), !,
   work_queue(5, Tasks, Tasks, [], 0, Time, _),
   writeln(Time).

% Generate a graphviz file for the input
write_edge([Os, A, B]) :-
   write(Os, "  "), write(Os, A), write(Os, " -> "), writeln(Os, B).

?- open("day7.dot", write, Os),
   findall([Os, A, B], before(A, B), Xs),
   writeln(Os, "digraph G {"),
   maplist(write_edge, Xs),
   writeln(Os, "}").

?- halt.
