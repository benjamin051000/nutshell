%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include "global.h"
#include "colors.h"

int yylex(void);
int yyerror(char *s);
/* Builtin commands */
int runCD(char* arg);
// Alias commands
int runSetAlias(char *name, char *word);
int showAliases(void);
int unsetAlias(char *);
// Environment variable commands
int setEnv(char *varName, char *value);
int printEnv(void);
int unsetEnv(char*);

int processCommand(int runInBackground);

void getPaths(char* envStr);

// argument list: 25 args
// char* argList[50];
// int argSize;


// end of C code
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS UNALIAS END SETENV PRINTENV UNSETENV AMPERSAND VERTBAR
%nterm <string> argument_list
%type <string> background 

%%

// pipe:
// 	%empty {}
// 	| VERTBAR STRING argument_list {}
	// | pipe 

background :
	%empty {cmdTable.background = 0;}
	| AMPERSAND {cmdTable.background = 1;}


argument_list :
	%empty                          {
									 for(int i = 0; i < sizeof(cmdTable.argv); i++)
									    cmdTable.argv[i] = malloc(30*sizeof(char)); // Allocate 50 chars for each argv.
									 cmdTable.argc = 1; // Set to 1 so [0] is available for path
								    }
	| argument_list STRING         {$$ = $1; strcpy(cmdTable.argv[cmdTable.argc++], $2);}

cmd_line :
	%empty                               {return 1;}
	| BYE END 		                	 {exit(1); return 1; }
	| CD STRING END        				 {runCD($2); return 1;}
	| ALIAS STRING STRING END			 {runSetAlias($2, $3); return 1;}
	| ALIAS END                     	 {showAliases(); return 1;}
	| UNALIAS STRING END				 {unsetAlias($2); return 1;}
	| SETENV STRING STRING END      	 {return setEnv($2, $3);}
	| PRINTENV END                  	 {return printEnv();}
	| UNSETENV STRING END           	 {return unsetEnv($2);}
	| STRING argument_list background END {strcpy(cmdTable.name, $1); return processCommand(cmdTable.background);}   // background
		// | STRING argument_list PIPE argument_list END
	// | STRING argument_list PIPE argument_list AMPERSAND END
%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
}

int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

/**
* param name - Alias
* param word - command
*/
int runSetAlias(char *name, char *word) {
    // Check that the size of the alias table is not full
	if(aliasIndex >= 128) return 0;
	
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) { 
			// if alias already defined, update expansion
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int showAliases(void) {
	for(int i = 0; i < aliasIndex; i++)
	{
		printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);	
	}
	return 1;
}

/**
* param name - Alias to remove
*/
int unsetAlias(char* name) {
	// Check that the size of the alias table is not empty
	if(aliasIndex == 0) return 0;
	
	for(int i = 0; i < aliasIndex; i++)
	{
		if(strcmp(aliasTable.name[i], name) == 0) {
			//replace what needs to be removed with whats at the end of the list
			strcpy(aliasTable.name[i], aliasTable.name[aliasIndex-1]);
			strcpy(aliasTable.word[i], aliasTable.word[aliasIndex-1]);
			aliasIndex--;

			return 1;
		}
	}
	
	return 0; //we didnt find the alias
}

/**
* param varName - name of environment variable being created
* param value - value of environment variable
*/
int setEnv(char *varName, char *value) {
	// Check that the size of the env table is not full
	if(varIndex >= 128) return 0;

	// If the variable already exists, update its value
	for(int i = 0; i < varIndex; i++) {
		if(strcmp(varName, varTable.var[i]) == 0) {
			// It's already there, update value
			strcpy(varTable.word[i], value);
			return 1;
		}
	}

	// Make a new environment variable.
	strcpy(varTable.var[varIndex], varName);
	strcpy(varTable.word[varIndex], value);
	varIndex++;

	return 1;
}

int printEnv(void) {
	for(int i = 0; i < varIndex; i++) {
		printf("%s=%s\n", varTable.var[i], varTable.word[i]);
	}
	return 1;
}

