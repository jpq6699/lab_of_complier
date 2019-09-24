%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
int files_count = 0;
int lines = 1;
int pos_start=1;
int pos_end=1;

enum cminus_token_type{
	ERROR = 258,
	ADD = 259,
	SUB = 260,
	MUL = 261,
	DIV = 262,
	LT = 263,
	LTE = 264,
	GT = 265,
	GTE = 266,
	EQ = 267,
	NEQ = 268,
	ASSIN = 269,
	SEMICOLON = 270,
	COMMA = 271,
	LPARENTHESE = 272,
	RPARENTHESE = 273,
	LBRACKET = 274,
	PBRACKET = 275,
	LBRACE = 276,
	PBRACE = 277,
	ELSE = 278,
	IF = 279,
	INT = 280,
	RETURN = 281,
	VOID = 282,
	WHILE = 283,
	IDENTIFIER = 284,
	NUMBER = 285,
	LETTER = 286,
	ARRAY = 287,
	EOL = 288,
	COMMENT = 289,
	BLANK = 290
};
/*****************end*****************/

%}

letter [a-zA-Z]
digit [0-9]
ID {letter}{letter}*  
NUM {digit}{digit}* 

%%

 /****请在此补全所有flex的模式与动作  start******/
"+" {pos_start=pos_end;pos_end=pos_start+1;return ADD;}
"-" {pos_start=pos_end;pos_end=pos_start+1;return SUB;}
"*" {pos_start=pos_end;pos_end=pos_start+1;return MUL;}
"/" {pos_start=pos_end;pos_end=pos_start+1;return DIV;}
"<" {pos_start=pos_end;pos_end=pos_start+1;return LT;}
"<=" {pos_start=pos_end;pos_end=pos_start+2;return LTE;}
">" {pos_start=pos_end;pos_end=pos_start+1;return GT;}
">=" {pos_start=pos_end;pos_end=pos_start+2;return GTE;}
"==" {pos_start=pos_end;pos_end=pos_start+2;return EQ;}
"!=" {pos_start=pos_end;pos_end=pos_start+2;return NEQ;}
"=" {pos_start=pos_end;pos_end=pos_start+1;return ASSIN;}
";" {pos_start=pos_end;pos_end=pos_start+1;return SEMICOLON;}
"," {pos_start=pos_end;pos_end=pos_start+1;return COMMA;}
"(" {pos_start=pos_end;pos_end=pos_start+1;return LPARENTHESE;}
")" {pos_start=pos_end;pos_end=pos_start+1;return RPARENTHESE;}
"[" {pos_start=pos_end;pos_end=pos_start+1;return LBRACKET;}
"]" {pos_start=pos_end;pos_end=pos_start+1;return PBRACKET;}
"{" {pos_start=pos_end;pos_end=pos_start+1;return LBRACE;}
"}" {pos_start=pos_end;pos_end=pos_start+1;return PBRACE;}
"else" {pos_start=pos_end;pos_end=pos_start+4;return ELSE;}
"if" {pos_start=pos_end;pos_end=pos_start+2;return IF;}
"int" {pos_start=pos_end;pos_end=pos_start+3;return INT;}
"return" {pos_start=pos_end;pos_end=pos_start+6;return RETURN;}
"void" {pos_start=pos_end;pos_end=pos_start+4;return VOID;}
"while" {pos_start=pos_end;pos_end=pos_start+5;return WHILE;}
{ID} {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return IDENTIFIER;}
{NUM} {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return NUMBER;}
{letter} {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return LETTER;}
"\n" {lines++;pos_start=1;pos_end=1;return EOL;}
"\r" {return EOL;}
"[]" {pos_start=pos_end;pos_end=pos_start+2;return ARRAY;}
"/*" {
    char c;
    int done=0;
    do{
        while((c=input())!='*');
        while((c=input())=='*');
        if(c=='/')
            done =1;
    }while(!done);
    return COMMENT;
}
" " {pos_start=pos_end;pos_end=pos_start+1;return BLANK;}

. {return ERROR;}


 /****  end******/
%%

/****************请按需求补全C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
/// \todo student should fill this function
void analyzer(char* input_file_name, char* output_file_name){
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");
	int token;
	while(token = yylex()){
		switch(token){
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT:
			case BLANK:
				break;
			case EOL:
				break;
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief get all file paths under 'testcase' directory
///
/// under 'testcase' directory, there could be many *.cminus files.
/// \todo student should fill this function
void getAllTestcase(char filename[][256]){
	DIR *dirp; 
	int i=0;
    struct dirent *dp;
    char *name=".cminus";
    dirp = opendir("./testcase"); //打开目录指针
    while ((dp = readdir(dirp)) != NULL) { //通过目录指针读目录
        if(!strcmp(dp->d_name+strlen(dp->d_name)-7,name))
        {
            strcpy(filename[i],dp->d_name);
			i+=1;
        }
    }
	files_count=i;      
    (void) closedir(dirp); //关闭目录
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
///	process all *.cminus files under 'testcase' directory,
/// then create *.tokens files under 'tokens' directory
/// \todo student should fill this function
int main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	char tempname[256];
	getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
		strcpy(tempname,filename[i]);
		tempname[strlen(tempname)-7]='\0';
        strcpy(output_file_name,tempname);
		strcat(output_file_name,suffix);
		lines = 1;
        pos_start=1;
        pos_end=1;
		analyzer(filename[i],output_file_name);
	}
	return 0;
}
/**************** end*************/
