% CAN channel params
vendor = 'Vector';  % Replace with vendor name
device = 'VN1610 1'; % Replace with device name
channel = 1;
extended = true;
bus_speed = 250000;

% Inverter parmas
start_id = hex2dec('0x4050000'); % ECU_m5start
start_dlc = 1;
command_id = hex2dec('0x4150000'); % ECU_m5command
command_dlc = 2;

% Throttle params
minThrottle = 0; % Minimum throttle position (0%)
maxThrottle = 100; % Maximum throttle position (100%)
power_factor = 1 % Power limiter
id = hex2dec('0x4150000'); % ECU_m5command
dlc = 2;

% Timeout between each iteration
timeout = 0.05;