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
 
% scroll through folders with measurement data of 59 light bulbs
for code_nr = 1:59
    file_name = 'D:\Matic\Measurements\LED_Light_bulbs\LEDBulbs';+code_nr;
    cd(file_name);
    
    nr_code(code_nr) = code_nr;
    
    % open excel file (measured_values.xlsx) and save new values
    FileName = 'measured_values.xlsx';
    list = 3;
    range = 'A1';
    measured_luminous_flux(code_nr) = xlsread(FileName,list,range);
end
 
%transpose the matrix
measured_luminous_flux = round(measured_luminous_flux.',2);
nr_code = nr_code.';

file_name = "D:\Matic\Measurements";
cd(file_name);
FileName = 'List_of_light_bulbs_V6.xlsx';
list = 1;
range = 'B2:C60';
[~, manufacturer_shop] = xlsread(FileName,list,range);
Cell_Type = manufacturer_shop{1:2};
 
list = 1;
range = 'F2:F60';
measured_luminous_packaging = xlsread(FileName,list,range);

%calculate deviation
deviation = abs(measured_luminous_packaging - measured_luminous_flux);
percentage_deviation = deviation./measured_luminous_packaging*100;
 
% create a table
Table_luminous_flux = table(nr_code,manufacturer_shop,...
    measured_luminous_flux,measured_luminous_packaging,deviation,percentage_deviation);
Table_luminous_flux2 = sortrows(Table_luminous_flux,6)
 
%create excel file (Table_fluctuation_percentage.xls) and save the table
writetable(Table_luminous_flux2,'Table_luminous_flux_deviation_V2.xls','Sheet',1)
