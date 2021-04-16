# COP4600 - Operating Systems
## The Nutshell Term Project

### By John Shoemaker and Benjamin Wheeler

## Features not implemented:
- Wildcards
- ~ expansion to go home
- Expanding environment variables within strings partially working

## Features implemented:
- Built in commands (setenv, printenv, unsetenv, cd, alias, unalias, bye)
- Alias loop detection
- File redirection with alias and printenv
- External commands, including parameters
- File redirection with external commands ("<", ">", ">>", "2>", "2>&1")
- Piping commands, including paramaters for each command
- File redirection combined with piping
- Welcome screen on launch
- Colors involved in terminal printing
- Allows commands to be run in background
- Will check everywhere in path for commands to be run

We used the VSCode Live Share plug-in that allowed us to work together in real time. Most parts of the project were worked on together all times but we can break up the work loosely as follows:

## Work done by John Shoemaker:
- made rules for lexer and parser
- alias, unalias, alias loop detection, bye memory deallocation
- handled memory allocation for command table
- getting paths for external commands, creating table structures
- file redirection for "<", ">" and ">>" options
- handled setting up tables entries for n pipes
- worked on forking and executing processes
- testing

## Work done by Benjamin Wheeler
- made rules for lexer and parser
- setenv, unsetenv, printenv, file redirection with alias and printenv
- setting up paramaters for external commands
- file redirection for "2>" and "2>&1> options
- handled executing n pipes and linking pipes and file redirection
- made welcome screen and color decorations
- worked on forking and executing processes
- testing
