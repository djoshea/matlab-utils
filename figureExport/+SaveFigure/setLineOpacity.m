function setLineOpacity(s, alpha)
% stores information in UserData struct to cause saveFigure to render
% lines as translucent when exporting to svg

    for i = 1:length(s)
        
        % tag it as translucent for saveFigure to
        % pick up during SVG authoring
        userdata = get(s(i),'UserData');
        userdata.svg.LineAlpha = alpha;
        set(s(i),'UserData', userdata);
            
        if ~verLessThan('matlab', '8.4')
            % first cache marker opacity
            if isempty(s(i).MarkerHandle)
                continue;
            end
            edge = s(i).MarkerHandle.EdgeColorData;
            face = s(i).MarkerHandle.FaceColorData;
            
            % use RGBA color specification
            s(i).Color(4) = alpha;
            
            drawnow; % needed to prevent marker handle being overwritten sometimes
            
            % restore marker opacity
            s(i).MarkerHandle.EdgeColorData = edge;
            s(i).MarkerHandle.FaceColorData = face;
            
        end
    end

end