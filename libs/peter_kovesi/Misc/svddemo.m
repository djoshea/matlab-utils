% DEMO of SVD and eigenvalues for a 2x2 transformation matrix
%
% Usage: svddemo(M)
%     where M is a 2x2 matrix
%
% The function plots a circle of unit vectors in varying hues and then plots the
% transformed vectors with their corresponding hues to show how they have been
% rotated and scaled.  If the eigenvalues are real the eigenvectors are plotted
% in white.
%
%   [U, S, V'] = svd(M)
%
% 1) The top-left plot is initial circle of unit vectors in varying hues.
% 2) The bottom-left plot is the unit vectors transformed by the rotation
%    matrix V'.
% 3) The bottom right plot shows the result after applying the scaling matrix S.
% 4) The top-right plot shows the final result after applying the rotation
%     matrix U to the scaled scaled vectors from the previous step.
%
% Examples: 
% Generate random 2x2 matrix and pass it to svddemo
%  M = rand(2); svddemo(M);
%
% Generate random symmetric 2x2 matrix and pass it to svddemo
%  M = rand(2); svddemo(M*M');

% PK March 2004

function svddemo(M)
    
    if ~all(size(M) == [2,2])
        error('Input matrix must be 2x2')
    end
    
    lw = 3;  % linewidth for plots
    fs = 16; % font size
    
    [u,s,v] = svd(M);   % M = u*s*v'
    [ev,ed] = eig(M);   % M*ev = ev*ed
                        % ed is a diagonal matrix of eigenvalues
                        % ev is a matrix with columns forming the eigenvectors
                        
    nvectors = 80;
    theta = [0:2*pi/nvectors: 2*pi - 2*pi/nvectors];
    
    x = cos(theta);
    y = sin(theta);
    
    hue = [0:1/nvectors: 1 - 1/nvectors];
    
    hsv = [hue' ones(nvectors,2)];
    rgb = hsv2rgb(hsv);
    
    r = M*[x;y];
    tx = r(1,:);
    ty = r(2,:);
    
    
    vX = v'*[x;y];
    vx = vX(1,:);
    vy = vX(2,:);
    
    svX = s*v'*[x;y];
    svx = svX(1,:);
    svy = svX(2,:);
    
    figure(1); clf
    subplot(2,2,1);
    for n = 1:nvectors
        line([0 x(n)],[0 y(n)],'color', rgb(n,:), 'linewidth',lw);
    end
    title('[x]','fontsize',fs,'fontweight','bold')
    axis equal, axis off
    
    subplot(2,2,2);
    for n = 1:nvectors
        line([0 tx(n)],[0 ty(n)],'color', rgb(n,:), 'linewidth',lw);
    end
    title('[ T ][x] = [u s v'' ][x]','fontsize',fs,'fontweight','bold')
    axis equal, axis off
    
    pv = u(:,1)*s(1,1);
    mv = u(:,2)*s(2,2);
    subplot(2,2,2);
    line([0 pv(1)],[0 pv(2)],'color',[0 0 0],'linewidth',lw);
    line([0 mv(1)],[0 mv(2)],'color',[0 0 0],'linewidth',lw);
    
    % Plot v'x
    
    subplot(2,2,3);
    for n = 1:nvectors
        line([0 vx(n)],[0 vy(n)],'color', rgb(n,:), 'linewidth',lw);
    end
    title('[v'' ][x]','fontsize',fs,'fontweight','bold')
    axis equal, axis off
    
    % Plot sv'x
    
    subplot(2,2,4);
    for n = 1:nvectors
        line([0 svx(n)],[0 svy(n)],'color', rgb(n,:), 'linewidth',lw);
    end
    line([0 s(1,1)],[0 0],'color',[0 0 0],'linewidth',lw);
    line([0 0],[0 s(2,2)],'color',[0 0 0],'linewidth',lw);
    title('[s v'' ][x]','fontsize',fs,'fontweight','bold')
    axis equal, axis off
    
    
    % plot aligner axis
    
    subplot(2,2,3);
    line([0 v(1,1)],[0 v(1,2)],'color',[.2 .2 .2],'linewidth',lw);
    line([0 v(2,1)],[0 v(2,2)],'color',[.2 .2 .2],'linewidth',lw);
    
    subplot(2,2,1);
    line([0 1],[0 0],'color',[.2 .2 .2],'linewidth',lw);
    line([0 0],[0 1],'color',[.2 .2 .2],'linewidth',lw);
    
    
    % if eigenvectors are real plot them
    if isreal(ev)
        subplot(2,2,1);
        line([0 ev(1,1)],[0 ev(2,1)],'color', [1 1 1], 'linewidth', lw);
        line([0 ev(1,2)],[0 ev(2,2)],'color', [1 1 1], 'linewidth', lw);
        
        subplot(2,2,2);
        line([0 ev(1,1)*ed(1,1)],[0 ev(2,1)*ed(1,1)],'color', [1 1 1], 'linewidth', lw);
        line([0 ev(1,2)*ed(2,2)],[0 ev(2,2)*ed(2,2)],'color', [1 1 1], 'linewidth', lw);
    end

