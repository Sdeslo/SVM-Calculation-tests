function mappedValue = mapRange(value, oldMin, oldMax, newMin, newMax)
    % Ensure the input value is within the old range
    if value < oldMin
        value = oldMin;
    elseif value > oldMax
        value = oldMax;
    end
    
    % Perform linear mapping
    mappedValue = newMin + ((value - oldMin) * (newMax - newMin) / (oldMax - oldMin));
    
    % Convert the result to uint16
    mappedValue = uint16(mappedValue);
end
