clear all;
clc;
close all;

inputTableAllData_Inconel = readtable('FinalDataSet XProject2025 E2.xlsx', ...
                                      'Sheet','Inconel');

cv = cvpartition(size(inputTableAllData_Inconel,1),'HoldOut',0.15);
idx = cv.test;

dataTrain_Inconel = inputTableAllData_Inconel(~idx,:);
dataTest_Inconel  = inputTableAllData_Inconel(idx,:);



%% ------------------------------------------------------------------------
inputTableAllData_Aluminium = readtable('FinalDataSet XProject2025 E2.xlsx', ...
                                      'Sheet','Aluminium');

cv = cvpartition(size(inputTableAllData_Aluminium,1),'HoldOut',0.15);
idx = cv.test;

dataTrain_Aluminium = inputTableAllData_Aluminium(~idx,:);
dataTest_Aluminium  = inputTableAllData_Aluminium(idx,:);



%% ------------------------------------------------------------------------
inputTableAllData_Steel = readtable('FinalDataSet XProject2025 E2.xlsx', ...
                                      'Sheet','Steel');

cv = cvpartition(size(inputTableAllData_Steel,1),'HoldOut',0.15);
idx = cv.test;

dataTrain_Steel = inputTableAllData_Steel(~idx,:);
dataTest_Steel  = inputTableAllData_Steel(idx,:);



clear cv
clear idx