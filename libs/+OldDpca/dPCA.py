from numpy import *
from itertools import combinations, chain
from numpy.linalg import det, pinv, slogdet

# core function
def DPCA(Y,ncomp,tolerance = 10e-3,maxloop=100):
	'''
	Y	- data as np.array, one dimension per parameter
	ncomp	- # of components to compute
        tolerance - breaking condition, if relative change of evidence is lower
                    than tolerance, break algorithm
        maxloop - maximum number of loops before break
	'''
        # PCA init
        Y = remean(Y)	# remove mean from data
        C = covmat(Y)	# calculate covariance matrix
        W = PCA(C,ncomp).real	# perform PCA as init

        # define important constants and variables
	"marginals --> (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
        marginals = list(powerset(range(1,len(Y.shape))))
        
        pdim = len(Y.shape) - 1
	N = prod(Y.shape[1:])
        d = Y.shape[0]
        m = len(marginals)

        iMo = empty((m,ncomp,ncomp))
        yo = empty((len(marginals),) + Y.shape)
        for o in range(len(marginals)):
            yo[o] = margAverage(Y,marginals[o]).real
        
        Ezo = einsum('ji...,oj...->oi...',W,yo)
        Ezzo = einsum('oi...,oj...->oij...',Ezo,Ezo)
        Ez = sum(Ezo,axis=0)
        Ezz = sum(Ezzo,axis=0)

	o2 = 1./var(Y - einsum('ij...,j...->i...',W,Ez))

        loop = 1

        B = einsum(Ezzo,[0,1,1] + range(2,pdim+2),[0,1])
        A = LambdaOpt(B,1)

        U,s,V = linalg.svd(einsum(Y,[0] + range(2,pdim+2),Ez,[1] + range(2,pdim+2),(0,1)),full_matrices=0)
        Q = dot(U,V.T)
        D = diag(s)

        evid_old = evidence(Y,W,o2)

	while True:
                # E-step
                for o in range(len(marginals)):
                    iMo[o] = linalg.pinv(dot(W.T,W) + o2*diag(A[o,:]**-1)).real

                iMW = einsum('oij,jk->oik',iMo,W.T)
                Ezo = einsum('oij...,oj...->oi...',iMW,yo)
                Ezzo = o2*iMo.reshape(iMo.shape + (1,)*pdim) + einsum('oi...,oj...->oij...',Ezo,Ezo)
                Ez = einsum('o...->...',Ezo)
                Ezz = einsum('o...->...',Ezzo)

                B = einsum(Ezzo,[0,1,1] + range(2,pdim+2),[0,1])
                A = LambdaOpt(B,1)
                
                Q,D = Wopt(einsum(Y,[0] + range(2,pdim+2),Ez,[1] + range(2,pdim+2),(0,1)),einsum(Ezz,range(2+pdim),range(2)),Q,D)
                W = dot(Q,D)
                
                o2 = 1/float(N*Y.shape[0])*(sum(Y*Y) - 2*trace(dot(einsum(Y,[0] + range(2,pdim+2),Ez,[1] + range(2,pdim+2),(0,1)),W.T)) + trace(dot(einsum(Ezz,range(2+pdim),range(2)),dot(W.T,W))))
                
                loop += 1
                evid_new = evidence(Y,W,o2)
                
                print "evidence: ", evid_new
                
                if abs((evid_new - evid_old)/evid_new) < tolerance or loop > maxloop:
                    break
                
                evid_old = evid_new.copy()
                
	return W

def evidence(y,W,o2):
    C = dot(W,W.T) + o2*eye(y.shape[0])
    iC = linalg.pinv(C)
    N = prod(y.shape[1:])
    return  -N*y.shape[0]/2.*log(2*pi) - 0.5*N*slogdet(C)[1] - 0.5*einsum(y,[0] + range(2,len(y.shape)+1),iC,(0,1),y,range(1,len(y.shape)+1),[])

def LambdaOpt(B,K):
    A = zeros(B.shape) + 10e-10
    for i in range(B.shape[1]):
        asort = argsort(B[:,i])[::-1][:K]
        A[asort,i] = B[asort,i]/sum(B[asort,i])
        
    return A

def Wopt(A,B,Q0,D0):
    Q = Q0
    D = D0
    
    loop = 0
    loss = QDloss(A,B,Q,D)
    
    while True:
        U,s,V = linalg.svd(dot(A,D),full_matrices=0)
        
        Q = dot(U,V)
        D = dot(diag(diag(dot(Q.T,A))),diag(diag(B)**-1))

        loop += 1

        newloss = QDloss(A,B,Q,D)
        if loop > 0 or allclose(loss,newloss):
            break            
            
        loss = newloss

    return Q,D
    
def QDloss(A,B,Q,D): return trace(dot(A,dot(D,Q.T))) - 0.5*trace(dot(B,D**2))
def remean (X): return X - einmean(X).reshape((X.shape[0],) + len(X.shape[1:])*(1,))
def einmean (X): return einsum(X,range(len(X.shape)),(0,))/prod(X.shape[1:])	
def covmat (X): return einsum(X,(0,)+tuple(range(1,len(X.shape))),X,(len(X.shape),)+tuple(range(1,len(X.shape))),(0,len(X.shape)))
def PCA (C,n): return linalg.eig(C)[1][:,:n]

def powerset(iterable):
    "powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
    s = list(iterable)
    return chain.from_iterable(combinations(s, r) for r in range(1,len(s)+1))

# MARGINALIZED AVERAGES
# Given a data matrix Y, Y.shape = (10,t,s,d), we perform averages in the series
# t,s,d,ts,td,sd where yt = <ytsd>_sd.

# assumes centered data! Indices J >= 1, 0 is reserved
def margAverage(A,J):
	J = list(J)
	w = zeros(array(A.shape)[[0] + J])
	iJ = list(invertJ(A,J))
	
	for i in range(len(J)):
		for I in list(combinations(J,i)):
## 			print "start", (-1)**i, iJ + list(I), J, iJ
			reshaped = array(A.shape)
			reshaped[iJ + list(I)] = 1
			reshaped = reshaped[[0] + J]
			w = w + (-1)**i*marginalize(A,iJ + list(I)).reshape(reshaped)
	
	reshaped = array(A.shape)
	reshaped[iJ] = 1
	return w.reshape(reshaped)
	
# invert list of indices
def invertJ(A,J): return map(int,list(delete(arange(len(A.shape)),J)[1:]))
# J = list of indices
def marginalize(A,J): return einsum(A,range(len(A.shape)),[0] + invertJ(A,J))/float(prod(array(A.shape)[J]))