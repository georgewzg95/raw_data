#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef enum {enc_none,enc_reg,enc_rir,enc_cjmp,enc_nir,enc_store,enc_rnn,enc_in,enc_out} ENCODING;
struct encentry { ENCODING enc;int opcode;char *name;}; //if name==NULL ==>end of list
struct instr_reg { unsigned opcode:6; unsigned rA:5,rB:5,rC:5;unsigned _pad:11;};
struct instr_cjmp { unsigned opcode:6; unsigned rA:5,rB:5; signed offset:16;};
struct instr_rir { unsigned opcode:6; unsigned rA:5,con_0_4:5,rC:5; unsigned con_5_15:11;};
struct instr_store { unsigned opcode:6; unsigned rA:5,rB:5; signed offset:16;};
struct instr_io { unsigned opcode:6; unsigned rA:5,rB:5,rC:5;unsigned auxcode:6; unsigned _pad:5;};

typedef union {struct instr_reg reg; struct instr_cjmp cjmp; struct instr_rir rir; struct instr_store store; struct instr_io io; unsigned int code; } instruction;

typedef enum {reloc_cjmp,reloc_li,reloc_lih,reloc_imm,reloc_store} RELOCTYPE;
struct reloc {struct reloc *next;int offset; int section; RELOCTYPE type;};
struct label {char *name; int offset; int section; int resolved; struct reloc *reloc;};
struct label_array {int size; int count; struct label *labels;} labels[256];
int labelcount=0,labelsize=1024;

int currentsection=0;
instruction *program;
int instrcount=0,programlength=1024;

struct section { int length;int size; char *data; unsigned int addr; } sectn[3];

char *reallocz(char * addr, int old_size, int new_size)
{
  char * rtn;
  rtn=realloc(addr,new_size);
  if (old_size<new_size) memset(rtn+old_size,0,new_size-old_size);
  return rtn;
}

int findhash(char *name)
{
int hash=0,i;
for (i=0; name[i]!=0; i++) hash=hash+name[i];
return hash & 0xff;
}

int findlabel(char *name)
{
int hash,i,found=0;
hash=findhash(name);
for(i=0;i<labels[hash].count;i++)
 {
  if(strcmp(name,labels[hash].labels[i].name)==0) 
   {
    found=1;
    break;
   }
 }
if (found) return i;
 else return -1;
}

int addlabel(char *name, int offset, int section,int resolved)
{
char *szname;
int hash,labelcount,i;
hash=findhash(name);
i=findlabel(name);
if (i>=0)
 {
  if (resolved)
   {
    labels[hash].labels[i].offset=offset;
    labels[hash].labels[i].section=section;
    labels[hash].labels[i].resolved=1;
   }
  return i;
 }
else
 {
  if (labels[hash].count>=labels[hash].size) 
   {
    labels[hash].labels=reallocz(labels[hash].labels,labels[hash].size,labels[hash].size*2); 
    labels[hash].size=labels[hash].size*2;
   }
  szname=malloc(strlen(name)+1);
  strcpy(szname,name);
  labelcount=labels[hash].count;
  labels[hash].labels[labelcount].name=szname;
  labels[hash].labels[labelcount].offset=offset;
  labels[hash].labels[labelcount].section=section;
  labels[hash].labels[labelcount].resolved=resolved;
  labels[hash].labels[labelcount].reloc=NULL;
  labels[hash].count++;
  return labelcount;
 }
}

void addreloc(char *labelname, int offset, int section, RELOCTYPE type)
{
int i,hash;
struct reloc *myreloc;
hash=findhash(labelname);
i=addlabel(labelname,0,0,0);
myreloc=malloc(sizeof(struct reloc));
myreloc->next=labels[hash].labels[i].reloc;
myreloc->offset=offset;
myreloc->section=section;
myreloc->type=type;
labels[hash].labels[i].reloc=myreloc;

}

