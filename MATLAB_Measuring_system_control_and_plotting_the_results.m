%###################################################################
%#  Measuring system for determining the quality of LED light
%#  sources for households
%#
%#  Made by: Matic Markovič
%#  Date: June 2021
%#  Version: 14
%###################################################################

clc
clear
close

% current lamp data and location for saving diagrams
mkdir ../LED_Light_bulbs 'LEDBulb1'
folder = 'D:\Matic\Measurements\LED_Light_bulbs\LEDBulb1';
 
UNO_stepper = serialport("COM7",9600);
UNO_lux = serialport("COM4",9600);
pause(2)
 
%% A N G U L A R   D I S T R I B U T I O N   O F   L I G H T
write(UNO_stepper,5,'char')     % disable stepper motor
write(UNO_stepper,3,'char')     % turn ON the light bulb
pause(1)    % delay
write(UNO_stepper,6,'char')     % enable stepper motor
write(UNO_stepper,1,'char')     % rotate the sliding table to the limit switch - starting position
pause(4)
 
initial_angle= -90;       % initial measurement angle
step_angle = 3.6;       % angle [°]
nr_steps = 50;        % since starting with 0 -> +1 is added
 
for i=1:(nr_steps+1)
    pause(1)
    flush(UNO_lux)
    pause(0.1)
    readline(UNO_lux);
    readline(UNO_lux);
    readline(UNO_lux);
    readline(UNO_lux);
    data_num = str2num(readline(UNO_lux));
    if data_num >= 0
        illuminance(i) = data_num;    % save the data in the matrix
	   % the command to move the motor for a certain angle is sent to the arduino
        write(UNO_stepper,2,'char')                   
        pause(1);   % delay
    end
end
 
E = illuminance;
d = 0.9;            % distance from the light bulb to the photocell [m]
I = E*d^2;          % calculation of luminosity [cd]
 
% generate angles for plotting
angle(1) = 0;
for i=1:(nr_steps+1)
    angle(i) = initial_angle + step_angle *(i-1);
end
angle_radians = deg2rad(angle);    % conversion to radians
angle2 = angle + 90;
angle_radians2 = deg2rad(angle2);
 
figure(1)
% plot the polar diagram
polarplot(angle_radians2,illuminance, 'r', 'LineWidth',1); 
pax = gca;
pax.ThetaDir = 'counterclockwise';
pax.ThetaZeroLocation = 'bottom';
pax.GridColor = 'k';
pax.MinorGridColor = 'k';
pax.RMinorGrid = 'on';
pax.ThetaMinorGrid = 'on';
pax.GridAlpha = 0.3;
pax.MinorGridAlpha = 0.15;set(findall(gcf,'-property','FontSize'),'FontSize',8)
pax.GridLineStyle = '-';
pax.MinorGridLineStyle = '--';
thetaticks(0:10:360)
thetalim([0 180])
rticks(0:20:500)
pax.ThetaAxis.Label.String = 'Polar diagram of luminous intensity';
pax.RAxis.Label.String = 'svetilnost [cd]';
thetaticklabels({'angle (\gamma): 0°     ','10°','20°','30°','40°','50°','60°',...
    '70°','80°','90°','100°','110°','120°','130°','140°','150°','160°','170°','180°'})
 
%%   C A L C U L AT I O N   O F   L U M I N O U S   F L U X
gamma1(1) = 0;
gamma1(2) = 1.8;
n = 1;
for j = 3:50
    gamma1(j) = 1.8 + 3.6 * n;
    n = n + 1;
end
gamma1(51) = 178.2;
gamma1_rad = deg2rad(gamma1);
 
gamma2(1) = 1.8;
gamma2(2) = 5.4;
m = 3;
for j = 3:50
    gamma2(j) = gamma1(j) + 3.6;
end
gamma2(51) = 180;
gamma2_rad = deg2rad(gamma2);
 
omega = 2*pi*(cos(gamma1_rad)-cos(gamma2_rad));
 
luminous_flux = sum(omega .* I);
 
% correction of the calculated luminous flux
luminous_flux = luminous_flux*1.105994;
 
