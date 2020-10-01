function pout=binomtest(s,n,p,Sided)
%function pout=myBinomTest(s,n,p,Sided)
%
% Performs a binomial test of the number of successes given a total number 
% of outcomes and a probability of success. Can be one or two-sided.
%
% Inputs:
%       s-      (Scalar or Array) The observed numebr of successful outcomes
%       n-      (Scalar or Array) The total number of outcomes (successful or not)
%       p-      (Scalar or Array) The proposed probability of a successful outcome
%       Sided-  (String) can be 'one', 'two' (the default), or 'two, equal 
%               counts'. A value of 'one' will perform a one-sided test to
%               determine if the observed number of successes are either 
%               significantly greater than or less than the expected number
%               of successes, depending on whether s is greater than or less 
%               than the observed number of successes. 'Two' will use the
%               method of small p-values (see reference below) to perform a
%               two-tailed test to calculate the probability of observing
%               any equally unlikely or more unlikely value greater than or
%               less than the expected number of successes (ie with the 
%               same cdf value of the distribution. 'Two, equal counts' 
%               will perform a two-sided test that the that the actual 
%               number of success is different from the expected number of 
%               successes in any direction.
%
% Outputs:
%       pout-   The probability of observing the resulting value of s or
%               another value more extreme (the precise meaning of which 
%               depends on the value of Sided) given n total outcomes with 
%               a probability of success of p.               
%
%       s, n and p can be scalars or arrays of the same size. The
%       dimensions and size of pout will match that of these inputs.
%
%   For example, the signtest is a special case of this where the value of p
%   is equal to 0.5 (and a 'success' is dfeined by whether or not a given
%   sample is of a particular sign.), but the binomial test and this code is 
%   more general allowing the value of p to be any value between 0 and 1.
%
%   The results when Sided='two' and when Sided='two, equal counts' are 
%   identical only when p=0.5, but are different otherwise. For more
%   description, see the second reference below.
%
% References:
%   http://en.wikipedia.org/wiki/Binomial_test
%   http://www.graphpad.com/guides/prism/6/statistics/index.htm?stat_binomial.htm
%
% by Matthew Nelson July 21st, 2009
%
% Last Updated by Matthew Nelson May 23, 2015
% matthew.nelson.neuro@gmail.com
if nargin<4 || isempty(Sided);    Sided='two';      end
if nargin<3 || isempty(p);      p=0.5;      end
    
s=floor(s);
[s,n,p]= EqArrayAndScalars(s,n,p);
E=p.*n;
GreaterInds=s>=E;
pout=zeros(size(GreaterInds));
Prec=1e-14;  % there are some rounding errors in matlab's binopdf, such that we need to specify a level of tolerance when using the 'two' test     
switch lower(Sided)
    case {'two','two, equal counts'}        
        if all(p)==0.5 && strcmpi(Sided,'two');
            % to avoid the rounding problems mentioned above, use the equal counts method which is is theoretically identical in this special case and is not susceptible to this rounding error    
            Sided='two, equal counts';
        end
            
        dE=pout;
        
        %note that matlab's binocdf(s,n,p) gives the prob. of getting up to AND INCLUDING s # of successes...
        %Calc pout for GreaterInds first
        if any(GreaterInds)
            pout(GreaterInds)=1-binocdf( s(GreaterInds)-1,n(GreaterInds),p(GreaterInds));  %start with the prob of getting >= s # of successes
            
            %now figure the difference from the expected value, and figure the prob of getting lower than that difference from the expected value # of successes
            dE(GreaterInds)=s(GreaterInds)-E(GreaterInds);
            
            if strcmpi(Sided,'two, equal counts')            
                s2= floor(E(GreaterInds)-dE(GreaterInds));
                
                % if s2<0 we add nothing because a negative number of sucesses is impossible    
                if s2>=0
                    pout(GreaterInds)=pout(GreaterInds)+ binocdf(s2,n(GreaterInds),p(GreaterInds));    %the binonmial is a discrete dist. ... so it's value over non-integer args has no meaning... this flooring of E-dE actually doesn't affect the outcome (the result is the same if the floor was removed) but it's included here as a reminder of the discrete nature of the binomial
                end     
                
                %If the expected value is exactly equaled, the above code would have added the probability at that discrete value twice, so we need to adjust (in this case, pout will always = 1 anyways)
                EqInds=dE==0;
                if any(EqInds)
                    pout(EqInds)=pout(EqInds)- binopdf( E(EqInds),n(EqInds),p(EqInds) );
                end
            else
                Inds=find(GreaterInds);                
                
                % find the first value on the other side of the expected value with probability less than or equal to the probability that we found...
                targy=binopdf(s(GreaterInds),n(GreaterInds),p(GreaterInds));                                
                
                % start by guessing a constant dE, and adjusting from there   
                s2=max(floor(E(GreaterInds)-dE(GreaterInds)),0);      %the binonmial is a discrete dist. ... so it's value over non-integer args has no meaning... this flooring of E-dE actually doesn't affect the outcome (the result is the same if the floor was removed) but it's included here as a reminder of the discrete nature of the binomial    
                
                y=binopdf(s2,n(GreaterInds),p(GreaterInds));
                for ii=1:length(Inds)            
                    SkipPAdd=false;
                    if y(ii) <= targy(ii)
                        % search forward until we find the correct limit
                        while y(ii) <= targy(ii) && s2(ii)<E(Inds(ii))
                            s2(ii)=s2(ii)+1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        s2(ii)=s2(ii)-1;    % because the last iteration would have crossed the boundary, and we want the first s2 with a binopdf <= targy
                    else
                        %while y(ii) > targy(ii) && s2(ii)<n(Inds(ii))  % sometimes this is susceptible to rounding errors which we want to avoid with the line below     
                        while (y(ii) - targy(ii)) > Prec && s2(ii)<n(Inds(ii))
                            s2(ii)=s2(ii)-1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        % if y(ii)>targy(ii) % bc of rounding error again, avoid this line   
                        if (y(ii) - targy(ii)) > Prec % in this case s2 is at 0, and the prob stil wasn't low enough so we need to add nothing new to pout
                            SkipPAdd=true;
                        end
                    end
                    
                    if ~SkipPAdd
                        % adding the lesser-than tail here   
                        pout(Inds(ii))=pout(Inds(ii))+ binocdf(s2(ii),n(Inds(ii)),p(Inds(ii)));  
                    end
                end
            end                        
        end
        
        %Calc pout for LesserInds second
        if any(~GreaterInds)            
            pout(~GreaterInds)=binocdf(s(~GreaterInds),n(~GreaterInds),p(~GreaterInds));  %start with the prob of getting <= s # of successes
            
            %now figure the difference from the expected value, and figure the prob of getting greater than that difference from the expected value # of successes
            dE(~GreaterInds)=E(~GreaterInds)-s(~GreaterInds);
            
            if strcmpi(Sided,'two, equal counts')
                s2=ceil(E(~GreaterInds)+dE(~GreaterInds));
                
                if s2<=n(~GreaterInds)
                    pout(~GreaterInds)=pout(~GreaterInds) + 1-binocdf(s2-1,n(~GreaterInds),p(~GreaterInds));
                end
            else
                Inds=find(~GreaterInds);
                
                % find the first value on the other side of the expected value with probability less than or equal to the probability that we found...
                targy=binopdf(s(~GreaterInds),n(~GreaterInds),p(~GreaterInds));                  
                
                % start by guessing a constant dE, and adjusting from there   
                s2=min(ceil(E(~GreaterInds)+dE(~GreaterInds)),n(~GreaterInds));      %the binonmial is a discrete dist. ... so it's value over non-integer args has no meaning... this flooring of E-dE actually doesn't affect the outcome (the result is the same if the floor was removed) but it's included here as a reminder of the discrete nature of the binomial    
                y=binopdf(s2,n(~GreaterInds),p(~GreaterInds));
                for ii=1:length(Inds)                
                    SkipPAdd=false;
                    if y(ii) <= targy(ii)
                        % search backward until we find the correct limit
                        while y(ii) <= targy(ii) && s2(ii)>E(Inds(ii))
                            s2(ii)=s2(ii)-1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        s2(ii)=s2(ii)+1;    % because the last iteration would have crossed the boundary, and we want the first s2 with a binopdf <= targy
                    else
                        %while y(ii) > targy(ii) && s2(ii)<n(Inds(ii))  % sometimes this is susceptible to rounding errors which we want to avoid with the line below     
                        while (y(ii) - targy(ii)) > Prec && s2(ii)<n(Inds(ii))    
                            s2(ii)=s2(ii)+1;
                            y(ii)=binopdf(s2(ii),n(Inds(ii)),p(Inds(ii)));
                        end
                        %if y(ii)>targy(ii) % bc of rounding error again, avoid this line   
                        if (y(ii) - targy(ii)) > Prec   % in this case s2 is at n, and the prob stil wasn't low enough so we need to add nothing new to pout
                            SkipPAdd=true;
                        end
                    end
                    
                    if ~SkipPAdd
                        % adding the greater-than tail here
                        pout(Inds(ii))=pout(Inds(ii))+ 1-binocdf(s2(ii)-1,n(Inds(ii)),p(Inds(ii)));   
                    end
                end
                        
            end
        end
    case 'one'  %one-sided
        if any(GreaterInds)
            pout(GreaterInds)=1-binocdf(s(GreaterInds)-1,n(GreaterInds),p(GreaterInds));  %just report the prob of getting >= s # of successes
        end
        if any(~GreaterInds)                    
            pout(~GreaterInds)=binocdf(s(~GreaterInds),n(~GreaterInds),p(~GreaterInds));  %just report the prob of getting <= s # of successes
        end
    otherwise
        error(['In myBinomTest, Sided variable is: ' Sided '. Unkown sided value.'])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=EqArrayAndScalars(varargin)
%function varargout=EqArrayAndScalars(varargin)
%
% This will compare a collection of inputs that must be either scalars or 
% arrays of the same size. If there is at least one array input, all scalar
% inputs will be replicated to be the array of that same size. If there are
% two or more array inputs that have different sizes, this will return an
% error.
%
% created by Matthew Nelson on April 13th, 2010
% matthew.j.nelson.vumail@gmail.com                        
d=zeros(nargin,1);
for ia=1:nargin    
    d(ia)=ndims(varargin{ia});
end
maxnd=max(d);
s=ones(nargin,maxnd);
    
for ia=1:nargin
    s(ia,1:d(ia))=size(varargin{ia});
end
maxs=max(s);
varargout=cell(nargin,1);
for ia=1:nargin
    if ~all(s(ia,:)==maxs)
        if ~all(s(ia,:)==1)
            error(['Varargin{' num2str(ia) '} needs to be a scalar or equal to the array size of other array inputs.'])
        else
            varargout{ia}=repmat(varargin{ia},maxs);
        end
    else
        varargout{ia}=varargin{ia};
    end
end
