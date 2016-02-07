function [T,WV] = LoadSEfromCSC(fn, R, U)

% Loading enginer for MClust-4.0
%
% 

sizeofdouble = 8;

if nargin == 1
    fp = fopen(fn);
    nS = fread(fp, 1, 'int');
    nSamp = fread(fp, 1, 'int');
    
    T = nan(nS, 1);
    WV = nan(nS, 1, nSamp);
    
    for iS = 1:nS
        T(iS) = fread(fp, 1, 'double');
        WV(iS,1,:) = fread(fp, nSamp, 'double');
    end
    fclose(fp);
elseif nargin == 2
    % New "get" construction"
    if strcmp(fn, 'get')
        switch (R)
            case 'ChannelValidity'
                T = [true false false false]; return;
            case 'ExpectedExtension'
                T = '.csc2se'; return;
            otherwise
                error('Unknown get condition.');
        end
    else
        error('2 argins requires "get" as the first argument.');
    end
else % nargin == 3
    switch (U)
        case 1 % TS list
            error('Not yet implemented.');
            
        case 2 % R is record number list
            fp = fopen(fn);
            nS = fread(fp, 1, 'int');
            nSamp = fread(fp, 1, 'int');
            seek0 = ftell(fp);
            
            nR = length(R);
            T = nan(nR, 1);
            WV = nan(nR, 1, nSamp);
    
            for iR = 1:nR
                fseek(fp, ((R(iR)-1)*(nSamp+1)) * sizeofdouble + seek0, 'bof');
                T(iR) = fread(fp, 1, 'double');
                WV(iR,1,:) = fread(fp, nSamp, 'double');
            end
            fclose(fp);
            
        case 3 % range of timestamps
            error('Not yet implemented.');
            
        case 4 % range of records
            fp = fopen(fn);
            nS = fread(fp, 1, 'int');
            nSamp = fread(fp, 1, 'int');
            seek0 = ftell(fp);
            
            nR = R(2) - R(1);
            T = nan(nR, 1);
            WV = nan(nR, 1, nSamp);
    
            fseek(fp, ((R(1)-1)*(nSamp+1)) * sizeofdouble + seek0, 'bof');
            for iR = 1:nR
                T(iR) = fread(fp, 1, 'double');
                WV(iR,1,:) = fread(fp, nSamp, 'double');
            end
            fclose(fp);
             
        case 5 % nSpikes
            fp = fopen(fn);
            nS = fread(fp, 1, 'int');
            fclose(fp);
            T = nS;
        otherwise
            error('Unknown unit expectation.');
    end
end
    