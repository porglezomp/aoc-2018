:- set_prolog_flag(verbose, silent).
:- prompt(_, '').
:- dynamic before/2.
:- dynamic task/1.

use_module(library(readutil)).

read_input -->
   "Step ", [A], " must be finished before step ", [B], " can begin.\n",
   { assertz(before(A, B)),
     (task(A) ; assertz(task(A))),
     (task(B) ; assertz(task(B))) },
   (read_input ; { true }).

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

% Generate a graphviz file for the input
write_graph(Filename) :-
   open(Filename, write, Os),
   findall([A, B], before(A, B), Xs),
   writeln(Os, "digraph G {"),
   maplist(format(Os, "  ~c -> ~c~n"), Xs),
   writeln(Os, "}").

?- phrase_from_file(read_input, 'input/day7'),
   write_graph("day7.dot"),
   findall(X, task(X), Tasks),
   toposort(Tasks, Sorted),
   string_codes(Message, Sorted),
   writeln(Message),
   work_queue(5, Tasks, Tasks, [], 0, Time, _),
   writeln(Time),
   halt.
