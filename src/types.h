#ifndef _TYPES_
#define _TYPES_



enum primitif {VOID_T, INT_T, FLOAT_T, PINT, PFLOAT};


typedef struct type_t { 
  enum primitif kind;
  int taille;
  int isFunction;
  int nbParam;
  enum primitif params[100];
} type_t;



#endif
