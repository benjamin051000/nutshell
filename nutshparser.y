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

int processCommand(char *command, char *args);

char argList[256];

// end of C code
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS UNALIAS END SETENV PRINTENV UNSETENV
%nterm <string> argument_list

%%

argument_list :
	%empty                         {memset(&argList[0], 0, sizeof(argList)); $$ = argList;}
	| argument_list STRING         {$$ = $1; strcat($$, $2);}

cmd_line :
	BYE END 		                {exit(1); return 1; }
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| ALIAS END                     {showAliases(); return 1;}
	| UNALIAS STRING END			{unsetAlias($2); return 1;}
	| SETENV STRING STRING END      {return setEnv($2, $3);}
	| PRINTENV END                  {return printEnv();}
	| UNSETENV STRING END           {return unsetEnv($2);}
	| STRING argument_list END		{return processCommand($1, $2);}   
	
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

int processCommand(char *command, char *args) {

	//where is the command located?

	//return if not found

	char command_with_path[50] = "/bin/";
	strcat(command_with_path, command);
	
	printf("Running command \"%s\"...\n", command_with_path);
	
	// Make a new process
	pid_t p = fork();

	if(p < 0) {
		fprintf(stderr, "Fork failed.\n");
		return 0;
	}
	else if(p > 0) { // Parent process (nutshell)
		// wait for child ?
		wait(NULL);
	}
	else { // Child process (p==0)
	// Attempt to access via each path directory.
		// if(access(command_with_path, X_OK)) { // TODO split path env variable and check each one.
			printf("args: \"%s\"\n", args);
			if(strcmp(args, "") == 0) {
				execl(command_with_path, command_with_path, NULL, NULL); //no arguments to pass
			}
			else {
				execl(command_with_path, command_with_path, args, NULL); // pass args
			}
		// }
		// else {
			// printf("Couldn't access command %s.\n", command_with_path);
			// return 0;
		// }
	}

	return 1;
}