%% RED PITAYA - 300 kHz DATA ACQUISITION
write(UNO_stepper,1,'char')     % totate the rotary sliding table to the limit switch - starting position
pause(4)
write(UNO_stepper,5,'char')     % disable stepper motor
 
freq = 300000;    % data acquisition frequency [Hz]
t0 = 1/freq;
plot_color = {'#0072BD'};
format shortg
 
current_time = clock;
system('rpsa_client.exe -h 169.254.33.31 -p TCP -f ./ -t wav -s 150000');
write(UNO_stepper,4 ,'char')    % turn OFF the light bulb
 
fix(current_time);
year = current_time(:,1);
month = current_time(:,2);
day = current_time(:,3);
hour = current_time(:,4);
minutes = current_time(:,5);
second = current_time(:,6);
second = round(second);
 
if month <= 9   %if the value "month"<=9, add "0" before the value
    month=num2str(month,'%02.f');
end
 
if day <= 9     %if the value "day"<=9, add "0" before the value
    day=num2str(day,'%02.f');
end
 
date = datetime;       %save current date in "date"
dst = isdst(datetime);      %check for winter / summer time
if dst == 0         %winter time -> reduce value "hour" for 2
    hour=hour-2;
end
if hour <= 9     %if the value "hour"<=9, add "0" before the value
    hour=num2str(hour,'%02.f');
end
 
if minutes <= 9     %if the value "min"<=9, add "0" before the value
    minutes=num2str(minutes,'%02.f');
end
 
if second <= 9     %if the value "second"<=9, add "0" before the value
    second=num2str(second,'%02.f');
end
 
%create file name
file_name_str ="data_file_"+year+"-"+month+"-"+day+"_"+hour+"-"+minutes+"-"+second+".wav";
 
if isfile(file_name_str) == 0
    if ischar(second) == 1
        m=str2num(second);
        second_minus_1=m-1;
    else
        second_minus_1=second-1;
    end
    if second_minus_1 <= 9     %if the value "second"<=9, add "0" before the value
        second_minus_1=num2str(second_minus_1,'%02.f');
    end
    new_file_name_str = "data_file_"+year+"-"+month+"-"+day+"_"+hour+"-"+minutes+"-"+second_minus_1+".wav";
end
 
if isfile(file_name_str) == 1
    file_name_chr = convertStringsToChars(file_name_str);
    [captured_data,Fs] = audioread(file_name_chr);
else
    file_name_chr = convertStringsToChars(new_file_name_str);
    [captured_data,Fs] = audioread(file_name_chr);
end
 
%from the matrix of both channels stores the captured data in a new separate matrix
luminous_flux = captured_data(:,1);
electric_current = captured_data(:,2);

luminous_flux = luminous_flux - 0.010748;   %offset
 
%% L U M I N O U S   F L U X
%Gaussian filter - luminous flux
sigma = 70;
gaussFilter = gausswin(6*sigma + 1)';
gaussFilter = gaussFilter / sum(gaussFilter);
filtr_luminous_flux = conv(luminous_flux, gaussFilter, 'same');
 
%select the plot area along the x axis
range = 200:length(luminous_flux)-200;
filtr_luminous_flux = filtr_luminous_flux(range);
[~, index]=max(filtr_luminous_flux);
org_index= range(index);
 
averaging_proportion = 1;           %proportion of samples for averaging [%]
proportion_discarded = 10;   %proportion of discarded samples [%]
 
nr = round(length(filtr_luminous_flux) * averaging_proportion/100);     % number of samples for averaging
nr_int = round(nr);         %rounded calculated number
proportion_discarded = 1-proportion_discarded/100;
 
A = maxk(filtr_luminous_flux,nr_int);
B = mink(A,round(nr_int*proportion_discarded));
peak = mean(B);
 
filtr_luminous_flux_pu = filtr_luminous_flux/peak;      %conversion of y axis from voltage to per-unit system
 
t_filtr = 0:t0:(length(filtr_luminous_flux_pu)-1)*t0;
 
