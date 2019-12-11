#include <stdio.h>
#include <stdlib.h>

void mc64id_(int *a)
{
  fprintf(stderr, "SuperLU: MC64 functionality not available (it uses non-free code). Aborting.\n");
  abort();
}

void mc64ad_(int *a, int *b, int *c, int d[], int e[], double f[],
             int *g, int h[], int *i, int j[], int *k, double l[],
             int m[], int n[])
{
  fprintf(stderr, "SuperLU: MC64 functionality not available (it uses non-free code). Aborting.\n");
  abort();
}
