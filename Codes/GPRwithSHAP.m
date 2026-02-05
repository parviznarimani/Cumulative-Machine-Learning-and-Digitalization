clear;
close all;
clc;
format bank;


excelFileName = 'FinalDataSet XProject2025 E3';

InconelTrain = (readtable(excelFileName, 'FileType','spreadsheet','Sheet', 'Inconel - Train'));
AluminiumTrain = (readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Train'));
SteelTrain = (readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Train'));



predictors = [InconelTrain(:, 1:end - 1); ...
              AluminiumTrain(:, 1:end - 1); ...
              SteelTrain(:, 1:end - 1)    ];

response   = [InconelTrain(:, end); ...
              AluminiumTrain(:, end); ...
              SteelTrain(:, end)     ];


phi = [mean(std(table2array(predictors)));1;std(table2array(response))/sqrt(2)];
Sigma = 1 * std(table2array(response)) + 1 * std(table2array(response));


regressionGP = fitrgp(...
    predictors, ...
    response, ...
    'BasisFunction', 'constant', ...
    'KernelFunction', 'rationalquadratic', ...
    'KernelParameters', phi, ...
    'Sigma', Sigma, ...
    'Standardize', true);

idx = randperm(size(predictors, 1), 100);

queryPoint = predictors(idx,:);

shapObj = shapley(regressionGP, predictors,QueryPoints=queryPoint);
%plot(shapObj);
%plot(shapObj, 'Summary');
swarmchart(shapObj)