% calculation of the maximum value, from 1% of the minimum values
D = mink(filtr_luminous_flux_pu, round(length(filtr_luminous_flux_pu)*0.01));
format shortG
percentage_of_oscillation = round(100-max(D)*100,2);
 
figure(2)
subplot(2,1,1)
plot(t_filtr*1000,filtr_luminous_flux_pu,'Color','[0 0.4470 0.7410]','LineWidth', 0.8)
ylim([0 max(filtr_luminous_flux_pu)*1.05])
title('The time course of the luminous flux')
xlabel('\itt \rm[ms]')
ylabel('\itluminous flux \rm[pu]')
 
%% E L E C T R I C   C U R R E N T
% shunt resistor value and current calculation (Ohm's law)
Rshunt = 1;     %[Ohm]
electric_current = electric_current/Rshunt;
 
%Gaussian filter - electric current
sigma = 20;
gaussFilter = gausswin(6*sigma + 1)';
gaussFilter = gaussFilter / sum(gaussFilter);
filtr_electric_current = conv(electric_current, gaussFilter, 'same');
 
%select the plot area along the x axis
range = 200:length(luminous_flux)-200;
filtr_electric_current = filtr_electric_current(range);
[value, index]=max(filtr_electric_current);
org_index= range(index);
 
filtr_electric_current_avg = filtr_electric_current - mean(filtr_electric_current);
 
C = (max(filtr_electric_current_avg)-min(filtr_electric_current_avg));
C = C * 0.05;
 
subplot(2,1,2)
plot(t_filtr*1000,filtr_electric_current_avg,'Color','[0.6350 0.0780 0.1840]','LineWidth', 0.8)
grid on
ylim([min(filtr_electric_current_avg)-C max(filtr_electric_current_avg)+C])
title('The time course of the electric current')
xlabel('\itt \rm[ms]')
ylabel('\iti \rm[A]')
set(findall(gcf,'-property','FontSize'),'FontSize',8)
 
%% P L O T T I N G   T W O   P E R I O D S
filtr_luminous_flux_pu_2_per = filtr_luminous_flux_pu(50000:50000+18000);
filtr_electric_current_avg_2_per = filtr_electric_current_avg(50000:50000+18000);
t_2_per = 0:t0:(length(filtr_luminous_flux_pu_2_per)-1)*t0;
 
figure(3)
subplot(2,1,1)
colororder(plot_color)
plot(t_2_per*1000,filtr_luminous_flux_pu_2_per,'Color','[0 0.4470 0.7410]','LineWidth', 0.8)
grid on
ylim([min(filtr_luminous_flux_pu_2_per)/1.005 max(filtr_luminous_flux_pu_2_per)*1.005])
title('The time course of the luminous flux')
xlabel('\itt \rm[ms]')
ylabel('\itluminous flux \rm[pu]')

subplot(2,1,2)
colororder('#A2142F')
plot(t_2_per*1000,filtr_electric_current_avg_2_per,'Color','[0.6350 0.0780 0.1840]','LineWidth', 0.8)
grid on
ylim([min(filtr_electric_current_avg)-C max(filtr_electric_current_avg)+C])
title('The time course of the electric current')
xlabel('\itt \rm[ms]')
ylabel('\iti \rm[A]')
set(findall(gcf,'-property','FontSize'),'FontSize',8)
 
%% F F T,   S P E C T R O G R A M  -  0 to 150 kHz
%FFT
figure(4)
subplot(2,1,1)
luminous_flux_avg = luminous_flux-mean(luminous_flux);
 
timeLimits = [0 0.5]; % seconds
frequencyLimits = [0 150000]; % Hz
 
luminous_flux_avg_ROI = luminous_flux_avg(:);
sampleRate = 300000; % Hz
startTime = 0; % seconds
minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;
maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(luminous_flux_avg_ROI)-1))+1;
luminous_flux_avg_ROI = luminous_flux_avg_ROI(minIdx:maxIdx);
 
% search for frequencies with highest amplitude
[p,f] = pspectrum(luminous_flux_avg_ROI,sampleRate,'FrequencyLimits',frequencyLimits);
f=f/1000;
local_max = islocalmax(p);
frequencies = local_max .* f;
spectral_power = local_max .* p;
max_spectral_power = maxk(spectral_power,5);
y_limit = max(max_spectral_power);

