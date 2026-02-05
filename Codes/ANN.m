clear;
close all;
clc;
format bank;


excelFileName = 'FinalDataSet XProject2025 E3';

InconelTrain = table2array(readtable(excelFileName, 'FileType','spreadsheet','Sheet', 'Inconel - Train'));
AluminiumTrain = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Train'));
SteelTrain = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Train'));



predictors = [InconelTrain(:, 1:end - 1); ...
              AluminiumTrain(:, 1:end - 1); ...
              SteelTrain(:, 1:end - 1)    ];

response   = [InconelTrain(:, end); ...
              AluminiumTrain(:, end); ...
              SteelTrain(:, end)     ];


regressionANN = fitrnet(...
        predictors, ...
        response, ...
        'LayerSizes', [30, 100], ...
        'Activations', 'relu', ...
        'Lambda', 0, ...
        'IterationLimit', 1000, ...
        'Standardize', true);

%{
regressionANN = fitrnet(...
    predictors,...
    response, ...
    'OptimizeHyperparameters','auto', ...
    'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'));
%}

partitionedModel = crossval(regressionANN, 'KFold', 5);
validationPredictions = kfoldPredict(partitionedModel);
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Total Training Dataset');
AccuracyTotoalTrain = accuracyAnalysis(response, validationPredictions);



% -------------------------------------------------------------------------
AccuracyInconelTrain = accuracyAnalysis(InconelTrain(:, end), validationPredictions(1:size(InconelTrain,1)));
AccuracyAluminiumTrain = accuracyAnalysis(AluminiumTrain(:, end), validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1)));
AccuracySteelTrain = accuracyAnalysis(SteelTrain(:, end), validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1)));




AccuracyTrain = [AccuracyTotoalTrain', AccuracyInconelTrain', AccuracyAluminiumTrain', AccuracySteelTrain'];



InconelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Inconel - Test'));
InconelTested = regressionANN.predict(InconelTest(:, 1:end - 1)); 
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Inconel Testing Dataset');
AccuracyInconelTest = accuracyAnalysis(InconelTest(:, end), InconelTested);



AluminiumTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Test'));
AluminiumTested = regressionANN.predict(AluminiumTest(:, 1:end - 1)); 
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Aluminium Testing Dataset');
AccuracyAluminiumTest = accuracyAnalysis(AluminiumTest(:, end), AluminiumTested);



SteelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Test'));
SteelTested = regressionANN.predict(SteelTest(:, 1:end - 1)); 
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Steel Testing Dataset');
AccuracySteelTest = accuracyAnalysis(SteelTest(:, end), SteelTested);



TotalTestValue = [InconelTest; AluminiumTest; SteelTest];
TotalTested = regressionANN.predict(TotalTestValue(:, 1:end - 1));
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Total Testing Dataset');
AccuracyTotalTest = accuracyAnalysis(TotalTestValue(:, end), TotalTested);

AccuracyTest = [AccuracyTotalTest', AccuracyInconelTest', AccuracyAluminiumTest', AccuracySteelTest'];



%{
% -------------------------------------------------------------------------
% writing on excel file
filename = 'FinalDataSet XProject2025 Final.xlsx';
xlRange = 'I2';
InconelTrained = validationPredictions(1:size(InconelTrain,1));
writematrix(InconelTrained,filename,"Sheet",'Inconel - Train',"Range",xlRange);
writematrix(InconelTested,filename,"Sheet",'Inconel - Test',"Range",xlRange);

AluminiumTrained = validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1));
writematrix(AluminiumTrained,filename,"Sheet",'Aluminium - Train',"Range",xlRange);
writematrix(AluminiumTested,filename,"Sheet",'Aluminium - Test',"Range",xlRange);

SteelTrained = validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1));
writematrix(SteelTrained,filename,"Sheet",'Steel - Train',"Range",xlRange);
writematrix(SteelTested,filename,"Sheet",'Steel - Test',"Range",xlRange);
%}