% IMPAD - pads the boundary of an image.
%
% Usage:  paddedim = impad(im, b, v)
%
% Arguments:     im - Image to be padded (greyscale or colour)
%                 b - Width of padding boundary to be added
%                 v - This may be:
%                     1) A numeric value to be assigned to the padded area.
%                     2) 'replicate' which results in the edges of the image 
%                        being replicated outwards to form the padding. 
%                     4) 'taper' which results in the padded edges of the
%                        image being linearly interpolated towards the
%                        cyclically opposite edge.  
%                     5) 'cosine' which results in the padded edges of the
%                        image form a cosine transition from one edge towards 
%                        the cyclically opposite edge of the image.
%                     6) If v is omitted it defaults to 0.
%
% Returns: paddedim - Padded image of size rows+2*b x cols+2*b
%
% Tapering is perhaps the best for frequency domain filtering. In practice I
% observe no significant advantage of using cosine padding over a linear taper
% in reducing edge effects.
%
% See also: IMTRIM, IMSETBORDER

% Peter Kovesi
% www.peterkovesi.com/matlabfns/
%
% June    2010
% January 2011  Added optional padding value.
% October 2017  Added replicate, taper and cosine options.

function pim = impad(im, b, v)

    if b == 0
        pim = im;
        return;
    end

    if ~exist('v', 'var'), v = 0; end
    
    [rows, cols, channels] = size(im);    
    
    if isnumeric(im) && isnumeric(v);   % numeric padding
        pim = v*ones(rows+2*b, cols+2*b, channels, class(im));
        
    elseif isnumeric(im) && strcmp(v, 'replicate')
        pim = zeros(rows+2*b, cols+2*b, channels, class(im));
    
    elseif isnumeric(im) && (strcmp(v, 'taper') || strcmp(v, 'cosine'))
        pim = zeros(rows+2*b, cols+2*b, channels, 'double');        
        
    elseif islogical(im)                % Logical image
        if v == true
            pim = true(rows+2*b, cols+2*b, channels);
        else
            pim = false(rows+2*b, cols+2*b, channels);
        end    
    else
        error('Unrecognized padding type')
    end
    
    pim(1+b:rows+b, 1+b:cols+b, :) = im;
    
    if strcmp(v, 'replicate') 
        % Replicate image edge values outwards
        for r = 1:b
            pim(r, 1+b:cols+b, :) = im(1,:,:);          % top
            pim(rows+b+r, 1+b:cols+b,:) = im(end,:,:);  % bottom
            
            pim(1+b:rows+b, r, :) = im(:,1,:);          % left
            pim(1+b:rows+b, cols+b+r, :) = im(:,end,:); % right
        end
        
        % Replicate corners
        for ch = 1:channels
            pim(1:b, 1:b, ch) = im(1,1,ch);             % top left
            pim(1:b, cols+b+1:end, ch) = im(1,cols,ch); % top right
            
            pim(rows+b+1:end, 1:b, ch) = im(rows,1,ch); % bottom left
            pim(rows+b+1:end, cols+b+1:end, ch) = im(rows,cols,ch); % bottom right
        end
        
    elseif strcmp(v, 'taper')
        % Generate padding by linearly interpolating towards opposite edge of image.
        delta = 1/(2*b+1);  % Fractional change that forms the tapered steps 
        top_bot = pim(1+b,:) - pim(rows+b,:);
        for n = 1:b
            pim(n,:) =  pim(1+b,:) - (b-n+1)*delta*top_bot;     % top
            pim(rows+b+n,:) =  pim(rows+b,:) + n*delta*top_bot; % bottom
        end

        left_right = pim(:,1+b) - pim(:,cols+b);
        for n = 1:b
            pim(:,n) =  pim(:,1+b) - (b-n+1)*delta*left_right;     % left
            pim(:,cols+b+n) =  pim(:,cols+b) + n*delta*left_right; % right
        end
    
    elseif strcmp(v, 'cosine')
        % Generate padding by forming a cosine transition from one edge towards
        % the opposite edge of the image.
        deltaTheta = pi/(2*b+1); % Angular change across each padding element
        top_bot = pim(1+b,:) - pim(rows+b,:);
        for n = 1:b
            pim(n,:) =  pim(1+b,:) - (0.5-cos((b-n+1)*deltaTheta)/2)*top_bot;     % top
            pim(rows+b+n,:) =  pim(rows+b,:) + (0.5-cos(n*deltaTheta)/2)*top_bot; % bottom
        end

        left_right = pim(:,1+b) - pim(:,cols+b);
        for n = 1:b
            pim(:,n) =  pim(:,1+b) - (0.5-cos((b-n+1)*deltaTheta)/2)*left_right;     % left
            pim(:,cols+b+n) =  pim(:,cols+b) + (0.5-cos(n*deltaTheta)/2)*left_right; % right
        end
    
    end