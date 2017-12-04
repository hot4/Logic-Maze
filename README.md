# Logic-Maze

Group Members: Timothy Ho, Uyen Uong

Features: 
The mazesolver.pl program will determine a path for Einstein to go through, based on the type {a, b, c}, to solve the maze. Type a will find any path between the starting point and the goal. Type b will find a path that pushes all buttons before reaching the goal. Type c will find a path that pushes all buttons in numeric order before reaching the goal. For types b and c, Einstein will always push the button if Einstein is on top of it. After finding a path, the path is written to a file. The NLParser.pl program takes in a file where each line is a sentence and uses Definite Claus Grammars to parse the sentences and move the mouse if it is a valid move. Invalid sentences are ignored. Once a invalid move is found, the program terminates. Information about parsed sentences are written to a file.

Bugs:
There are no known bugs, however, on our machines we had to change the name of file NLParser.pl to nLParser.pl in order to run it. We changed the name back to NLParser.pl but just in case it does not work, we included this comment.