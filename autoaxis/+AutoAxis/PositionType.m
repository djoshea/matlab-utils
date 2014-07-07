classdef PositionType < uint32
    enumeration
        Top (1)
        Bottom (2)
        VCenter (3)
        Height (4)

        Left (5)
        Right (6) 
        HCenter (7)
        Width (8)
    end

    methods
        function field = getDirectField(pos)
            import AutoAxis.PositionType;

            switch(pos)
                case PositionType.Top 
                    field = 'top';
                case PositionType.Bottom 
                    field = 'bottom';
                case PositionType.Height
                    field = 'height';
                case PositionType.VCenter
                    field = 'vcenter';
                
                case PositionType.Left
                    field = 'left';
                case PositionType.Right
                    field = 'right';
                case PositionType.HCenter
                    field = 'hcenter';
                case PositionType.Width
                    field = 'width';
            end
        end
        
        function tf = isX(pos)
            import AutoAxis.PositionType;
            tf = ismember(pos, [PositionType.Left, PositionType.Right, PositionType.HCenter, PositionType.Width]);
        end

        function tf = isY(pos)
            import AutoAxis.PositionType;
            tf = ismember(pos, [PositionType.Bottom, PositionType.Top, PositionType.VCenter, PositionType.Height]);
        end
        
        function tf = specifiesSize(pos)
            import AutoAxis.PositionType;
            tf = ismember(pos, [PositionType.Width, PositionType.Height]);
        end

        function fields = getLocationFieldsAffected(pos)
            % list PositionType fields potentially affected by this type of anchor
            switch(pos)
                case {PositionType.Top, PositionType.Bottom, PositionType.VCenter, PositionType.Height}
                    fields = {'top', 'bottom', 'height'};
                case {PositionType.Left, PositionType.Right, PositionType.HCenter, PositionType.Width}
                    fields = {'left', 'right', 'width'};
            end
        end
    end
end
