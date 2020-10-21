/* function gamma = DyadUpdate(y,c)
 *
 * Inputs
 *    y
 *    c
 * Output
 *    gamma
 *
 * Huo & Szekely (2017). Fast Computing for Distance Covariance,
 *   Technometrics, 2016, 58, 435?447.
 *
 * Copyright (c) 2014  Xiaoming Huo
 */

#include <math.h>
#include <stdio.h>
#include "mex.h"
#include "matrix.h"

/* Input Arguments */
#define Y   prhs[0]
#define C   prhs[1]

/* Output Arguments */
#define GAMMA       plhs[0]

/* subroutines declaration */
void DyadUpdate(double GAMMA_p[],double Y_p[],double C_p[],const int n);

/* Gateway Routine */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
   /* Variables declarations */
   int n,m_Y,n_Y,m_c,n_c;
   double *Y_p,*C_p,*GAMMA_p;
   
   /* Check for proper number of arguments. */
   if (nrhs != 2) {
      mexErrMsgTxt("DyadUpdate requires 2 input arguments.");
   } else if (nlhs != 1) {
      mexErrMsgTxt("DyadUpdate requires 1 output arguments.");
   }
   
   /* i1. first input */
   /* Get dimensions for 1st input. It should be a column vector. */
   m_Y =(int) mxGetM(Y); n_Y =(int) mxGetN(Y);
   if (n_Y > 1)
      mexErrMsgTxt("'Y' must be a column vector.");
   if (mxIsComplex(Y))
      mexErrMsgTxt("'Y' must be a Real vector.");
   
   /* Get pointers to the inputs */
   Y_p = mxGetPr(Y); n = m_Y;
   
   /* i2. second input */
   /* Get dimensions for 2nd input. It should be a vector. */
   m_c =(int) mxGetM(C); n_c =(int) mxGetN(C);
   if (n_c > 1)
      mexErrMsgTxt("'C' must a column vector.");
   if (mxIsComplex(C))
      mexErrMsgTxt("'C' must be a Real vector.");
   if (m_c != m_Y)
      mexErrMsgTxt("Inputs Y and C must have the same dimensions.");
   
   /* Get pointers to the inputs */
   C_p = mxGetPr(C);
   
   /* o1. output */
   GAMMA = mxCreateDoubleMatrix((int) n, (int) 1, mxREAL);
   if (GAMMA == NULL)
      mexErrMsgTxt("Could not allocate memory for GAMMA.");
   
   GAMMA_p = mxGetPr(GAMMA);
   
   /* Call subroutine to do the computation */
   DyadUpdate(GAMMA_p,Y_p,C_p,n);
   return;
}

#undef Y
#undef C
#undef GAMMA

#include "DyadUpdate.c"
