#include "stdbool.h" // TODO unused in this file?
#include <limits.h>

// Environment variable table
struct evTable {
   char var[128][100];
   char word[128][100];
};

// Alias table
struct aTable {
	char name[128][100];
	char word[128][100];
};

struct commandProperties {
   char name[100];
   int argc;
   char argv[100];
   char inputFile[PATH_MAX];
   char outputFile[PATH_MAX];
};

char cwd[PATH_MAX];

// Instantiate tables
struct evTable varTable;
struct aTable aliasTable;
struct commandProperties commandTable; // TODO make array

// Current sizes of alias table and env var table
int aliasIndex, varIndex;

char* subAliases(char* name);