# Text to Image
Matlab function to rasterize Unicode text to binary images.

## Usage:
```matlab
c = texttoimage(txt, font_size, font_name, font_type)
```
* **txt** is a string to be rasterized.
* **font_size** is a scalar, default 32 pixels.
* **font_name** is a string, default 'Monospaced'. Note that if txt is unicode, the font specified must support it.
* **font_type** is a string of a comination of 'b' (bold) or 'i' (italic). Leave unspecified for the normal typeface.
* **c** is a cell array of rasterized binary images.

## Example:
```matlab
c = texttoimage('離離原上草', 600, 'SimSun');
figure; imagesc(cat(2, c{:})); axis image;
```

![Result:](/example.png)
