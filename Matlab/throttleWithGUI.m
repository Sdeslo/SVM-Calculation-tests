clc, clearvars

% Load params
run('params.m');

% Set up CAN channel
canCh = canChannel(vendor, device, channel);
configBusSpeed(canCh, bus_speed);
start(canCh);

% Start drive inverter
start_msg = canMessage(start_id, extended, start_dlc);
start_msg.Data(1) = 1;
transmit(canCh, start_msg);

% Initialize throttle position
throttlePos = 0;

% Create throttle CAN message
command_msg = canMessage(command_id, extended, command_dlc);

% Create a UI figure
fig = uifigure('Name', 'Throttle Control', 'Position', [100, 100, 300, 200]);
fig.UserData = true; % keepRunning flag stored in UserData

% Create a slider to control throttle position
slider = uislider(fig, 'Position', [100, 150, 150, 3], ...
                  'Limits', [0 100], ...
                  'ValueChangedFcn', @(src, event) updateValue(src.Value));

 % Callback function to update the variable from the slider
function updateValue(newValue) 
    sliderValue = newValue;
    % Update the label to reflect the new slider value
    label.Text = ['Throttle Position: ', num2str(sliderValue)];
end

% Create a label to display the throttle position
label = uilabel(fig, 'Position', [100, 80, 150, 22], ...
                'Text', 'Throttle Position: 0');

% Create a button to stop the loop
stopButton = uibutton(fig, 'push', 'Position', [100, 40, 100, 22], ...
                      'Text', 'Stop', ...
                      'ButtonPushedFcn', @(btn, event) stopLoop(fig));

% Function to stop the loop
function stopLoop(figHandle)
    figHandle.UserData = false; % Update keepRunning flag
end

 while fig.UserData
    % Get the current value of the slider
    throttlePos = slider.Value * power_factor;
    
    % Update Label
    label.Text = ['Throttle Position: ', num2str(throttlePos)];

    % Convert throttle position to CAN data (0-100% to 0-65279)
    mappedValue = mapRange(throttlePos, 0, 100, hex2dec('0x0000'), hex2dec('0xFEFF'));
    command_msg.Data(2) = bitshift(mappedValue, -8); % High byte
    command_msg.Data(1) = bitand(mappedValue, 255);  % Low byte

    % Transmit the CAN message
    transmit(canCh, command_msg);

    pause(timeout); % Adjust the pause time as needed
 end

% Cleanup: Stop and delete the CAN channel
stop(canCh);
delete(canCh);
close(fig); % Close the UI figure