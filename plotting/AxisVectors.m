classdef AxisVectors < handle

    methods
        function associate(av, axh)
            axis(axh, 'off'); 
            h = rotate3d(axh);
            set(h, 'ActionPreCallback', @av.actionPreCallback);
            set(h, 'ActionPostCallback', @av.actionPostCallback);
        end
    end


    methods
        function h = getHandles(av, event)
            axh = event.Axes;
            data = get(axh, 'UserData');
            if isempty(data) || ~isstruct(data) || ~isfield(data, 'axisVectors')
                h = [];
                return;
            else
                h = data.axisVectors;
            end
        end

        function actionPreCallback(av, h, event)

        end

        function actionPostCallback(av, h, event)
            axh = event.Axes;
        end
    end

end
