%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include "nutshparser.tab.h"
#include <string.h>
#include "global.h"
#include "colors.h"

/**
 * bool to determine whether or not to expand an alias (unalias cmd should not expand aliases)
 */
int expand = 1;

void yyerror(char*);
// void yyerror(char* msg) {
//     fprintf(stderr, RED "%s", msg);
// }

// Substitute the alias tokens with their expanded name.
char* subAliases(char* name) {
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}

// Substitute the variable with their expanded name.
char* subVariable(char* name){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            return varTable.word[i];
        }
    }
    return name;
}

// Check each individual token to see if it's an variable.
bool ifVariable(char* name){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            return true;
        }
    }
    return false;
}

// Check each individual token to see if it's an alias.
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}
%}
%array
%option noyywrap
%x string_condition

CHAR            [.A-Za-z0-9!\/_\-:]+
ANYCHAR         [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ \-:]+

%%

<string_condition>$\{{CHAR}+\}   {                     
                                    char* yycopy = strdup(yytext);
                                    char* strbuff = malloc(sizeof(yycopy));
                                    int endCurly = strcspn(yycopy, "}"); // find where end curly brace is
                                    int startCurly = strcspn(yycopy, "{");                  
                                    memcpy(strbuff, &yycopy[startCurly+1], endCurly - startCurly - 1); // substring to get rid of "${}"
                                    //printf("string: \"%s\"\n", strbuff);

                                    if(ifVariable(strbuff)) {
                                        
                                        char* varcopy = strdup(subVariable(strbuff));
                                        for ( int i = strlen(subVariable(strbuff)) - 1; i >= 0; --i )
                                            unput( varcopy[i] );
                                        free( varcopy );
                                        free(strbuff);
                                    
                                    // printf("DEBUG: variable is: \"%s\"\n", yytext);
                                    }
                                    else {
                                        yyerror(RED "ERROR: Invalid environment variable." reset);
                                        return STRING;
                                        // TODO should we throw an error here, or try to run the command (and let it handle the err)?
                                    }
                                }
<string_condition>{ANYCHAR}+     {yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}

[ ]		            { }
bye                 { return BYE; }
cd		            { return CD;}
alias		        { expand = 0; return ALIAS; }
unalias             { expand = 0; return UNALIAS;}
setenv              { expand = 0; return SETENV; }
unsetenv            { expand = 0; return UNSETENV; }
printenv            { return PRINTENV; }
"\n"		        { expand = 1; return END; }
&                   { return AMPERSAND; }
\<                  { return LESS_THAN; }
\>                  { return GREATER_THAN; }
\>\>                { return DOUBLE_GREATER_THAN;}
2\>                 { return STD_ERR_SYMB; }
2\>&1               { return STD_ERR_SYMB_2; }
\|                  { return VERTBAR; }
[\"]                { BEGIN(string_condition); }
{CHAR}+             {   if(expand && ifAlias(yytext)) {
                        //printf("yytext: %s\n", yytext);
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                        } else {
                            //printf("yytext: %s\n", yytext);
                            yylval.string = strdup(yytext);
                            return STRING;
                        };
                    }
$\{{CHAR}+\}        {                     
                        char* yycopy = strdup(yytext);
                        char* strbuff = malloc(sizeof(yycopy));
                        int pos = strcspn(yycopy, "}"); // find where end curly brace is                    
                        memcpy(strbuff, &yycopy[2], pos-2); // substring to get rid of "${}"
                        //printf("string: \"%s\"\n", strbuff);

                        if(ifVariable(strbuff)) {
                            char* varcopy = strdup(subVariable(strbuff));
                            for ( int i = strlen(subVariable(strbuff)) - 1; i >= 0; --i )
                                unput( varcopy[i] );
                            free( varcopy );
                            free(strbuff);
                        
                           // printf("DEBUG: variable is: \"%s\"\n", yytext);
                        }
                        else {
                            yyerror(RED "ERROR: Invalid environment variable." reset);
                            return STRING;
                            // TODO should we throw an error here, or try to run the command (and let it handle the err)?
                        }
                    }
%%