void apply_relocs()
{
int i,hash;
struct reloc *rel;
instruction instr;
unsigned short int sh_a;

for (hash=0;hash<=255;hash++)
{
 for (i=0; i<labels[hash].count; i++)
 {
  rel=labels[hash].labels[i].reloc;
  while (rel!=NULL)
   {
    switch(rel->type)
     {
      case reloc_cjmp:
      if (rel->section==0)
       {
         if (labels[hash].labels[i].section==0)
          {
           ((short *) sectn[0].data)[(rel->offset+2)/2]=(labels[hash].labels[i].offset-rel->offset)/4;
          }
       } 
      break;
      case reloc_li:
      if (rel->section==0)
       {
        instr=((instruction *) sectn[0].data)[rel->offset/4];
        sh_a=(sectn[labels[hash].labels[i].section].addr+labels[hash].labels[i].offset);
        //  fprintf(stderr,"*** reloc lc %s, sh_a=%i\n",labels[hash].labels[i].name,sh_a); 
        instr.rir.con_0_4=sh_a & 0x1f;
        instr.rir.con_5_15=sh_a >> 5;
        ((instruction *) sectn[0].data)[rel->offset/4]=instr;
       }
      break;
      case reloc_lih:
      if (rel->section==0)
       {
        instr=((instruction *) sectn[0].data)[rel->offset/4];
        sh_a=(sectn[labels[hash].labels[i].section].addr+labels[hash].labels[i].offset) >> 16;
        instr.rir.con_0_4=sh_a & 0x1f;
        instr.rir.con_5_15=sh_a >> 5;
        ((instruction *) sectn[0].data)[rel->offset/4]=instr;
       }
      break;
      case reloc_imm:
      if (rel->section==0)
       {
        instr=((instruction *) sectn[0].data)[rel->offset/4];
        sh_a=(sectn[labels[hash].labels[i].section].addr+labels[hash].labels[i].offset) >> 16;
        instr.store.offset=sh_a;
        ((instruction *) sectn[0].data)[rel->offset/4]=instr;
       }
      break;
      case reloc_store:
      if (rel->section==0)
       {
        instr=((instruction *) sectn[0].data)[rel->offset/4];
        sh_a=(sectn[labels[hash].labels[i].section].addr+labels[hash].labels[i].offset) & 0xffff;
        //fprintf(stderr,"*** reloc lc %s, sh_a=%i\n",labels[hash].labels[i].name,sh_a); 
        instr.store.offset=sh_a;
        ((instruction *) sectn[0].data)[rel->offset/4]=instr;
       }
      break;

     }
    rel=rel->next;
   }
 }
}
}

