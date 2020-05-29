% IMSETBORDER - sets pixels on image border to a value 
%
% Usage:  im = imsetborder(im, b, v)
%
% Arguments:
%           im - Image.
%            b - Border size .
%            v - Value to set image borders to (defaults to 0)
%                Can also be the string 'replicate' or 'rep' in which case
%                missing values on the border by replicating values from just 
%                inside the border.
%
% See also: IMPAD, IMTRIM

% Peter Kovesi
% www.peterkovesi.com/matlabfns/

% June  2010
% May   2018  Added replicate option

function im = imsetborder(im, b, v)
    
    if ~exist('v','var'),  v = 0;  end    

    assert(b >= 1, 'Padding size must be >= 1')
    b = round(b);  % ensure integer
    
    [rows,cols,channels] = size(im);

    if isnumeric(v)     % Numeric case
        for chan = 1:channels
            im(1:b,:,chan) = v;
            im(end-b+1:end,:,chan) = v;        
            im(:,1:b,chan) = v;
            im(:,end-b+1:end,chan) = v;                
        end
      
    elseif strncmpi(v, 'replicate',3)   % Replicate case
        % Fill missing values on border by replicating values from just inside the
        % border
        for chan = 1:channels
            for n = 1:b
               im(n,:,chan) = im(b+1,:,chan); 
               im(end-n+1,:,chan) = im(end-b,:,chan); 
            
               im(:,n,chan) = im(:,b+1,chan); 
               im(:,end-n+1,chan) = im(:,end-b,chan); 
            end
        end
        
    else
        error('Border value must be numeric or ``replicate''');
    end