%{	
	#include <stdio.h>
	#include<string.h>
	#include<stdlib.h>
	#include<iostream>
	
        int EsteCorecta = 0;
	int corecta=1,eroare=1;
	int yylex(void);
	int yyerror(const char *msg);
	char msg[500];
	

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	     int setat;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	     int getSetat(char* n);
	     void setSetat(char* n);
	   
	    
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
         this->setat=0;
	 this->next = NULL;

	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	 
	}
	
	

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }
	
	
	
	
         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }
	

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
		tmp->setat=1;
	      }
	      tmp = tmp->next;
	    }
	  }

 	void TVAR::setSetat(char* n)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		
		tmp->setat=1;
	      }
	      tmp = tmp->next;
	    }
	  }
	
	int TVAR::getSetat(char* n)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	      {
	      if(tmp->setat==1)
	      	return 1;
	      tmp = tmp->next;
	      }
	   return -1;
	  }
 	
       
	
	TVAR* ts = NULL;
%}




%union {int val; char *sir;}
%locations
%token   PROGRAM VAR BEGIN1 END INTEGER DIV  READ WRITE FOR DO TO VIRGULA PUNCT PUNCTVIRGULA EQ PLUS MINUS OR PD PI TOK_ERROR
%token <val> INT
%token <sir> id
%type <val> exp
%type <sir> id_list
%type <sir> assign 
%type <val> factor
%type <val> term
%start prog

%left PLUS MINUS 
%left OR DIV

%%

prog : PROGRAM prog_name VAR dec_list BEGIN1 stmt_list END TOK_ERROR  {  if(eroare==1) EsteCorecta = 1; } ;
prog_name: id | error { eroare = 0; };
dec_list: dec | dec_list PUNCTVIRGULA dec | error { eroare = 0; };
dec: id_list PUNCT type {               char* c = strtok($1," ") ; 
					while(c!=NULL)
					{
						if(ts!=NULL)
						{
							if(ts->exists(c))
							{
								sprintf(msg," Declaratie multipla a variabilei %s\n",c);
								yyerror(msg);
								
								corecta = 0;
								//YYERROR;
							}
							else
								{ts->add(c);
								
								}
						}
						else
							{ts=new TVAR();
							ts->add(c);
							
							}
					c=strtok(NULL," ");
					}
			
					
			} ;
type: INTEGER | error { eroare = 0; };
id_list: id  | id_list VIRGULA id { strcat($$," "); strcat($$,$3);} ;

stmt_list: stmt | stmt_list PUNCTVIRGULA stmt | error { eroare = 0; };
stmt: assign | read | write | for ;
assign: id EQ exp {
		if(ts != NULL)
			{
	 		 if(ts->exists($1) == 1)
	  			{
	    			ts->setValue($1,$3);
	  			}
	 		 else
	 			 {
	   			 sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n", $1);
	    			yyerror(msg);
				corecta = 0;
	    			//YYERROR;
	  			}
			}
		else
			{
	 		 sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n", $1);
	 		 yyerror(msg);
			corecta = 0;
	 		//YYERROR;
			}
       };

exp: term { $$= $1; } | exp PLUS term { $$=$1+$3;} | exp MINUS term { $$=$1-$3;};
term: factor { $$= $1;} 
	| term OR factor { $$=$1*$3;} 
	| term DIV factor { 
				if($3 == 0) 
	 				{ 
	      				sprintf(msg,"Eroare semantica: Impartire la zero!\n");
	      				yyerror(msg);
					corecta = 0;
	     				// YYERROR;
	  				} 
	  			else 
				{ $$ = $1 / $3; } 
	} 
								
factor: id {
		
		if(ts != NULL)
			{
	 		 if(ts->exists($1) == 1)
	  			{if(ts->getSetat($1)==1)
	    				$$=ts->getValue($1);
				else
					{ sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!\n", $1);
	    				yyerror(msg);
					corecta = 0;
					//YYERROR;
					}
	  			}
	 		 else
	 			 {
	   			 sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n", $1);
	    			yyerror(msg);
				corecta = 0;
	    			//YYERROR;
	  			}
			}
		else
			{
	 		 sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n", $1);
	 		 yyerror(msg);
			corecta = 0;
	 		 //YYERROR;
			}
	 }
	 | INT {$$=$1; } 
	| PD exp PI { $$= $2; } ;
read: READ PD id_list PI { char *p=strtok($3," ");
			   while(p!=NULL)
				{
				if(ts->exists(p)==0)
					{ sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n",p);
	    				yyerror(msg);
					corecta = 0;
					//YYERROR;
					}
					else
					ts->setSetat(p);
				p=strtok(NULL," ");
				}
			};
write: WRITE PD id_list PI { char *p=strtok($3," ");
			   while(p!=NULL)
				{
				if(ts->exists(p)==0)
					{ sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n",p);
	    				yyerror(msg);
					corecta = 0;
					//YYERROR;
					}
				p=strtok(NULL," ");
				}
			} ;
for: FOR index_exp DO body ;
index_exp: id EQ exp TO exp{ 
			if(ts != NULL)
			{
	 		 if(ts->exists($1) == 1)
	  			{
	    			ts->setValue($1,$3);
	  			}
	 		 else
	 			 {
	   			 sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n", $1);
	    			yyerror(msg);
				corecta = 0;
	    			//YYERROR;
	  			}
			}
		else
			{
	 		 sprintf(msg,"Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!\n", $1);
	 		 yyerror(msg);
			corecta = 0;
	 		 //YYERROR;
			}
		} ;
body: stmt | BEGIN1 stmt_list END ;
%%

int main()
{	
	yyparse();
	
	if(EsteCorecta == 1 && corecta==1)
	{
		printf(" CORECTA!\n");		
	}	
	else
	{
		printf(" INCORECTA!\n");
	}

       return 0;
}

int yyerror(const char *msg)
{	
	printf("\n%s",msg);
	return 1;
}



