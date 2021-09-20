/*
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
!!! Copyright (c) 2017-20, Lawrence Livermore National Security, LLC
!!! and DataRaceBench project contributors. See the DataRaceBench/COPYRIGHT file
for details.
!!!
!!! SPDX-License-Identifier: (BSD-3-Clause)
!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!
 */

/*
   Simplified miniAMR proxy app to reproduce data race behavior. 
   Data Race Pair, in@60:43:R vs. in@52:43:W
                   work@65:19@W vs. work@65:19@W 
                   bp->array@65:36@R vs. bp->array@75:19@W 
                   bp->array@66:36@R vs. bp->array@75:19@W 
                   bp->array@67:36@R vs. bp->array@75:19@W 
                   bp->array@68:36@R vs. bp->array@75:19@W 
                   bp->array@69:36@R vs. bp->array@75:19@W 
                   bp->array@70:36@R vs. bp->array@75:19@W 
                   bp->array@71:36@R vs. bp->array@75:19@W 
 */

#include <stdio.h>
#include <stdlib.h>

typedef long long num_sz;

int max_num_blocks;
int num_refine;
int num_vars;
int x_block_size, y_block_size, z_block_size;
int error_tol;

double tol;

typedef struct {
   num_sz number;
   int level;
   int refine;
   int new_proc;
   num_sz parent;       // if original block -1,
                     // else if on node, number in structure
                     // else (-2 - parent->number)
   double ****array;
} block;

block *blocks;

void stencil_calc(int var, int stencil_in)
{
   int i, j, k, in;
   double sb, sm, sf, work[x_block_size+2][y_block_size+2][z_block_size+2];
   block *bp;

   int tid;

#pragma omp parallel default(shared) private(i, j, k, bp)
  {
      for (in = 0; in < max_num_blocks; ++in) {
         bp = &blocks[in];
         for (i = 1; i <= x_block_size; i++)
            for (j = 1; j <= y_block_size; j++)
               for (k = 1; k <= z_block_size; k++)
                  work[i][j][k] = (bp->array[var][i-1][j  ][k  ] +
                                   bp->array[var][i  ][j-1][k  ] +
                                   bp->array[var][i  ][j  ][k-1] +
                                   bp->array[var][i  ][j  ][k  ] +
                                   bp->array[var][i  ][j  ][k+1] +
                                   bp->array[var][i  ][j+1][k  ] +
                                   bp->array[var][i+1][j  ][k  ])/7.0;
         for (i = 1; i <= x_block_size; i++)
            for (j = 1; j <= y_block_size; j++)
               for (k = 1; k <= z_block_size; k++)
                  bp->array[var][i][j][k] = work[i][j][k];
      }
  }
}


void allocate(void)
{
   int i, j, k, m, n;

   blocks = (block *) malloc(max_num_blocks*sizeof(block));

   for (n = 0; n < max_num_blocks; n++) {
      blocks[n].number = -1;
      blocks[n].array = (double ****) malloc(num_vars*sizeof(double ***));
      for (m = 0; m < num_vars; m++) {
         blocks[n].array[m] = (double ***)
                              malloc((x_block_size+2)*sizeof(double **));
         for (i = 0; i < x_block_size+2; i++) {
            blocks[n].array[m][i] = (double **)
                                   malloc((y_block_size+2)*sizeof(double *));
            for (j = 0; j < y_block_size+2; j++)
               blocks[n].array[m][i][j] = (double *)
                                     malloc((z_block_size+2)*sizeof(double));
         }
      }
   }
}

void deallocate(void)
{
   int i, j, m, n;

   for (n = 0; n < max_num_blocks; n++) {
      for (m = 0; m < num_vars; m++) {
         for (i = 0; i < x_block_size+2; i++) {
            for (j = 0; j < y_block_size+2; j++)
               free(blocks[n].array[m][i][j]);
            free(blocks[n].array[m][i]);
         }
         free(blocks[n].array[m]);
      }
      free(blocks[n].array);
   }
   free(blocks);
}

void init(void)
{
   int n, var, i, j, k, l, m, o, size, dir, i1, i2, j1, j2, k1, k2, ib, jb, kb;
   num_sz num;
   block *bp;


   /* Determine position of each core in initial mesh */
   // initialize
   for (o = n = k1 = k = 0; k < 1; k++)
      for (k2 = 0; k2 < 1; k1++, k2++)
         for (j1 = j = 0; j < 1; j++)
            for (j2 = 0; j2 < 1; j1++, j2++)
               for (i1 = i = 0; i < 1; i++)
                  for (i2 = 0; i2 < 1; i1++, i2++, n++) {
                     bp = &blocks[o];
                     bp->level = 0;
                     bp->number = n;
                     //add_sorted_list(o, n, 0);
                     for (var = 0; var < num_vars; var++)
                        for (ib = 1; ib <= x_block_size; ib++)
                           for (jb = 1; jb <= y_block_size; jb++)
                              for (kb = 1; kb <= z_block_size; kb++)
                                 bp->array[var][ib][jb][kb] =
                                    ((double) rand())/((double) RAND_MAX);
                    o++;
                  }
}



void driver(void)
{
  int start, number, var;

  init();

  for (var = 0; var < num_vars; var ++) {
     stencil_calc(var, 7);
  }
}


int main(int argc, char* argv[])
{   
  max_num_blocks = 500;
  num_refine = 5;
  num_vars = 40;
  x_block_size = 10;
  y_block_size = 10;
  z_block_size = 10;

  allocate();
 
  driver();

  deallocate();
  return 0;
} 
