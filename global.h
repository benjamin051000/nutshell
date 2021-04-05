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
   char* name;
   int argc;
   char* argv[50];
   char inputFile[PATH_MAX];
   char outputFile[PATH_MAX];
};

char cwd[PATH_MAX];

// Instantiate tables
struct evTable varTable;
struct aTable aliasTable;
struct commandProperties cmdTable;

// Array to hold each path string for commands
char *paths[50];
int numPaths;

// Current sizes of alias table and env var table
int aliasIndex, varIndex;

char* subAliases(char* name);