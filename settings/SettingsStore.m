classdef SettingsStore < handle 
% This class enables you to access and manipulate machine-specific settings in
% an easy to implement and systematic way. Examples of such settings might be
% paths to common data or figure directories, values of particular constants, 
% etc. By storing these machine-specific settings in a SettingsStore object 
% rather than in code, you can maintain the same code base on multiple machines.
% 
% SettingsStore is an abstract class which handles the details of saving and
% accessing specific settings for you. You simply override this class and
% add in any machine-specific settings as additional properties. In code, 
% you can access these settings using YourSettingsStoreClass('propertyName').
%
% First Usage:
%   settings = YourSettingsStoreClass();
%   settings.propertyName = value;
%   settings.saveSettings(pathToMatFileFolder);
%
%      Call .saveSettings(directory) where directory is a folder on the Matlab
%      search path where you would like to save the .mat file containing 
%      the SettingsStore object. Typically, you would want this directory
%      to be outside of a source control repo being shared across these machines.
%
% Accessing saved setting values:
%   settings = YourSettingsStoreClass();
%   value = settings.propertyName
%   
% Updating settings:
%   Simply set the value of the properties you wish to set and call saveSettings:
%      settings = YourSettingsStoreClass();
%      settings.propertyName = newValue;
%      settings.saveSettings();
%

    methods(Static, Abstract)
        % return a string like 'DirectorySettings' to indicate the name of the
        % .mat file where the settings will be saved. The .mat suffix is not
        % necessary to include in name. The path information as to where to save
        % the file will be specified when calling .saveSettings()
        name = getMatFileName()
    end

    properties(Hidden)
        % this will determine where the matFile should be saved
        % initially it is empty, but when first saved, this will be filled in
        % so that future calls to saveSettings do not require the directory
        % to be specified
        matFilePath
    end

    properties(Dependent, SetAccess=private)
        matFileName
    end

    properties(Access=private)
        isLoaded = false;
    end

    methods(Access=protected)
        function obj = SettingsStore()
            obj.loadSettings();
        end

        function filename = buildMatFileFullName(obj, path)
            matName = obj.getMatFileName();
            if length(matName) < 4 || ~strcmp(matName(end-3:end), '.mat')
                matName = [matName '.mat'];
            end
            filename = fullfile(path, matName);
        end
    end

    methods
        function name = get.matFileName(obj)
            path = obj.matFilePath;
            name = obj.buildMatFileFullName(path);
        end

        function value = getValue(this, propertyName)
            this.loadSettings();
            value = this.(propertyName);
        end
    end

    methods(Access=protected)
        % load settings from disk if not loaded yet
        function loadSettings(this)
            if ~this.isLoaded;
                this.reloadSettings();
            end
        end

        function name = getMatVarName(this)
            name = 'settings';
        end

        % force loading of settings even if already loaded
        % access the settings from disk, copy all properties from the saved
        % instance to this one
        function reloadSettings(this)
            varName = this.getMatVarName();
            matName = this.getMatFileName();

            % load the mat file and return the instance within
            try
                data = load(matName);
                if ~isfield(data, varName)
                   warning('%s SettingsStore file is invalid. Does not contain variable %s', ...
                       matName, varName);
                   instance = [];
                else 
                    instance = data.(varName);
                    if ~isa(instance, 'SettingsStore')
                        warning('%s SettingsStore file is invalid. Does not SettingsStore object', ...
                            matName);
                        instance = [];
                    end
                end
            catch
                warning('Could not locate %s on path to load SettingsStore');
                instance = [];
            end

            if ~isempty(instance)
                this.transferDataFrom(instance);
                this.isLoaded = true;
            end
        end

        % copy all property values from dest to src
        function transferDataFrom(dest, src)
            assert(isa(dest, class(src)), 'Class names must match exactly');

            meta = metaclass(src);
            propInfo = meta.PropertyList;
            for iProp = 1:length(propInfo)
                info = propInfo(iProp);
                name = info.Name;
                if info.Dependent && isempty(info.SetMethod)
                    continue;
                end
                if info.Constant
                    continue;
                end
                dest.(name) = src.(name);
            end
        end
    end

    methods
        function saveSettings(settings, path)
            % path argument only necessary if settings.matFilePath is empty
            % (which means its likely the first save)
            if nargin < 2
                if isempty(settings.matFilePath)
                    error('Usage: .saveSettings(path)');
                else
                    path = settings.matFilePath;
                end
            end
            settings.matFilePath = path;
            filename = settings.buildMatFileFullName(path);
            varName = settings.getMatVarName();
            data.(varName) = settings;

            save(filename, '-struct', 'data');
            fprintf('%s saved to %s\n', class(settings), filename);
        end
    end

end

