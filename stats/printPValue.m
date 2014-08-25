function printPValue(name, p)

    fprintf('%20s: ', name);

    sigColor = 'light green';
    verySigColor = 'light yellow';

    if p < 0.0001
        tcprintf(verySigColor, '< 0.0001 ****');
    elseif p < 0.001
        tcprintf(verySigColor, '< 0.001 ***');
    elseif p < 0.01
        tcprintf(sigColor, '< 0.01 **');
    elseif p < 0.05 
        tcprintf(sigColor, '< 0.05 *');
    else
        fprintf('%.3f', p);
    end

    fprintf('\n');

end