n = 1;
for j = 1:5
    index(n) = find(p==max_spectral_power(n));
    n = n+1;
end
frequencies_150kHz = f(index)*1000;
 
peak = max(max_spectral_power);
p_pu = p/peak;      %y-axis conversion to per-unit system
y_limit_pu = y_limit/peak;
 
plot(f,p_pu,'LineWidth', 0.8)
title('Frequency luminance spectrum')
ylim([0 y_limit_pu])
xticks([0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150])
xlabel('\itf \rm[kHz]')
ylabel('\itSpectral power of signal \rm[pu]')

%Spectrogram
timeLimits = [0 0.5]; % seconds
frequencyLimits = [0 150000]; % Hz
leakage = 0;
timeResolution = 0.5; % seconds
overlapPercent = 50;
reassignFlag = true;
 
subplot(2,1,2)
luminous_flux_avg_ROI = luminous_flux_avg(:);
sampleRate = 300000; % Hz
startTime = 0; % seconds
timeValues = startTime + (0:length(luminous_flux_avg_ROI)-1).'/sampleRate;
minIdx = timeValues >= timeLimits(1);
maxIdx = timeValues <= timeLimits(2);
luminous_flux_avg_ROI = luminous_flux_avg_ROI(minIdx&maxIdx);
timeValues = timeValues(minIdx&maxIdx);
 
pspectrum(luminous_flux_avg_ROI,timeValues,'spectrogram', 'FrequencyLimits',...
    frequencyLimits,'Leakage',leakage,'TimeResolution',timeResolution,'OverlapPercent',...
    overlapPercent,'Reassign',reassignFlag);
 
colorbar('off')
view(90,90)
colormap('jet');
caxis('auto');
set(findall(gcf,'-property','FontSize'),'FontSize',8)
yticks([0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150])
title('Spectrogram')
xlabel('\itt \rm[s]')
ylabel('\itf \rm[kHz]')
 
%% Red Pitaya - data acquisition 30 kHz
command = input('Set data acquisition to 30 kHz -> press 1');
 
if command ==1
    write(UNO_stepper,3,'char')     %turn ON the light bulb
    pause(1)    %delay
    
    freq = 30000;    %frequency of data acquisition [Hz]
    t0 = 1/freq;
    plot_color = {'#0072BD'};
    format shortg
    
    current_time = clock;
    system('rpsa_client.exe -h 169.254.33.31 -p TCP -f ./ -t wav -s 15000');
    pause(1);
    write(UNO_stepper,4 ,'char')    %turn OFF the light bulb
    
    fix(current_time);
    year = current_time(:,1);
    month = current_time(:,2);
    day = current_time(:,3);
    hour = current_time(:,4);
    minutes = current_time(:,5);
    second = current_time(:,6);
    second = round(second);
    
    if month <= 9   % if the value "month"<=9, add "0" before the value
        month=num2str(month,'%02.f');
    end
    
    if day <= 9     %if the value "day"<=9, add "0" before the value
        day=num2str(day,'%02.f');
    end
    
    date = datetime;       % save current date in "date"
    dst = isdst(datetime);      %check for winter / summer time
    if dst == 0         %winter time -> reduce value "hour" for 2
        hour=hour-2;
    end
    if hour <= 9     %if the value "hour"<=9, add "0" before the value
        hour=num2str(hour,'%02.f');
    end
    
    if minutes <= 9     %if the value "min"<=9, add "0" before the value
        minutes=num2str(minutes,'%02.f');
    end
    
    if second <= 9     %if the value "second"<=9, add "0" before the value
        second=num2str(second,'%02.f');
    end
    
    %create file name
    file_name_str ="data_file_"+year+"-"+month+"-"+day+"_"+hour+"-"+minutes+"-"+second+".wav";
    
    if isfile(file_name_str) == 0
        if ischar(second) == 1
            m=str2num(second);
            second_minus_1=m-1;
        else
            second_minus_1=second-1;
        end
