#include "stdbool.h" // TODO unused in this file?
#include <limits.h>

// Environment variable table
struct evTable {
   char var[128][100]; // variable name
   char word[128][100]; // value
};

// Alias table
struct aTable {
	char name[128][100]; // alias
	char word[128][100]; // expanded value
};

struct commandProperties {
   char name[50]; // command name
   // args
   int argc;
   char* argv[50];
};

// For File I/O
char inputFile[PATH_MAX];
char outputFile[PATH_MAX];
// Bool for if the task is a background (1) or foreground (0) task.
int background;

/* Current working directory */
char cwd[PATH_MAX];

// Instantiate tables
struct evTable varTable;
struct aTable aliasTable;
struct commandProperties cmdTable[50];
int cmdTableSize; // Size of cmdTable (used for indexing and iteration)

// Array to hold each path string for commands
char* paths[50];
int numPaths;

// Current sizes of alias table and env var table
int aliasIndex, varIndex;

char* subAliases(char* name);
