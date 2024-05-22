classdef Glasbey

    methods(Static)
        function hexmap = to_hex(cmap)
            if isstring(cmap)
                hexmap = cmap;
            else
                hexmap = lower(string(rgb2hex(cmap)));
            end
        end

        function cmap = to_cmap(hexmap)
            if isnumeric(hexmap)
                cmap = hexmap;
            else
                cmap = hex2rgb(hexmap);
            end
        end

        function cmap = create_palette(palette_size, args)
            arguments
                palette_size (1, 1) int32;
                args.grid_space (1, 1) string = "JCh";
                args.hue_bounds (1, 2) double = [0, 360];
                args.lightness_bounds (1, 2) double = [10 90];
                args.chroma_bounds (1, 2) double = [10 90];
                args.colorblind_safe (1, 1) logical = false;
                args.cvd_type (1, 1) string = "deuteranomaly",
                args.cvd_severity (1, 1) double = 50.0,
            end

            hue_bounds = py.tuple(args.hue_bounds);
            lightness_bounds = py.tuple(args.lightness_bounds);
            chroma_bounds = py.tuple(args.chroma_bounds);
            cmap = double(py.numpy.array(py.glasbey.create_palette(palette_size=int32(palette_size), as_hex=false, ...
                grid_space = args.grid_space, ...
                hue_bounds=hue_bounds, lightness_bounds=lightness_bounds, chroma_bounds=chroma_bounds, ...
                colorblind_safe=args.colorblind_safe, cvd_type=args.cvd_type, cvd_severity=args.cvd_severity)));
            %cmap = Glasbey.to_cmap(hexmap);
        end

        function cmap = extend_palette(cmap, palette_size)
            arguments
                cmap 
                palette_size (1, 1) int32;
            end

            if ischar(cmap) || isstring(cmap)
                map = string(cmap);
            else
                map = Glasbey.to_hex(cmap);
            end

            hexmap = string( py.glasbey.extend_palette(map, palette_size=int32(palette_size)) );
            cmap = Glasbey.to_rgb(hexmap);
        end
    end
end
