function allowEditorFullScreen()

% activate mac os full screen on the editor window
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    jEditor = desktop.getGroupContainer('Editor').getTopLevelAncestor;
    com.apple.eawt.FullScreenUtilities.setWindowCanFullScreen(jEditor, true);

end