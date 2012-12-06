classdef ExampleSettingsStore < SettingsStore

    properties
        dataPath
        figurePath
    end

    methods(Static)
        function name = getMatFileName()
            name = 'exampleSettings';
        end
    end

end
