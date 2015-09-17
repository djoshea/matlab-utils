function fcat(figh)

    if nargin < 1
        figh = gcf;
    end

    propMB = get(figh, 'MenuBar');
    propTB = get(figh, 'ToolBar');
    
    set(figh, 'MenuBar', 'none');
    set(figh, 'ToolBar', 'none');
    
    drawnow;
    jf = getjframe(figh);
    rec = jf.getBounds();
    bufferedImage = javaObjectEDT('java.awt.image.BufferedImage', rec.width, rec.height, java.awt.image.BufferedImage.TYPE_INT_ARGB);

    jf.paint(bufferedImage.getGraphics());

    %%

    % Create temp file.
    temp = java.io.File.createTempFile('matlabfigure', '.png');

    % Use the ImageIO API to write the bufferedImage to a temporary file
    import javax.imageio.ImageIO;
    ImageIO.write(bufferedImage, 'png', temp);

    % Delete temp file when program exits.
    temp.deleteOnExit();

    imgcat(char(temp));
    
    set(figh, 'MenuBar', propMB);
    set(figh, 'ToolBar', propTB);
end