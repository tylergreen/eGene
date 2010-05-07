-module(genetic).
-compile(export_all).

%% pattern matching is a must for this type of work

% step 1: Make Code into Data -- have to do this in haskell too
% still its an extra step

evaluate({const, X}, _) -> X;
evaluate({param, N}, Input) -> lists:nth(N, Input);

evaluate({node, {F, Args}}, Input) -> F(lists:map(fun(X) ->
							 evaluate(X, Input)
						 end,
						 Args));

evaluate({node, {ifst, Test, Conseq, Alt}}, Input) ->
    case evaluate(Test, Input) of
	false -> evaluate(Alt, Input);
	[] -> evaluate(Alt, Input);
	_ -> evaluate(Conseq, Input)
    end.


% Primitives
% have to do this bc erlang is totally lame. 
% Would be super easy in haskell/factor
% actually I think there is a better way to do this
add(X,Y) -> X + Y.
sub(X,Y) -> X - Y.
mult(X,Y) -> X * Y.
grt(X, Y) -> X > Y.
eql(X, Y) -> X == Y.
     
% step 2: Code Manipulation

% random binary fun!  Want to make this more general
randomfn() ->
    Fns = [fun add/2, fun sub/2, fun mult/2, fun grt/2, fun eql/2],
    N = random:uniform(length(Fns)),
    lists:nth(N, Fns).

% mutate({binop, {_, X, Y}}) -> {binop, {random_fn(), X, Y}};
%mutate(_) -> randomtree();

one_of(Xs) ->
    R = random:uniform(lists:length(Xs)),
    lists:nth(R, Xs).

% can definitely clean all this up -- too hacky
mutate({node, {ifstmt, [X, Y, Z]}}) ->
    one_of([ X,
	     Z,
	     {randomfn(), X, Y},
	     {randomfn(), X, Z},
	     {randomfn(), Z, Y}
	    ]);

% can add more
mutate({node, {_, Args}}) -> one_of(Args).

-define(Threshold, 0.7).

% mating
% takes two trees as input and traverses down both of them


crossover({node, {F, Args1}},{node, {_, Args2}}) ->   
    {node, {F, crossover_map(Args1, Args2) }};
crossover(X, _) -> X.

% has to better a better way to do this without mutually recursive fns
% erlang is not statically typed should be able to do better
crossover_map(Xs, Ys) -> lists:map(fun(C) ->
					   crossover_aux(C, one_of(Xs))
					   end,
					   Ys).

crossover_aux({node, {F, Args1}},{node, {_, Args2}}) ->
    case random:uniform() < ?Threshold of
	true -> {node, {F, Args1}};  % no @ pattern sucks !!!
	false -> {node, {F, crossover_map(Args1, Args2) }}
    end;
crossover_aux(X, _) -> X.




