:- use_module(mazeInfo, [info/3, wall/2, button/3, num_buttons/1, start/2, goal/2]).

% Main Horne clause to begin application
	main :- currentLocation.

% Write coordinates to file
	writeCoords([], _) :- true.
	writeCoords([H|T], Stream) :- write(Stream, H),
    		   		    		  nl(Stream),
        	   		    		  writeCoords(T, Stream).

% Write path to file
    writePath(Path) :- open('path-solution.txt', write, Stream),
                	   writeCoords(Path, Stream),
                	   close(Stream).

% Horne clauses that dictate how application is run -----------------------------------------------
% Begin application at start location and add coordinates to path and visited lists
	currentLocation :- start(X, Y),
	                   currentLocation(X, Y, [[X, Y]], [[X, Y]], []).

% Check if current location is where the goal is
	currentLocation(X, Y, Path, _, Buttons) :- finish(Buttons, X, Y), !, 
	                              	     	   writePath(Path).

% Click button and move current location to some other valid location while clearing visited list
	currentLocation(X, Y, Path, _, Buttons) :- clickButton(Buttons, X, Y), !, 
											   append(Buttons, [[X, Y]], ButtonsN),
											   step(X, Y, Path, [[X,Y]] , ButtonsN).

% Move current location to some other valid location
	currentLocation(X, Y, Path, Visited, Buttons) :- step(X, Y, Path, Visited, Buttons).

% Movement Horne clauses for valid locations ------------------------------------------------------
% Move North and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- YN is Y-1, 
								 		  validLocation(Visited, X, YN), !, 
				 				 		  append(Path, [[X, YN]], PathN),
				 				 		  append(Visited, [[X, YN]], VisitedN),
	             				 		  currentLocation(X, YN, PathN, VisitedN, Buttons).

% Move South and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- YS is Y+1,
								 		  validLocation(Visited, X, YS), !, 
				 				 	 	  append(Path, [[X, YS]], PathN),
				 				 		  append(Visited, [[X, YS]], VisitedN),
				 				 		  currentLocation(X, YS, PathN, VisitedN, Buttons).

% Move East and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- XE is X+1,
								 		  validLocation(Visited, XE,Y), !, 
				 				 	      append(Path, [[XE, Y]], PathN), 
				 				 		  append(Visited, [[XE, Y]], VisitedN),
	             			 	 		  currentLocation(XE, Y, PathN, VisitedN, Buttons).

% Move West and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- XW is X-1,
								 		  validLocation(Visited, XW,Y), !, 
				 				 		  append(Path, [[XW, Y]], PathN), 
				 				 		  append(Visited, [[XW, Y]], VisitedN),
	             				 		  currentLocation(XW, Y, PathN, VisitedN, Buttons).
 
% Helper Horne clauses ----------------------------------------------------------------------------
% Check if within board
	withinBoard(X, Y) :- info(Width, Height, _),
	                     X < Width,
	                     Y < Height,
	                     X >= 0,
	                     Y >= 0.

% Check if coordinates are in the list
% No coordinate pair matches with desired coordinates
	isInList([], _, _) :- false.
% Desired coordinate pair matches some coordinate pair in the list
	isInList([[X, Y]|_], X, Y).
% Recursively check if desired coordinates are within the list	
	isInList([_|T], X, Y) :- isInList(T, X, Y).

% Calculate the length of a list
% No more elements in the list
	len([], 0).
% Increment accumulator
	len([_|T], A) :- len(T, X),
	                 A is X+1.

% Valid Location Horne clauses --------------------------------------------------------------------
% Check if location is within the board and not a wall and not previously visited
	validLocation(Visited, X, Y) :- withinBoard(X, Y), 
									\+ wall(X, Y), 
	                      			\+ isInList(Visited, X, Y).
    
% Button Horne Clauses ----------------------------------------------------------------------------
    clickButton(Buttons, X, Y) :- button(X, Y, _),
								  \+ isInList(Buttons, X, Y).

% Goal Horne Clauses ------------------------------------------------------------------------------
% Check if location is the goal and all the buttons have been clicked
	finish(Buttons, X, Y) :- goal(X, Y),
							 num_buttons(Amt),
							 len(Buttons, Amt).