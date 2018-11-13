function mode = getMatlabOutputMode()

    if ~isempty(getenv('JUPYTER_KERNEL'))
        % we are running inside a Jupyter kernel
        % but from the desktop or not?
        if ~isempty(getenv('JUPYTER_CURRENTLY_EXECUTING'))
            mode = "notebook";
        else
            mode = "desktop";
        end
    else
        % not running inside jupyter, either desktop or terminal
         if usejava('desktop')
             mode = "desktop";
         else
             mode = "terminal";
         end
    end
        
end