/**
* param name - variable to remove
*/
int unsetEnv(char* name) {
	// Check that the size of the env table is not empty
	if(varIndex == 0) return 0;
	
	for(int i = 0; i < varIndex; i++)
	{
		if(strcmp(varTable.var[i], name) == 0) {
			//replace what needs to be removed with whats at the end of the list
			strcpy(varTable.var[i], varTable.var[varIndex-1]);
			strcpy(varTable.word[i], varTable.word[varIndex-1]);
			varIndex--;

			return 1;
		}
	}
	
	return 0; //we didnt find the var
}

int processCommand(int runInBackground) {

	// Get locations from path env var
	char* path_env;
	for(int i = 0; i < varIndex; i++) {
		if(strcmp(varTable.var[i], "PATH") == 0) {
			path_env = varTable.word[i];
			break;
		}
	}
	
	if(path_env == NULL) {
		fprintf(stderr, RED "Couldn't find PATH environment variable.\n");
		return 0;
	}

	getPaths(path_env);	

	char command_with_path[50];
	int found = 0;

	// Try to run the command on each path.
	for(int i = 0; i < numPaths; i++) {
		// printf("attempting paths[%d]: \"%s\"\n", i, paths[i]);

		strcpy(command_with_path, paths[i]);
		strcat(command_with_path, "/");
		strcat(command_with_path, cmdTable.name);
		
		// printf("Checking accessibility of \"%s\"\n", command_with_path);

		// Is it accessible?
		if(access(command_with_path, X_OK) == 0) {
			// printf("this one works\n");
			found = 1;
			break;
		}
	}

	if(!found) {
		fprintf(stderr, RED "Error: Command not executable.\n");
		return 0;
	}

	//TODO after one & command, we arnt waiting for the child to finish anymore 
	// Make a new process
	pid_t p = fork();

	if(p < 0) {
		fprintf(stderr, "Fork failed.\n");
		return 0;
	}
	else if(p > 0) { 
		// Parent process (nutshell)
		// wait for child (unless we want it run in the foreground)
		if(!runInBackground)
		{
			wait(NULL); // TODO is this it? Nano doesn't run in bkgd like in bash
			//printf("We waited for process to finish.\n");
		}
	}
	else { // Child process (p==0)
		cmdTable.argv[0] = command_with_path;
		cmdTable.argv[cmdTable.argc++] = NULL;

		//debug code for printing arguments
		// printf("------Args------\n");
		// for(int i = 0; i < argSize; i++) {
		// 	printf("argList[%d]: \"%s\"\n", i, argList[i]);
		// }
		// printf("----------------\n");

		execv(command_with_path, cmdTable.argv); // Execute command with args
		printf(BLU "--\tThe child is done\n" reset);
		// exit(0); // child process complete
	}

	return 1;
}

/* Input path environment variable, split and add invididual paths to 
"paths" global to iterate through later when running an Other Command. */
void getPaths(char* envStr) {
    // Initialize each path string	
	for(int i = 0; i < sizeof(paths)/sizeof(char*); i++)
		paths[i] = malloc(50*sizeof(char));
		
	numPaths = 0;

	char* delim = ":"; // TODO is this on stack or heap???

	// Copy envStr before modifying it.
	char *tempEnvStr = malloc(sizeof(envStr));
	strcpy(tempEnvStr, envStr);

	// printf("tempEnvStr: \"%s\"\n", tempEnvStr);

	char *ptr = strtok(tempEnvStr, delim);

	while(ptr != NULL) {

		//printf("token: \"%s\"\n", ptr); // debug
		
		// Add to array
		paths[numPaths++] = ptr;

		// Start at next NUL terminator position of string (strtok remembers initial string)
		ptr = strtok(NULL, delim);
	}
	
	// Debug print
	// for(int k = 0; k < numPaths; k++)
	// 	printf("[getPaths]\tpaths[%d]: \"%s\"\n", k, paths[k]);

	/* free(tempEnvStr); */
}


//  TODO Free memory!!!!!!!!!!!!!!!!!!!