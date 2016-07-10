classdef cellRunner < handle
  properties ( SetAccess = private )
    fileName
    fileInfo
    cellInfo
    cellNames = {};
  end
  methods 
    function obj = cellRunner ( file ) % constructor
      if nargin == 0                        
        obj.fileName = 'cellScript.m';      % default file for testing
      else
        obj.fileName = file;                % store user file
      end
      obj.parseFile();                      % read the file into memory
    end
    function obj = parseFile ( obj )
      if ~isempty ( obj.fileInfo )                        % on parsing check to see if its been parsed before
        if isequal ( obj.fileInfo, dir ( obj.fileName ) ) % Check date stamp (has cell file been modified
%           disp ( 'file not changed - reading skipped' );  % if not skip
%           reading 
          return
        end
      end
      obj.fileInfo = dir ( obj.fileName );                % store file info
      fid = fopen ( obj.fileName );                       % open file for reading
      if fid ~= -1
        index = 0;                                        % this is the index of each cell
        inCell = false;                                   % has it found a cell to start reading
        lines = cell(0);                                  
        while ( true )
          line = fgetl ( fid );                           % read the line in the file
          if line == -1; break; end                       % check for the end of the file
          sLine = strtrim ( line );                       % trim any white space
          if length ( sLine ) > 2 && strcmp ( sLine(1:2), '%%' ) % check to see if its the start of a cell
            if index > 0                                  % Store the last cell data                
              obj.cellInfo{index} = lines;                % in class to run when required
            end
            index = index + 1;                            % increment the index
            obj.cellNames{index} = strtrim ( sLine(3:end) ); % save the name of the cell
            lines = cell(0);                              % re-initialise the lines var
            inCell = true;                                % the start of the cells have been found
          elseif inCell                                   % if reading a cell array
            lines{end+1} = line;                          % add each line to the lines var
          end          
        end
        if index > 0                                      % make sure and save the last cell when finished reading
          obj.cellInfo{index} = lines;
        end
        fclose ( fid );
      else
        error ( 'cellRunner:fileError', 'unable to read file' );
      end
    end
    function obj = runCell ( obj, arg )
      % obj.runCell ( 'cellName' );
      % obj.runCell ( index );
      obj.parseFile();                                    % check that the file hasn't been changed
      if ischar ( arg )                                   % if user provided a char then search for it
        index = strcmp ( arg, obj.cellNames );            % find the index
        if ~any ( index )                                 % check it was found
          error ( 'cellRunner:notFound', '%s not found', arg ); 
        end
      else
        index = arg;                                      % if index is an integer (not checked - assumed if not char)
        if index < 1 || index > length ( obj.cellInfo )   % check integer is valid
          error ( 'cellRunner:notFound', 'Index %d not found', arg );
        end
      end
      commands = obj.cellInfo{index}{1};                  % start to build the command to execute.
      inBlock = false;
      for ii=2:length(obj.cellInfo{index})                % loop around - ignoring any commented lines.
        nextLine = strtrim ( obj.cellInfo{index}{ii} ); 
        if inBlock
          if length ( nextLine ) == 2 && strcmp ( nextLine, '%}' );
            inBlock = false;
          end
          continue
        end
        if length ( nextLine ) == 2 && strcmp ( nextLine, '%{' );
          inBlock = true;
          continue
        end
        if length ( nextLine ) >= 1 && strcmp ( nextLine(1), '%' )
          continue;
        end
        commands = sprintf ( '%s;%s', commands, obj.cellInfo{index}{ii} ); % build a parge string to eval
      end
      evalin('base',commands);                            % eval the expression in the base workspace.
    end
  end
end