%if the value "second"<=9, add "0" before the value
        if second_minus_1 <= 9     
            second_minus_1=num2str(second_minus_1,'%02.f');
        end
        new_file_name_str = "data_file_"+year+"-"+month+"-"+day+"_"+hour+"-"+minutes+"-"+second_minus_1+".wav";
    end
    
    if isfile(file_name_str) == 1
        file_name_chr = convertStringsToChars(file_name_str);
        [captured_data,Fs] = audioread(file_name_chr);
    else
        file_name_chr = convertStringsToChars(new_file_name_str);
        [captured_data,Fs] = audioread(file_name_chr);
    end
    
    %from the matrix of both channels stores the captured data in a new separate matrix
    luminous_flux = captured_data(:,1);
    
    %% F F T,   S P E V T R O G R A M -  0 to 500 Hz
    %FFT
    figure(5)
    subplot(2,1,1)
    luminous_flux_avg = luminous_flux-mean(luminous_flux);
    
    timeLimits = [0 0.5]; % seconds
    frequencyLimits = [0 500]; % Hz
    
    luminous_flux_avg_ROI = luminous_flux_avg(:);
    sampleRate = 30000; % Hz
    startTime = 0; % seconds
    minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;
    maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(luminous_flux_avg_ROI)-1))+1;
    luminous_flux_avg_ROI = luminous_flux_avg_ROI(minIdx:maxIdx);
    
    % search for frequencies with highest amplitude
    [p,f] = pspectrum(luminous_flux_avg_ROI,sampleRate,'FrequencyLimits', frequencyLimits);
    local_max = islocalmax(p);
    frequencies = local_max .* f;
    spectral_power = local_max .* p;
    max_spectral_power = maxk(spectral_power,5);
    
    n = 1;
    for j = 1:5
        index(n) = find(p==max_spectral_power(n));
        n = n+1;
    end
    frequencies_500Hz = f(index);
    
    peak = max(max_spectral_power);
    p_pu = p/peak;      %y-axis conversion to per-unit system
    
    plot(f,p_pu,'LineWidth', 0.8)
    title('Frequency luminance spectrum')
    xlabel('\itf \rm[Hz]')
    ylabel('\itSpectral power of signal \rm[pu]')
    
    %Spectrogram
    timeLimits = [0 0.5]; % seconds
    frequencyLimits = [0 500]; % Hz
    leakage = 0;
    timeResolution = 0.5; % seconds
    overlapPercent = 50;
    reassignFlag = true;
    
    subplot(2,1,2)
    luminous_flux_avg_ROI = luminous_flux_avg(:);
    sampleRate = 30000; % Hz
    startTime = 0; % seconds
    timeValues = startTime + (0:length(luminous_flux_avg_ROI)-1).'/ sampleRate;
    minIdx = timeValues >= timeLimits(1);
    maxIdx = timeValues <= timeLimits(2);
    luminous_flux_avg_ROI = luminous_flux_avg_ROI(minIdx&maxIdx);
    timeValues = timeValues(minIdx&maxIdx);
    
    pspectrum(luminous_flux_avg_ROI,timeValues,'spectrogram', 'FrequencyLimits',...
        frequencyLimits,'Leakage',leakage,'TimeResolution',timeResolution,'OverlapPercent',...
        overlapPercent,'Reassign',reassignFlag);
    
    colorbar('off')
    view(90,90)
    colormap('jet');
    caxis('auto');
    set(findall(gcf,'-property','FontSize'),'FontSize',8)
    title('Spectrogram')
    xlabel('\itt \rm[s]')
    ylabel('\itf \rm[Hz]')
    
    %% F F T,   S P E C T R O G R A M -  0 to 10 kHz
    %FFT
    figure(6)
    subplot(2,1,1)
    
    timeLimits = [0 0.5]; % seconds
    frequencyLimits = [0 10000]; % Hz
    
    luminous_flux_avg_ROI = luminous_flux_avg(:);
    sampleRate = 30000; % Hz
    startTime = 0; % seconds
    minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;
    maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(luminous_flux_avg_ROI)-1))+1;
    luminous_flux_avg_ROI = luminous_flux_avg_ROI(minIdx:maxIdx);
    
    % search for frequencies with highest amplitude
    [p,f] = pspectrum(luminous_flux_avg_ROI,sampleRate,'FrequencyLimits', frequencyLimits);
    f=f/1000;
    local_max = islocalmax(p);
    frequencies = local_max .* f;
    spectral_power = local_max .* p;
    max_spectral_power = maxk(spectral_power,5);
    
    clear index
    n = 1;
    for j = 1:5
        index(n) = find(p==max_spectral_power(n));
        n = n+1;
    end
    
    frequencies_10kHz = f(index)*1000;
    
    peak = max(max_spectral_power);
    p_pu = p/peak;      %y-axis conversion to per-unit system
    
    plot(f,p_pu,'LineWidth', 0.8)
    title('Frequency luminance spectrum')
    xlabel('\itf \rm[kHz]')
    ylabel('\itSpectral power of signal \rm[pu]')
    
    %Spectrogram
    timeLimits = [0 0.5]; % seconds
    frequencyLimits = [0 10000]; % Hz
    leakage = 0;
    timeResolution = 0.5; % seconds
    overlapPercent = 50;
    reassignFlag = true;
    
    subplot(2,1,2)
    luminous_flux_avg_ROI = luminous_flux_avg(:);
    sampleRate = 30000; % Hz
    startTime = 0; % seconds
    timeValues = startTime + (0:length(luminous_flux_avg_ROI)-1).'/ sampleRate;
    minIdx = timeValues >= timeLimits(1);
    maxIdx = timeValues <= timeLimits(2);
    luminous_flux_avg_ROI = luminous_flux_avg_ROI(minIdx&maxIdx);
    timeValues = timeValues(minIdx&maxIdx);
    
    pspectrum(luminous_flux_avg_ROI,timeValues,'spectrogram','FrequencyLimits',...
        frequencyLimits,'Leakage',leakage,'TimeResolution',timeResolution, 'OverlapPercent',...
        overlapPercent,'Reassign',reassignFlag);
    
    colorbar('off')
    view(90,90)
    colormap('jet');
    caxis('auto');
    set(findall(gcf,'-property','FontSize'),'FontSize',8)
    title('Spektrogram')
    xlabel('\itt \rm[s]')
    ylabel('\itf \rm[kHz]')
    
    %%  S A V E   D I A G R A M S
    figure(1)
    exportgraphics(gcf,'Polar diagram 180°.png','Resolution',600)
    movefile('Polar diagram 180°.png',folder);
    figure(2)
    exportgraphics(gcf,'Luminous flux and electric current - 500 ms.png','Resolution',600)
    movefile('Luminous flux and electric current - 500 ms.png',folder);
    figure(3)
    exportgraphics(gcf,'Luminous flux and electric current - 60 ms.png', 'Resolution',600)
    movefile('Luminous flux and electric current - 60 ms.png',folder);
    figure(4)
    exportgraphics(gcf,'FFT 0 to 150 kHz.png','Resolution',600)
    movefile('FFT 0 to 150 kHz.png',folder);
    figure(5)
    exportgraphics(gcf,'FFT 0 to 500 Hz.png','Resolution',600)
    movefile('FFT 0 to 500 Hz.png',folder);
    figure(6)
    exportgraphics(gcf,'FFT 0 to 10 kHz.png','Resolution',600)
    movefile('FFT 0 to 10 kHz.png',folder);
    
    save('workspace.mat')
    movefile('workspace.mat',folder);
    
    %% E X C E L  -  S A V E   M E A S U R E D   V A L U E S
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    baseFileName = 'measured_values.xlsx';
    fullFileName = fullfile(folder, baseFileName);
    xlswrite(fullFileName ,percentage_of_oscillation,'Percentage of oscillation');
    xlswrite(fullFileName ,luminous_flux,'Luminous flux');
    xlswrite(fullFileName ,freq_to_500Hz,'Freq to 500 Hz');
    xlswrite(fullFileName ,freq_to_10kHz,'Freq to 10 kHz');
    xlswrite(fullFileName ,freq_to_150kHz,'Freq to 150 kHz');
end