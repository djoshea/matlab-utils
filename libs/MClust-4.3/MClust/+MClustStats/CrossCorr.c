 /* CrossCorr
 * cross correlations
 * MEX file
 * 
 * batta 1999
 * 
 * input: t1, t2: two time series to cross correlate 
 *                (assumed to be sorted) 
 *        binsize: the binsize for the cross corr histogram 
 *        nbins: the number of bins
  * NOTE: ASSUMES t1, t2, binsize, nbins in SAME units
 * output: C the cross correlation histogram
 *         B (optional) a vector with the times corresponding to the bins
 *
 * version 4.0
  * Fixed rbound bug line 103: nt2-1 --> nt2 2014/May/16
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
  double *t2;
  double binsize;
  double *C, *cross, *B;
  double w, lbound, rbound;
  
  int nbins, nt1, nt2;
  int i1 = 0, i2 = 0, l, j, k;
  
  /* check number of arguments: expects 4 inputs, 1 or 2 outputs */
  if (nINP != 4)
    mexErrMsgTxt("Call with t1, t2, binsize and nbins  as inputs.");
  if (nOUT != 1 && nOUT != 2)
    mexErrMsgTxt("Requires one or two outputs.");

  /* check validity of inputs */
  if (mxGetM(pINP[0]) != 1 && mxGetN(pINP[0]) != 1)
    mexErrMsgTxt("t1 must be a row or column vector");
  if (mxGetM(pINP[1]) != 1 && mxGetN(pINP[1]) != 1)
    mexErrMsgTxt("t2 must be a row or column vector");
  if (mxGetM(pINP[2]) * mxGetN(pINP[2]) != 1)
    mexErrMsgTxt("binsize must be scalar");
  if (mxGetM(pINP[3]) * mxGetN(pINP[3]) != 1)
    mexErrMsgTxt("nbins must be scalar");

  /* unpack inputs */
  nt1 = mxGetM(pINP[0]) * mxGetN(pINP[0]);
  t1 = mxGetPr(pINP[0]);
  if (!t1)  mexErrMsgTxt("Memory allocation error t1");  // ADR 2014-11-25
  if (!mxIsDouble(pINP[0]))
	  mexErrMsgTxt("T1 input is not a double!");


  nt2 = mxGetM(pINP[1]) * mxGetN(pINP[1]);
  t2 = mxGetPr(pINP[1]);
  if (!t2)  mexErrMsgTxt("Memory allocation error t2");  // ADR 2014-11-25
  if (!mxIsDouble(pINP[1]))
	  mexErrMsgTxt("T2 input is not a double!");

  binsize = mxGetScalar(pINP[2]);
  nbins = (int)mxGetScalar(pINP[3]);
 
  /* we want nbins to be odd */
  if ((nbins / 2) * 2 == nbins)
    nbins++;

  pOUT[0] = mxCreateDoubleMatrix(nbins, 1, mxREAL);
  C = mxGetPr(pOUT[0]);
  if (!C)  mexErrMsgTxt("Memory allocation error C");  // ADR 2014-11-25

  if(nOUT == 2)
    {
      double m;
      
      pOUT[1] = mxCreateDoubleMatrix(nbins, 1, mxREAL);
      B =  mxGetPr(pOUT[1]);
      if (!B)  mexErrMsgTxt("Memory allocation error B");  // ADR 2014-11-25

      m = - binsize * (nbins / 2);
      
      for(j = 0; j < nbins; j++)
	B[j] = m + j * binsize;

    }
  
  /* cross correlations */
  
  w = (nbins / 2) * binsize;

  
  for(i1 = 0; i1 < nt1; i1++)
    {
      lbound = t1[i1] - w;
      while(t2[i2] < lbound && i2 < nt2 -1)
	i2++;
      while(t2[i2-1] > lbound && i2 > 1)
	i2--;
      rbound = lbound;
      l = i2;
      
      for(j = 0; j < nbins; j++)
	{
	  k = 0;
	  rbound += binsize;
	  while(t2[l] < rbound && l < nt2)
	    {
	      l++;
	      k++;
	    }

	  C[j] += k;
	}
    }
  
  
  for(j = 0; j < nbins; j++)
    C[j] /= nt1 * binsize / 10000;
  
      
}
  
  
		 
