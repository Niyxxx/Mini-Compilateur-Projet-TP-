%{
#include "bison.tab.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
extern int nb_ligne = 1;
extern YYSTYPE yylval;
%}

pr "Programme"

end "END"

beg "BEGIN"

lettreMaj [A-Z]

caractere [a-zA-Z0-9_]

chiffre [0-9]

IDF {lettreMaj}{caractere}*

cst {chiffre}+

Consteuh [cC][oO][nN][sS][tT]

le_INT [Ii][Nn][Tt]
le_FLOAT [Ff][Ll][Oo][Aa][Tt]
le_bool [Bb][Oo][Oo][Ll]

for [fF][oO][rR]

type {le_INT}|{le_FLOAT}|{le_bool}

opmath [+*/-]

opcond ==|!=|<|>|<=|>=

ifff [iI][fF]

elssse [eE][lL][sS][eE]

comment  "{ "[^\{]+" }"$



%%

{opmath} {yylval.str=strdup(yytext);
return opmath;}

{pr} { return pr;}

{end} {return end;}

{beg} {return beg;}

{for} {return forza;}

"++" {return compt;}

\( {return parOuvre;}

\) {return parFerme;}

:= {return affect;}

, {return virg;}

{Consteuh} {
    yylval.str=strdup(yytext);
    return Consteuh;}
    
{type} {
    yylval.str=strdup(yytext);
    return type;
}

{comment} {
    yylval.str=strdup(yytext);
    return comment;
}

{opcond} {yylval.str=strdup(yytext);
    return opcond;}

{IDF} {
    yylval.str=strdup(yytext);
    int tiretConsecutif=0;
    if(yyleng <=10){
        for (int i = 0; i< yyleng-1; i++) {
            if (yytext[i]== '_' && yytext[i+1] == '_'){
                tiretConsecutif = 1;
            }
        }
        if (tiretConsecutif==1) {
            yyerror("IDF refusé. Tirets consecutifs.");
        }else{
                if(yytext[yyleng-1]=='_'){
                    yyerror("IDF refusé. Ne doit pas finir avec un tiret.");
                }else{
                return idf;
                }
            
                }
        }else{
        yyerror("IDF refusé. Mot trop long.");
    }
}

\{ {return croO;}

\} {return CroF;}

{cst} {yylval.entier=atoi(yytext);
    return cst;}

= return aff;

{ifff} return ifff;

{elssse} return elssse;

; return pvg;

\n {
nb_ligne++;
return newline;
}


