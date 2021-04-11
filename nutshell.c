// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include "colors.h"

char *getcwd(char *buf, size_t size);
int yyparse();

int main()
{
    // Set default values of global variables
    aliasIndex = 0;
    varIndex = 0;

    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    // Allocate space for entire command table
    // Iterate through each cmdTable
    for(int i = 0; i < 50; i++) 
    {
        // Allocate space for each argv string
        for(int j = 0; j < 50; j++)
        {
            cmdTable[i].argv[j] = malloc(30*sizeof(char));              
        }
        
        cmdTable[i].argc = 1; // Set to 1 so [0] is available for path
    }
    
    system("clear");
    printf("Welcome to the Nutshell, loser.\n");
    while(1)
    {
        printf(GRN "[%s]>> " reset, varTable.word[2]);
        yyparse();
    }

   return 0;
}