function setDesktopWindowTitle(str)
    if ~isempty(com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame)
        com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame.setTitle(str);
    end
end