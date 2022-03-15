[![MATLAB FEX](https://img.shields.io/badge/MATLAB%20FEX-coord2norm-brightgreen.svg)](http://www.mathworks.com/matlabcentral/fileexchange/54254-coord2norm) ![Minimum Version](https://img.shields.io/badge/Requires-R2007a%20%28v7.4%29-orange.svg)

# coordinate2normalized

`COORD2NORM(axishandle, x, y)` takes input XY coordinates, relative to the axes object `axishandle`, and normalizes them to the parent container of `axishandle`. This is useful for functions like `annotation`, where the input XY coordinates are normalized to the parent container of the plotting axes object and not to the data being plotted. `axishandle` must be a valid MATLAB axes object (HG2) or handle (HG1).

`COORD2NORM` returns discrete arrays `xnorm` and `ynorm` of the same size as the input XY coordinate arrays.

Example:

```matlab
myaxes = axes();
x = -10:10;
y = x.^2;
plot(x, y);

[normx, normy] = coord2norm(myaxes, [x(1) x(2)], [y(1) y(2)]);
annotation('arrow', normx, normy);
````

![coord2norm](https://github.com/sco1/sco1.github.io/blob/master/coordinate2normalized/coord2norm.png)

Also included is the helper function `NORM2COORD` which performs the reverse operation, mapping coordinates normalized to the parent container of `axishandle` to the data space of `axishandle`.

Example:

```matlab
myaxes = axes();
x = -10:10;
y = x.^2;
plot(x, y);

normx = [0.5, 0.55];
normy = [0.5, 0.55];
annotation('arrow', normx, normy);

hold on;
[coordx, coordy] = norm2coord(myaxes, normx, normy);
plot(coordx, coordy, 'or')
```

![norm2coord](https://github.com/sco1/sco1.github.io/blob/master/coordinate2normalized/norm2coord.png)
