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
    list = 2;
    range = 'A1';
    fluctuation_percentage(code_nr) = xlsread(FileName,list,range);
end
 
%transpose the matrix
fluctuation_percentage = fluctuation_percentage.';
nr_code = nr_code.';
 
file_name = "D:\Matic\Measurements";
cd(file_name);
FileName = 'List_of_light_bulbs_V6.xlsx';
list = 1;
range = 'B2:C60';
[~, manufacturer_shop] = xlsread(FileName,list,range);
Cell_Type = manufacturer_shop{1:2};

% create a table
Table_fluctuation_percentage = table(nr_code,manufacturer_shop,fluctuation_percentage)
Table_fluctuation_percentage2 = sortrows(Table_fluctuation_percentage,3)

%create excel file (Table_fluctuation_percentage.xls) and save the table
writetable(Table_fluctuation_percentage2,'Table_fluctuation_percentage.xls','Sheet',1)