int main()
{
int chr;
int toplevel=1;
int tokenchars=0;
char token[256];
int tokencount=0;
char tokens[16][256];
int i,a,b,c,d;
signed short sh_a;
int comma=0;
int PC=0;
int nexttoken=0;
int error=0;
int inquote=0;
int incomment=0;
int lineno=0;

instruction instr;
instruction extraInstr;
int hasExtraInstr=0;

static struct encentry instrset[]={
{enc_rir,0,"lih"},
{enc_rir,0,"lch"},
{enc_nir,1,"li"},
{enc_nir,1,"lc"},
{enc_reg,2,"and"},
{enc_rir,3,"andi"},
{enc_reg,4,"or"},
{enc_rir,5,"ori"},
{enc_reg,6,"xor"},
{enc_rir,7,"xori"},
{enc_reg,8,"add"},
{enc_rir,9,"addi"},
{enc_reg,10,"sub"},
{enc_rir,11,"subi"},
{enc_none,12,"nop"},
{enc_rir,13,"andi1"},
{ enc_reg, 14, "shl" },
{ enc_rir, 15, "shli" },
{ enc_reg, 16, "shr" },
{ enc_rir, 17, "shri" },
{ enc_reg, 18, "sar" },
{ enc_rir, 19, "sari" },
{ enc_in, 0, "inb" },
{enc_in,1,"inw"},
{enc_in,2,"inl"},
{enc_out,4,"outb"},
{enc_out,5,"outw"},
{enc_out,6,"outl"},
{enc_cjmp,32,"cjule"},
{enc_cjmp,32,"cjc"},
{enc_cjmp,33,"cjugt"},
{enc_cjmp,33,"cjnc"},
{enc_cjmp,34,"cjeq"},
{enc_cjmp,35,"cjne"},
{enc_cjmp,36,"cjult"},
{enc_cjmp,37,"cjuge"},
{enc_cjmp,38,"cjn"},
{enc_cjmp,39,"cjnn"},
{enc_cjmp,40,"cjslt"},
{enc_cjmp,41,"cjsge"},
{enc_cjmp,42,"cjsle"},
{enc_cjmp,43,"cjsgt"},
{enc_cjmp,44,"cjo"},
{enc_cjmp,45,"cjno"},
{enc_rir,46,"call"},
{enc_rnn,47,"ret"},
{enc_rir,56,"ldl"},
{enc_rir,57,"ldw"},
{enc_rir,58,"ldb"},
{enc_store,60,"stl"},
{enc_store,61,"stw"},
{enc_store,62,"stb"},
{enc_none,-1,NULL}
};

//program=malloc(programlength*(sizeof(instruction)));
for (i=0; i<=255; i++) 
 {
  labels[i].count=0;
  labels[i].size=16;
  labels[i].labels=malloc(16*(sizeof(struct label)));
  memset(labels[i].labels,0,16*(sizeof(struct label)));
 }

for (i=0; i<=2; i++)
{
sectn[i].length=0;
sectn[i].addr=0;
sectn[i].size=4096;
sectn[i].data=malloc(4096);
memset(sectn[i].data,0,4096);
}

while(1) 
 {
  chr=fgetc(stdin);
  if (chr==';') {incomment=1; continue; }
  if (incomment) goto handle_newline_eof;
  if (chr=='"')
   {
    if (!inquote) {inquote=1; continue;}
    else { inquote=0; continue;}
   }
  if (inquote && (chr!='\n') && (chr!=EOF))
  {
   if (toplevel) {token[0]=chr;tokenchars=1;toplevel=0;} else {token[tokenchars]=chr;tokenchars++;}   
   continue;
  }
  if ((chr>='a' && chr<='z')||(chr>='A' && chr<='Z')||(chr>='0' && chr<='9')||(chr=='_'))
   {
    comma=0;
    if (toplevel) {token[0]=chr;tokenchars=1;toplevel=0;} else {token[tokenchars]=chr;tokenchars++;}
   }
  if (chr==' ' || chr=='\t') 
   {if (toplevel) {} else 
    {for(i=0;i<tokenchars;i++) tokens[tokencount][i]=token[i]; 
     tokens[tokencount][tokenchars]=0;
     tokencount++;
     toplevel=1;
    } 
   } 
  if (chr==',' || chr==':') //single character tokens
   {if (toplevel) {tokens[tokencount][0]=chr;tokens[tokencount][1]=0;tokencount++;} else
    {for(i=0;i<tokenchars;i++) tokens[tokencount][i]=token[i]; 
     tokens[tokencount][tokenchars]=0;
     tokencount++;
     tokens[tokencount][0]=chr;tokens[tokencount][1]=0;tokencount++;
     toplevel=1;
    }    
   }
 /* if (chr==':')
   {if (toplevel) {tokens[tokencount][0]=':';tokens[tokencount][1]=0;tokencount++;} else
    {for(i=0;i<tokenchars;i++) tokens[tokencount][i]=token[i]; 
     tokens[tokencount][tokenchars]=0;
     tokencount++;
     tokens[tokencount][0]=':';tokens[tokencount][1]=0;tokencount++;
     toplevel=1;
    }    
   }*/
  handle_newline_eof:
  if (chr=='\n' || chr==EOF)
   { 
    incomment=0;
    lineno++;
    if (toplevel) {} else 
    {for(i=0;i<tokenchars;i++) tokens[tokencount][i]=token[i]; 
     tokens[tokencount][tokenchars]=0;
     tokencount++;
     toplevel=1;
    }
    //for (i=0;i<tokencount;i++) printf ("t%i:%s\n",i,&tokens[i][0]);
    nexttoken=0;
    if (tokencount>=2 && !strcmp(tokens[1],":"))
    {addlabel(tokens[0],sectn[currentsection].length,currentsection,1);
     nexttoken=2;
    }
    //i=0;
    error=1;
    if (tokencount<=nexttoken) error=0;
    //printf("eRror %i\n",error);
    if (tokencount>nexttoken+1)
    {
     if (!strcmp(tokens[nexttoken],"section"))
     {
      if (!strcmp(tokens[nexttoken+1],"code")) {error=0;currentsection=0;}
      if (!strcmp(tokens[nexttoken+1],"data")) {error=0;currentsection=1;}
      if (!strcmp(tokens[nexttoken+1],"bss" )) {error=0;currentsection=2;}
     }

     if (!strcmp(tokens[nexttoken],"align"))
     {
       if (sscanf(tokens[nexttoken+1],"0x%x",&a)==1)
         error=0;
       else if (sscanf(tokens[nexttoken+1],"%i",&a)==1)
         error=0;
       if (error==0)
       {
         error=1;
         b=0xffffffff;
         for (i=0; (i<7) && (a!=1<<i); i++)
         {
           b=b<<1;
         }
         if (i<7)
         {
            if (((sectn[currentsection].length+(1<<i)-1) & b) > sectn[currentsection].size)
            {
              sectn[currentsection].data=reallocz(sectn[currentsection].data,sectn[currentsection].size,sectn[currentsection].size*2);
              sectn[currentsection].size+=sectn[currentsection].size;
            }
            sectn[currentsection].length=(sectn[currentsection].length+(1<<i)-1) & b;
            error=0;
         }      
       }
       
     }

     if (!strcmp(tokens[nexttoken],"DS"))
     {
      for (i=0; i<strlen(tokens[nexttoken+1]); i++)
      {
       //if (sscanf(tokens[i],"%i",&a)!=1)
       //  sscanf(tokens[i],"0x%x",&a);
       a=tokens[nexttoken+1][i];
       if (sectn[currentsection].length>=sectn[currentsection].size)
       {
        sectn[currentsection].data=reallocz(sectn[currentsection].data,sectn[currentsection].size,sectn[currentsection].size*2);
        sectn[currentsection].size+=sectn[currentsection].size;
       }
       sectn[currentsection].data[sectn[currentsection].length]=a;
       sectn[currentsection].length++;
      }
      error=0;
     } //DS

     if (!strcmp(tokens[nexttoken],"DB"))
     {
      for (i=nexttoken+1; i<tokencount; i++)
      {
       if (sscanf(tokens[i],"0x%x",&a)!=1)
         sscanf(tokens[i],"%i",&a);
       if (sectn[currentsection].length>=sectn[currentsection].size)
       {
        sectn[currentsection].data=reallocz(sectn[currentsection].data,sectn[currentsection].size,sectn[currentsection].size*2);
        sectn[currentsection].size+=sectn[currentsection].size;
       }
       sectn[currentsection].data[sectn[currentsection].length]=a;
       sectn[currentsection].length++;
      }
      error=0;
     }
     if (!strcmp(tokens[nexttoken],"DW"))
     {
      for (i=nexttoken+1; i<tokencount; i++)
      {
       if (sscanf(tokens[i],"0x%x",&a)!=1)
         sscanf(tokens[i],"%i",&a);
       if (sectn[currentsection].length+2>sectn[currentsection].size)
       {
        sectn[currentsection].data=reallocz(sectn[currentsection].data,sectn[currentsection].size,sectn[currentsection].size*2);
        sectn[currentsection].size+=sectn[currentsection].size;
       }
       *((short int *) &(sectn[currentsection].data[sectn[currentsection].length]))=a;
       sectn[currentsection].length+=2;
      }
      error=0;
     }
     if (!strcmp(tokens[nexttoken],"DL"))
     {
      for (i=nexttoken+1; i<tokencount; i++)
      {
       if (sscanf(tokens[i],"0x%x",&a)!=1)
         sscanf(tokens[i],"%i",&a);
       if (sectn[currentsection].length+4>sectn[currentsection].size)
       {
        sectn[currentsection].data=reallocz(sectn[currentsection].data,sectn[currentsection].size,sectn[currentsection].size*2);
        sectn[currentsection].size+=sectn[currentsection].size;
       }
       *((int *) &(sectn[currentsection].data[sectn[currentsection].length]))=a;
       sectn[currentsection].length+=4;
       
      }
      error=0;
     }
    }

    if ((tokencount>nexttoken) && (error==1))
    {
     for (i=0;;i++)
     {
      if (instrset[i].name==NULL) break;
      if (strcmp(tokens[nexttoken],instrset[i].name)==0) break;
     }
     instr.code=0;
     error=0;
     hasExtraInstr=0;
     extraInstr.code=0; 
     if (instrset[i].name==NULL) error=1;
     else
     switch (instrset[i].enc)
     {
      case enc_none: instr.reg.opcode=instrset[i].opcode; break;
      case enc_reg:
       if (tokencount-nexttoken==6)
       {
        instr.reg.opcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"r%d",&b)!=1) error=1;
        if (strcmp(tokens[nexttoken+4],",")) error=1;
        if (sscanf(tokens[nexttoken+5],"r%d",&c)!=1) error=1;
        instr.reg.rA=a;
        instr.reg.rB=b;
        instr.reg.rC=c;

       }
       else error=1;
       break;
      case enc_rir:
       if (tokencount-nexttoken==6)
       {
        instr.rir.opcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"0x%x",&d)!=1)
         if (sscanf(tokens[nexttoken+3],"%d",&d)!=1)
         {
          addreloc(tokens[nexttoken+3],sectn[0].length,0,reloc_imm);
          addreloc(tokens[nexttoken+3],sectn[0].length+4,0,reloc_li);
          d=0xbaadf00d;
         }
        if (strcmp(tokens[nexttoken+4],",")) error=1;
        if (sscanf(tokens[nexttoken+5],"r%d",&c)!=1) error=1;
        sh_a=(signed short) d;
        instr.rir.rA=a;
        instr.rir.rC=c;
        instr.rir.con_0_4=sh_a & 0x1f;
        instr.rir.con_5_15=sh_a >> 5;
        if (sh_a!=d)
        {
         extraInstr.store.opcode=30;
         extraInstr.store.offset=d>>16;
         hasExtraInstr=1;
        }
        
       }
       else error=1;
       break;
      case enc_nir:
       if (tokencount-nexttoken==4)
       {
        instr.rir.opcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"0x%x",&a)!=1)
         if (sscanf(tokens[nexttoken+1],"%d",&a)!=1)
           {//li
            addreloc(tokens[nexttoken+1],sectn[0].length+4,0,reloc_li);
            addreloc(tokens[nexttoken+1],sectn[0].length,0,reloc_imm);
            a=0xbaadf00d;
            //printf("reloc\n");
           }
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"r%d",&c)!=1) error=1;
        sh_a=(signed short) a;
        instr.rir.rA=0;
        instr.rir.rC=c;
        instr.rir.con_0_4=sh_a & 0x1f;
        instr.rir.con_5_15=sh_a >> 5;
        //printf("sh_a=%i,token=%s\n",sh_a,tokens[nexttoken+1]);
        if (sh_a!=a)
        {
         hasExtraInstr=1;
         extraInstr.store.opcode=30;
         extraInstr.store.offset=a>>16;
        }
       }
       else error=1;
       break;

      case enc_cjmp:
       if (tokencount-nexttoken==6)
       {
        instr.reg.opcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"r%d",&b)!=1) error=1;
        if (strcmp(tokens[nexttoken+4],",")) error=1;
        //if (sscanf(tokens[nexttoken+5],"r%d",&c)!=1) error=1;
        instr.cjmp.rA=a;
        instr.cjmp.rB=b;
        if (error==0) addreloc(tokens[nexttoken+5],sectn[0].length,0,reloc_cjmp);

       }
       else error=1;
       break;

      case enc_store:
       if (tokencount-nexttoken==6)
       {
        instr.rir.opcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"0x%x",&d)!=1)
         if (sscanf(tokens[nexttoken+3],"%d",&d)!=1) 
         {
          addreloc(tokens[nexttoken+3],sectn[0].length+4,0,reloc_store);
          addreloc(tokens[nexttoken+3],sectn[0].length,0,reloc_imm);
          d=0xbaadf00d;
         }
        if (strcmp(tokens[nexttoken+4],",")) error=1;
        if (sscanf(tokens[nexttoken+5],"r%d",&c)!=1) error=1;
        sh_a=(signed short) d;
        instr.cjmp.rA=a;
        instr.cjmp.rB=c;
        instr.cjmp.offset=sh_a;
        if (sh_a!=d)
        {
         hasExtraInstr=1;
         extraInstr.store.opcode=30;
         extraInstr.store.offset=d>>16;
        }
        
       }
       else error=1;
       break;

      case enc_rnn:
       if (tokencount-nexttoken==2)
       {
        instr.rir.opcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        instr.rir.rA=a;
        
       }
       else error=1;
      break;

      case enc_in:
       if (tokencount-nexttoken==4)
       {
        instr.io.opcode=31;
        instr.io.auxcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"r%d",&b)!=1) error=1;

        instr.io.rA=a;
        instr.io.rB=0;
        instr.io.rC=b;

       }
       else error=1;
       break;

      case enc_out:
       if (tokencount-nexttoken==4)
       {
        instr.io.opcode=31;
        instr.io.auxcode=instrset[i].opcode;
        if (sscanf(tokens[nexttoken+1],"r%d",&a)!=1) error=1;
        if (strcmp(tokens[nexttoken+2],",")) error=1;
        if (sscanf(tokens[nexttoken+3],"r%d",&b)!=1) error=1;
        
        instr.io.rA=a;
        instr.io.rB=b;
        instr.io.rC=0;

       }
       else error=1;
       break;

      default: error=1;
     }
