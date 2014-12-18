#include<stdlib.h>

int main(){
  float * a = malloc(sizeof(float)*100);
  int i;
  for (i=0; i<=100; i++) {
    a[i] = 0;
  }

  free(a);
  return 0;
}
