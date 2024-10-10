clc, clearvars

% Load params
run('params.m');

% Set up and CAN channel
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

% Control loop
keepRunning = true;

while keepRunning
    % Prompt user for new throttle value
    throttlePos = input('Enter new throttle position (0-100) or -1 to stop: ');
    
    % Check if user wants to exit
    if throttlePos == -1
        keepRunning = false;
        break;
    end
    
    % Ensure throttle position is within valid range
    if throttlePos <= -1 || throttlePos >= maxThrottle
        disp('Invalid throttle position.');
        continue;
    end
    
    % Convert throttle position to CAN data (0-100% to 0x0000 - 0xFEFF)
    % Value in little endian
    mappedValue = mapRange(throttlePos, 0, 100, hex2dec('0x0000'), hex2dec('0xFEFF'));
    command_msg.Data(2) = bitshift(mappedValue, -8); % High byte
    command_msg.Data(1) = bitand(mappedValue, 255)  % Low byte
    
    % Transmit the CAN message
    transmit(canCh, command_msg);
    
    pause(0.1); % Wait for a short time before next iteration
end

% Cleanup: Stop and delete the CAN channel
stop(canCh);
delete(canCh);