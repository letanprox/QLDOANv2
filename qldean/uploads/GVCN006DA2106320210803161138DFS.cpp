#include <stdio.h>
#include <conio.h>
#include <iostream>
#include<stack>

#define MAX 50
#define TRUE 1
#define FALSE 0

using namespace std;
int A[MAX][MAX], n,chuaxet[MAX];FILE *fp;


void Init(void){
  int i,j;
  fp= fopen("dothi.in","r");
  
  fscanf(fp,"%d",&n);
  printf("\n So dinh do thi:%d",n);
  
  for(i=1; i<=n; i++){
    printf("\n");
	chuaxet[i]=TRUE;
    for(j=1; j<=n; j++){
      fscanf(fp,"%d",&A[i][j]);
      printf("%3d",A[i][j]);
    }
    
  }
}


void DFS_Dequi(int u){
  int v;
  printf("%3d",u);chuaxet[u]=FALSE;
  for(v=1; v<=n; v++){
    if(A[u][v] && chuaxet[v])
      DFS_Dequi(v);
  }
}

void DFS_Stack(int u){
	int s, t;
	stack<int> Stack;
	Stack.push(u);
	chuaxet[u]=FALSE;
	printf("%3d",u);
	  
	  while (!Stack.empty()) {
	  	s = Stack.top(); 
	  	Stack.pop(); 
	  	
	    for(t =1;t<=n; t++){
      	  if(chuaxet[t] && A[s][t]){
        	printf("%3d",t);
        	chuaxet[t] = FALSE;
        	Stack.push(s);
        	Stack.push(t);
			break; 
      		}
    	}
	  }	
}


int main(){
  int u;
  Init();
  
   printf("\n");
  
  cout<<"\n Dinh bat dau duyet: ";
  cin>>u;

//  DFS_Dequi(u);

  DFS_Stack(u);
  
  getch();
}




