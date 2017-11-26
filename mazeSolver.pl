:- use_module(mazeInfo, [info/3, wall/2, button/3, num_buttons/1, start/2, goal/2]).

% Main Horne clause to begin application
	main :- currentLocation, !.

% Write coordinates to file
	writeCoords([], _) :- true.
	writeCoords([H|T], Stream) :- write(Stream, H),
    		   		    		  nl(Stream),
        	   		    		  writeCoords(T, Stream).

% Write path to file
    writePath(Path) :- open('path-solution.txt', write, Stream),
                	   writeCoords(Path, Stream),
                	   close(Stream).

% Horne clauses that dictate how application is run ------------------------------------------------------------------
% Begin application at start location and add coordinates to path and visited lists and start with no buttons clicked
	currentLocation :- start(X, Y),
	                   currentLocation(X, Y, [[X, Y]], [[X, Y]], []).

% Check if current location is where the goal is
	currentLocation(X, Y, Path, _, Buttons) :- finish(Buttons, X, Y),
                              	         	   writePath(Path).

% Click button and move current location to some other valid location while clearing visited list
	currentLocation(X, Y, Path, _, Buttons) :- \+ checkType(a),
											   clickButton(Buttons, X, Y),
									   		   append(Buttons, [[X, Y]], ButtonsN),
									           step(X, Y, Path, [[X, Y]], ButtonsN).

% Move current location to some other valid location only only if 
%     current location is not a button and buttons have been clicked in the proper order 
	currentLocation(X, Y, Path, Visited, Buttons) :- checkType(c),
													 \+ button(X, Y, _),
													 btnOrder(Buttons, 1),
                                                     step(X, Y, Path, Visited, Buttons).

    currentLocation(X, Y, Path, Visited, Buttons) :- \+ checkType(c),
    												 step(X, Y, Path, Visited, Buttons).                                                     

% Movement Horne clauses for valid locations -------------------------------------------------------------------------
% Move North and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- YN is Y-1, 
						 		  		  validLocation(Visited, X, YN),
		 				 		  		  append(Path, [[X, YN]], PathN),
		 				 		  		  append(Visited, [[X, YN]], VisitedN),
         				 		  		  currentLocation(X, YN, PathN, VisitedN, Buttons).

% Move South and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- YS is Y+1,
						 		  		  validLocation(Visited, X, YS),
		 				 	 	  		  append(Path, [[X, YS]], PathN),
		 				 		  		  append(Visited, [[X, YS]], VisitedN),
		 				 		  		  currentLocation(X, YS, PathN, VisitedN, Buttons).

% Move East and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- XE is X+1,
						 		  		  validLocation(Visited, XE,Y), 
		 				 	      		  append(Path, [[XE, Y]], PathN), 
		 				 		  		  append(Visited, [[XE, Y]], VisitedN),
         			 	 		  		  currentLocation(XE, Y, PathN, VisitedN, Buttons).

% Move West and add coordinates to path and visited lists
	step(X, Y, Path, Visited, Buttons) :- XW is X-1,
						 		  		  validLocation(Visited, XW,Y),
		 				 		  		  append(Path, [[XW, Y]], PathN), 
		 				 		  		  append(Visited, [[XW, Y]], VisitedN),
         				 		  		  currentLocation(XW, Y, PathN, VisitedN, Buttons).
 
% Helper Horne clauses -----------------------------------------------------------------------------------------------
% Check the test type of maze
	checkType(Type) :- info(_, _, Type).

% Check if within board
	withinBoard(X, Y) :- info(Width, Height, _),
	                     X < Width,
	                     Y < Height,
	                     X >= 0,
	                     Y >= 0.

% Check if coordinates are in list
% No coordinate pair matches with desired coordinates
	isInList([], _, _) :- false.
% Desired coordinate pair matches some coordinate pair in the list
	isInList([[X, Y]|_], X, Y).
% Recursively check if desired coordinates are within the list	
	isInList([_|T], X, Y) :- isInList(T, X, Y).

% Calculate the length of a list
% No elements in the list
	len([], 0).
% Increment accumulator
	len([_|T], A) :- len(T, X),
	                 A is X+1.
	
% Valid Location Horne clauses ---------------------------------------------------------------------------------------
% Check if location is within the board and not a wall and not previously visited
	validLocation(Visited, X, Y) :- withinBoard(X, Y), 
									\+ wall(X, Y), 
	                      			\+ isInList(Visited, X, Y).
    
% Button Horne Clauses -----------------------------------------------------------------------------------------------
    clickButton(Buttons, X, Y) :- button(X, Y, _),
    							  \+ isInList(Buttons, X, Y).

% Determine if order of buttons are proper in ascending order
% No elements in the list
    btnOrder([], _).
% If head of list matches the specified button number, recursively check the next element in the list
    btnOrder([[X, Y]|T], BtnNum) :- button(X, Y, BtnNum),
    							    BtnNumN is BtnNum+1, 
    							    btnOrder(T, BtnNumN).

% Goal Horne Clauses -------------------------------------------------------------------------------------------------
% Check if location is the goal and all the buttons have been clicked
% For test types b and c
	finish(Buttons, X, Y) :- \+ checkType(a),
							 goal(X, Y),
							 num_buttons(Amt),
							 len(Buttons, Amt).
% For test type a
    finish(_, X, Y) :- checkType(a), 
    	               goal(X, Y).