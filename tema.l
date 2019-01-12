%{	
	#include "y.tab.h"
	#include <stdlib.h>
	#include <string.h>

	int lineNo = 1;
	int colNo = 1;
	
%}


%%



"program" {colNo+=7; return PROGRAM;}
"var" {colNo+=3; return VAR;}
"begin" {colNo+=5; return BEGIN1;}
"end" {colNo+=3; return END;}
"integer" {colNo+=7; return INTEGER;}
"/" {colNo++; return DIV;}
"read" {colNo+=4; return READ;}
"write" {colNo+=5; return WRITE;}
"for" {colNo+=3;return FOR;}
"do" {colNo+=2; return DO;}
"to" {colNo+=2; return TO;}
"," {colNo++; return VIRGULA;}
":" {colNo++; return PUNCT;}
";" {colNo++; return PUNCTVIRGULA;}
":=" {colNo+=2; return EQ;}
"+" {colNo++; return PLUS;}
"-" {colNo++; return MINUS;}
"*" {colNo++; return OR;}
"(" {colNo++; return PD;}
")" {colNo++; return PI;}

[a-zA-Z][a-zA-Z0-9]* { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return id;}

0|[1-9][0-9]*	{yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.val = atoi(yytext); return INT; }

[ ]				{ colNo++; }
\r\n			{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ colNo++; return TOK_ERROR; }

%%
