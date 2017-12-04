:- use_module(mazeInfo, [info/3, wall/2, button/3, num_buttons/1, start/2, goal/2]).

% Setting up the definitive clause grammar ---------------------------------------------------------------------------------------
% The words that the parser needs to understand
article --> ["a"] | ["the"].
subject --> ["rat"] | ["rodent"].
pronoun --> ["einstein"] | ["he"] | ["it"].
verb --> ["ran"] | ["moved"] | ["pushed"] | ["scurried"].
object --> ["square"] | ["squares"] | ["cell"] | ["cells"] | ["button"].

digit(1) --> ["1"].
digit(2) --> ["2"].
digit(3) --> ["3"]. 
digit(4) --> ["4"]. 
digit(5) --> ["5"]. 
digit(6) --> ["6"]. 
digit(7) --> ["7"]. 
digit(8) --> ["8"]. 
digit(9) --> ["9"].

direction(up) --> ["up"].
direction(down) --> ["down"]. 
direction(left) --> ["left"]. 
direction(right) --> ["right"].

% Defining what a sentence consists of and its parts
% Using features to extract the number of squares to use and the direction for sentences that move the mouse
sentence(Num, Dir) --> subject_phrase, verb_phrase(Num, Dir).
sentence --> subject_phrase, verb_phrase.

subject_phrase --> article, subject; pronoun.

verb_phrase(Num, Dir) --> verb, direction_phrase(Num, Dir).
verb_phrase --> verb, object_phrase.

direction_phrase(Num, Dir) --> digit(Num), object, direction(Dir).

object_phrase --> article, object.

% MAIN FUNCTION ---------------------------------------------------------------------------------------
main :-
    open('NL-input.txt', read, Str),
    read_file(Str,Lines),
    %Convert the lines in file to an list of sentences that are lists of words
    lines_to_words(Lines, Words),
    close(Str), !,

    % Open the stream to the output file and check the sentences
    open('NL-parse-solution.txt', write, Stream),
    start(X,Y),
    checkSentences(Words, X, Y, Stream),
    %% write(Stream, Words),
    close(Stream), !.


% Credit to StackOverflow and author Ishq for file parser
% https://stackoverflow.com/a/4805931
% https://stackoverflow.com/users/577045/ishq
read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+ at_end_of_stream(Stream),
    read(Stream,X),
    read_file(Stream,L).

% Converts sentence to a list of words
lines_to_words([], []).
lines_to_words([H|T], [H2|T2]) :-
	split_string(H, " ", "", H2),
	lines_to_words(T, T2).

% Checking the sentences to make sure they are in the correct structure --------------------------------------
/* Used to go through the list of sentences and checking if they are valid sentences
   Only checks one sentence at a time (because need to know new mouse location if mouse moves and
                                        if it is not a valid move then stop parsing sentences) */
checkSentences([], _, _, _) :- true.
checkSentences([H|T], X, Y, Stream) :- isSentence(H, X, Y, Stream, T).

% Check if the list of words is a sentence (must be in the form for moving the mouse or pressing a button)
% Takes in a list of words, the current X and Y position of the mouse, the output stream and the rest of the sentences to look at
isSentence(S, X, Y, Stream, RestofSents) :- (isMovingSentence(S, X, Y, Stream, RestofSents); 
                                             isButtonSentence(S, X, Y, Stream, RestofSents)), 
                                            !.
isSentence(_, X, Y, Stream, RestofSents) :- write(Stream, "Not a valid sentence"), 
                                            nl(Stream), 
                                            checkSentences(RestofSents, X, Y, Stream).

% Check if the given list of words is a sentence in the structure for moving Einstein
% If it is, then check if it is a valid move
% Takes in a list of words, an X and Y position of the mouse, the output stream and the rest of the sentences to look at
isMovingSentence(S, X, Y, Stream, RestofSents) :- sentence(Num, Dir, S, []), 
                                                  moveMouse(Num, Dir, X, Y, Stream, RestofSents).

% Check if the given list of words is a sentence in the structure for pressing a button
% If it is, then check is it is a valid move by trying to press a button at the given location
% Takes in a list of words, an X and Y position of the mouse, the output stream and the rest of the sentences to look at
isButtonSentence(S, X, Y, Stream, RestofSents) :- sentence(S, []),
                                                  pressButton(X,Y, Stream, RestofSents).

% Checking if the sentence is a valid move --------------------------------------------------------------
% Checking if the mouse is on a button to press
% Takes in the current location of the mouse as an X and Y position, the output stream and the rest of the sentences to look at
% If this is not a valid move, then stop parsing sentences
pressButton(X, Y, Stream, RestofSents) :- button(X, Y, _), !, 
                                          write(Stream, "Valid move"), 
                                          nl(Stream),
                                          checkSentences(RestofSents, X, Y, Stream).
pressButton(_, _, Stream, _) :- write(Stream, "Not a valid move"), nl(Stream).

% Determines how to move the mouse based on the sentence and checks if it is a valid move
% If this is not a valid move, then stop parsing sentences
moveMouse(Num, Dir, X, Y, Stream, RestofSents) :- step(Num, Dir, X, Y, Stream, RestofSents), !.
moveMouse(_, _, _, _, Stream, _) :- write(Stream, "Not a valid move"),
                                    nl(Stream).

% Base case for recursive stepping 1 cell at a time
% If was able to make it to them end then this is a valid move so go check the next sentence
step(0, _, X, Y, Stream, RestofSents) :- write(Stream, "Valid move"), 
                                         nl(Stream),
                                         checkSentences(RestofSents, X, Y, Stream).

% Moving the mouse 1 cell up
step(Num, Dir, X, Y, Stream, RestofSents) :- Dir == up, 
                                             YN is Y-1, 
                                             validLocation(X,YN), 
                                             NumLeft is Num-1, !, 
                                             step(NumLeft, Dir, X, YN, Stream, RestofSents).

% Moving the mouse 1 cell down
step(Num, Dir, X, Y, Stream, RestofSents) :- Dir == down, 
                                             YS is Y+1, 
                                             validLocation(X,YS), 
                                             NumLeft is Num-1, !, 
                                             step(NumLeft, Dir, X, YS, Stream, RestofSents).

% Moving the mouse 1 cell right
step(Num, Dir, X, Y, Stream, RestofSents) :- Dir == right, 
                                             XR is X+1, 
                                             validLocation(XR,Y), 
                                             NumLeft is Num-1, !, 
                                             step(NumLeft, Dir, XR, Y, Stream, RestofSents).

% Moving the mouse 1 cell left
step(Num, Dir, X, Y, Stream, RestofSents) :- Dir == left, 
                                             XL is X-1, 
                                             validLocation(XL,Y), 
                                             NumLeft is Num-1, !, 
                                             step(NumLeft, Dir, XL, Y, Stream, RestofSents). 

% Checks if the given location is inside the board and not a wall
validLocation(X, Y) :- withinBoard(X, Y), 
                       \+ wall(X, Y).

% Checks if the given location is within the board
withinBoard(X, Y) :- info(Width, Height, _),
                     X < Width,
                     Y < Height,
                     X >= 0,
                     Y >= 0.






