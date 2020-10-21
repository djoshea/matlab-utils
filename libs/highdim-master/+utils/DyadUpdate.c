/*
 *         The main routine for DyadUpdate.c
 *
 * Huo & Szekely (2017). Fast Computing for Distance Covariance,
 *   Technometrics, 2016, 58, 435?447.
 *
 * Copyright (c) 2014  Xiaoming Huo
 */

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#define calloc   mxCalloc
#define free     mxFree
#endif

#define S(i)     s_p[i-1]
#define Y(i)     Y_p[i-1]
#define C(i)     C_p[i-1]
#define GAMMA(i) GAMMA_p[i-1]

void DyadUpdate(double GAMMA_p[],double Y_p[],double C_p[],const int n)
{
   int L,ii,ell,k,pos,scale,s_length;
   double *s_p;
   
   L = (int) ceil(log((double) n)/log((double) 2));
   s_length = (int) pow(((double) 2), ((double) L+1));
   s_p = (double *) calloc(s_length, sizeof(double));
   
   for(ii=2;ii<=n;ii++){
      for(ell=0;ell<=L-1;ell++){
         k = (int) ceil(Y(ii-1)/((int) pow(((double) 2), ((double) ell))));
         pos = k;
         if(ell>0){
            for(scale=ell-1;scale>=0;scale--){
               pos = pos + (int) pow(((double) 2), ((double) L-scale));
            }
         }
         S(pos) = S(pos) + C(ii-1);
      }
      for(ell=0;ell<=L-1;ell++){
         k = (int) floor((double) (Y(ii)-1)/((int) pow(((double) 2), ((double) ell))));
         if((double) k/2 > (int) floor(((double) k)/2)){
            pos = k;
            if(ell>0){
               for(scale=ell-1;scale>=0;scale--){
                  pos = pos + (int) pow(((double) 2), ((double) L-scale));
               }
            }
            GAMMA(ii) = GAMMA(ii) + S(pos);
         }
      }
   }
   
   free(s_p);
}

#undef S
#undef Y
#undef C
#undef GAMMA
