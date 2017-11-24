:- use_module(mazeInfo, [info/3, wall/2, button/3, num_buttons/1, start/2, goal/2]).

% Main Horne clause to begin application
	main :- currentLocation.

% File Horne clauses ------------------------------------------------------------------
% Write coordinates to file
	writeCoords([], _) :- true.
	writeCoords([H|T], Stream) :- write(Stream, H),
    		   		    		  nl(Stream),
        	   		    		  writeCoords(T, Stream).

% Write path to file
    writePath(Path) :- open('path-solution.txt', write, Stream),
                	   writeCoords(Path, Stream),
                	   close(Stream).

% Horne clauses that dictate how application is run -----------------------------------
% Begin application at start location and add coordinates to path and visited lists
	currentLocation :- start(X, Y),
	                   currentLocation(X, Y, [[X, Y]], [[X, Y]]).

% Check if current location is where the goal is
	currentLocation(X, Y, Path, _) :- goal(X, Y), !,
	                              	  writePath(Path).

% Move current location to some other valid location
	currentLocation(X, Y, Path, Visited) :- step(X, Y, Path, Visited).

% Movement Horne clauses for valid locations ------------------------------------------
% Move North and add coordinates to path and visited lists
	step(X, Y, Path, Visited) :- YN is Y-1, 
								 validLocation(Visited, X, YN), !,
				 				 append(Path, [[X, YN]], PathN),
				 				 append(Visited, [[X, YN]], VisitedN),
	             				 currentLocation(X, YN, PathN, VisitedN).

% Move South and add coordinates to path and visited lists
	step(X, Y, Path, Visited) :- YS is Y+1,
								 validLocation(Visited, X, YS), !,
				 				 append(Path, [[X, YS]], PathN),
				 				 append(Visited, [[X, YS]], VisitedN),
				 				 currentLocation(X, YS, PathN, VisitedN).

% Move East and add coordinates to path and visited lists
	step(X, Y, Path, Visited) :- XE is X+1,
								 validLocation(Visited, XE,Y), !,
				 				 append(Path, [[XE, Y]], PathN), 
				 				 append(Visited, [[XE, Y]], VisitedN),
	             			 	 currentLocation(XE, Y, PathN, VisitedN).

% Move West and add coordinates to path and visited lists
	step(X, Y, Path, Visited) :- XW is X-1,
								 validLocation(Visited, XW,Y), !, 
				 				 append(Path, [[XW, Y]], PathN), 
				 				 append(Visited, [[XW, Y]], VisitedN),
	             				 currentLocation(XW, Y, PathN, VisitedN).
 
% Helper Horne clauses ---------------------------------------------------------------
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

% Valid Location Horne clauses --------------------------------------------------------
% Check if location is within the board and not a wall and not previously visited
	validLocation(Visited, X, Y) :- withinBoard(X, Y), 
									\+ wall(X, Y), 
	                      			\+ isInList(Visited, X, Y).