//     if (error==0) printf("hexcode %x,name %s\n",instr.code,instrset[i].name);
     if (error==0) 
     {
 //     printf("hexcode %x,name %s\n",instr.code,instrset[i].name);
      if (hasExtraInstr)
       {
         if (sectn[0].length+4>sectn[0].size) 
          { 
           sectn[0].data=reallocz(sectn[0].data,sectn[0].size,2*sectn[0].size);
           sectn[0].size+=sectn[0].size;
          }
        ((instruction * )sectn[0].data)[(sectn[0].length+3)/4]=extraInstr;
        PC+=4;
        sectn[0].length=(sectn[0].length+4+3) & 0xfffffffc;
       }
      if (sectn[0].length+4>sectn[0].size) 
       { 
        sectn[0].data=reallocz(sectn[0].data,sectn[0].size,2*sectn[0].size);
        sectn[0].size+=sectn[0].size;
       }
      ((instruction * )sectn[0].data)[(sectn[0].length+3)/4]=instr;
      PC+=4;
      sectn[0].length=(sectn[0].length+4+3) & 0xfffffffc;
     }

    } //else error=1;
    if (error) printf("error in line %i\n",lineno);
    tokencount=0;
    if (chr==EOF) 
     {
      //printf("EOF\n");
      sectn[0].addr=0;//todo:origin
      for (i=1; i<=2; i++)
       sectn[i].addr=(sectn[i-1].addr+sectn[i-1].length+63) & 0xffffffc0;
      apply_relocs();
      for (a=0; a<=1; a++)
      {
       //printf("a=%i\n",a);
       for (i=0;i<((sectn[a].length+63)& 0xffffffc0)/4;i++)
       {
        printf("%x\n",((unsigned int *) sectn[a].data)[i]);
       }
      }
      exit(0);
      
     }
   }
   
 }

}
