 /* AutoCorr
 * auto correlations
 * MEX file
 * 
 * batta 1999, lipa 2000
 * 
 * input: t1: a time series to auto correlate 
 *                (assumed to be sorted) 
 *        binsize: the binsize for the auto corr histogram
 *        nbins: the number of bins
  * NOTE: ASSUMES t1, binsize, nbins in SAME units
 * output: C the auto correlation histogram
 *         B (optional) a vector with the times corresponding to the bin centers
 *
 * version 2.0
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 4.0.
% Version control M5.0.
  * ADR 2014-11-25 added checks for memory control
  * ADR 2014-12-01 added checks to ensure that data is passed in as a Matlab double.
  * Mex with -largearraydims flag
 -----------------------------------*/

#include "mex.h"
#include <math.h>
#include <matrix.h>

void mexFunction(
  int nOUT, mxArray *pOUT[],
  int nINP, const mxArray *pINP[])
{
  
  double *t1;
  double binsize;
  double *C, *B;
  double rbound;
  
  mwSize nbins, nT;
  int i, nextEl, j, count;
  
  /* check number of arguments: expects 3 inputs, 1 or 2 outputs */
  if (nINP != 3)
    mexErrMsgTxt("Call with t1,  binsize and nbins  as inputs.");
  if (nOUT != 1 && nOUT != 2)
    mexErrMsgTxt("Requires one or two outputs.");

  /* check validity of inputs */
  if (mxGetM(pINP[0]) != 1 && mxGetN(pINP[0]) != 1)
    mexErrMsgTxt("t1 must be a row or column vector");
  if (mxGetM(pINP[1]) * mxGetN(pINP[1]) != 1)
    mexErrMsgTxt("binsize must be scalar");
  if (mxGetM(pINP[2]) * mxGetN(pINP[2]) != 1)
    mexErrMsgTxt("nbins must be scalar");
  if (!mxIsDouble(pINP[0]))
	  mexErrMsgTxt("T input is not a double!");
  
  /* unpack inputs */
  nT = mxGetM(pINP[0]) * mxGetN(pINP[0]);
  t1 = mxGetPr(pINP[0]);
  if (!t1)  mexErrMsgTxt("Memory allocation error t1");  // ADR 2014-11-25
  binsize = mxGetScalar(pINP[1]);
  nbins = (int)mxGetScalar(pINP[2]);
  
  pOUT[0] = mxCreateDoubleMatrix(nbins, 1, mxREAL); // inits all C to 0
  C = mxGetPr(pOUT[0]);
  if (!C)  mexErrMsgTxt("Memory allocation error C");  // ADR 2014-11-25
  if(nOUT == 2)
  {
      double m;
      
      pOUT[1] = mxCreateDoubleMatrix(nbins, 1, mxREAL);
      B =  mxGetPr(pOUT[1]);
      if (!B)  mexErrMsgTxt("Memory allocation error B");  // ADR 2014-11-25
      m = binsize/2.0;
      for(j = 0; j < nbins; j++)	B[j] = m + j * binsize;

  }
  
  /* cross correlations */
    
  for(i = 0; i < nT; i++)
  {
      nextEl = i+1;
      rbound = t1[i];
        
      for(j = 0; j < nbins; j++)
	  {
		  count = 0; // nothing in this bin yet
		  rbound += binsize;  // rbound of this bin
		  while((t1[nextEl] < rbound) && (nextEl < (nT-1)))
              {nextEl++; count++;}
		  C[j] += count;
	  }
  }
  
  for(j = 0; j < nbins; j++)  C[j] /= nT * binsize;
  
      
}
  
  
		 
