%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
extern int nb_ligne;
%}
/* YYACCEPT QUAND IL Y A END POUR FINIR L'ANALYSE SYNTAXIQUE */
%union {
int entier;
char* str;
}

%token <str> idf Consteuh type opmath opcond comment
%token <entier> cst 
%token aff pvg newline pr end beg forza parOuvre parFerme affect virg compt croO CroF elssse ifff

%%

program: 
       | program statement newline
       ;
statement:
pr idf {
    inserer($2, "IDF", "/", "NO");
    printf("Nom du programme : %s\n\n", $2);
}
| beg {
    printf("Début du programme.\n");
}
| end {
    printf("Fin du programme sans problème.");
    YYACCEPT;
}
| Consteuh type idf aff cst pvg{
    if((recherche($3)==-1)){
        inserer($3, "IDF", $2, "YES");
    }else{
        printf("\nErreur. Constante double-declarée à la ligne %d.", nb_ligne);
    }
}
| Consteuh type idf pvg{
    printf("Erreur d'affectation (const non affectée) à la ligne %d.\n", nb_ligne);
    YYERROR;
}
| type idf aff cst pvg{
    inserer($2, "IDF", $1, "NO");
}
| type idf pvg{
    inserer($2, "IDF", $1, "NO");
}
| operation
/*For (var :=valInit, condition, compteur)
{
Bloc Instructions pvg idf compt croO
}*/ 
| bouclefor
| iff
| comment {
    printf("\nCommentaire: %s\n", $1);
}
                ;

operation: idf aff expression pvg {
                if (!(recherche($1)==-1)){
                        printf("\nOpération %s =", $1);
                        inserer($1, "IDF", "Oui", "Non");
                    }else{
                    printf("\nErreur. L'IDF n'est pas declaré à la ligne %d.", nb_ligne);
                    YYERROR;
                }
}
;

expression: expression opmath expression 
| idf 
| cst 
;




bouclefor: forza parOuvre idf affect cst pvg idf opcond cst pvg idf compt parFerme croO {
    if(recherche($3)==-1){
        printf("\nErreur. L'IDF de la boucle for n'est pas déclaré à la ligne %d.", nb_ligne);
        YYERROR;
    }else{
        if(!(strcmp($3, $7) == 0 && strcmp($7, $11) == 0)){
            printf("\nErreur. Plusieurs IDFs différents dans la déclartion de la boucle à la ligne %d", nb_ligne);
            YYERROR;
        }else{
        printf("\nFor (%s = %d ; %s %s %d ; %s++){", $3,$5,$3,$8,$5,$3);
        }
    }
}
| CroF {
    printf("\n}");
}
| croO {
    printf("\n{\n");
}
;

iff: ifff parOuvre idf opcond cst parFerme croO {
        if(recherche($3)==-1){
        printf("\nErreur. L'IDF de la boucle if n'est pas déclaré à la ligne %d.", nb_ligne);
        YYERROR;
    }else{
        printf("\nIf (%s %s %d){", $3, $4, $5);
    }
}
| CroF {
    printf("\n}");
}
| croO {
    printf("\n{\n\n");
}
;

%%

void yyerror(const char *s) {
    printf("%s (Ligne %d).\n",s, nb_ligne);
}
int yywrap() {
    return 1;
}


typedef struct{
char NomEntite[20];
char CodeEntite[20];
char TypeEntite[20];
char ConstEntite[20];
} TypeTS;
//initiation d'un tableau qui va contenir les elements de la table de symbole
TypeTS ts[100];
// un compteur global pour la table de symbole
int CpTabSym=0;

//la fonction recherche: cherche est ce que l'entité existe ou non dans la table de symbole.
// renvoi:
// sa position i: si l'entite existe déjà dans la table de symbole
// -1: si l'entité n'existe pas dans la table de symbole.

int recherche(char entite[])
{
int i=0;
while(i<CpTabSym)
{
if (strcmp(entite,ts[i].NomEntite)==0) return i;
i++;
}
return -1;
}

//une fontion qui va insérer les entités de programme dans la table de symbole

void inserer(char entite[], char code[], char type[], char cst[])
{
if ( recherche(entite)==-1)
{
strcpy(ts[CpTabSym].NomEntite,entite);
strcpy(ts[CpTabSym].CodeEntite,code);
strcpy(ts[CpTabSym].TypeEntite,type);
strcpy(ts[CpTabSym].ConstEntite,cst);
CpTabSym++;
}
}

//une fonction pour afficher la table de symbole
void afficher()
{
printf("\n/***********Table des Symboles***********/\n");
printf("\t _______________________________________\n");
printf("\t| NomEntite | CodeEntite | Type | Const |\n");
printf("\t|___________|____________|______|_______|\n");
int i=0;
while(i<CpTabSym)
{
printf("\t|%10s |%11s |%5s |%6s |\n",ts[i].NomEntite,ts[i].CodeEntite,ts[i].TypeEntite,ts[i].ConstEntite);
i++;
}
printf("\t|___________|____________|______|_______|\n");
}
int main() {
    yyparse();
    printf("\n\n");
    afficher();
    return 0;

}


