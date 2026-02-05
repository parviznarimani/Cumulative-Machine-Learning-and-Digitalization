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

Epsilon = iqr(response)/13.49;
BC = iqr(response)/1.349;


regressionKernel = fitrkernel( ...
                            predictors, ...
                            response, ...
                            "Epsilon",Epsilon, ...
                            "BoxConstraint", BC, ...
                            "KernelScale", 5, ...
                            "Learner","svm", ...
                            "NumExpansionDimensions", 100, ...
                            "Standardize", true, ...
                            "KFold", 5);

validationPredictions = kfoldPredict(regressionKernel);
fprintf('\nLinear Method\n');
fprintf('\nAccuracy Metrics for Total Training Dataset');
AccuracyTotoalTrain = accuracyAnalysis(response, validationPredictions);
AccuracyInconelTrain = accuracyAnalysis(InconelTrain(:, end), validationPredictions(1:size(InconelTrain,1)));
AccuracyAluminiumTrain = accuracyAnalysis(AluminiumTrain(:, end), validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1)));
AccuracySteelTrain = accuracyAnalysis(SteelTrain(:, end), validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1)));
AccuracyTrain = [AccuracyTotoalTrain', AccuracyInconelTrain', AccuracyAluminiumTrain', AccuracySteelTrain'];




InconelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Inconel - Test'));
%InconelTested = regressionKernel.predict(InconelTest(:, 1:end - 1)); 
InconelTested = predict(regressionKernel.Trained{1}, InconelTest(:, 1:end - 1));
fprintf('\nLinear Method\n');
fprintf('\nAccuracy Metrics for Inconel Testing Dataset');
AccuracyInconelTest = accuracyAnalysis(InconelTest(:, end), InconelTested);



AluminiumTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Test'));
%AluminiumTested = regressionKernel.predict(AluminiumTest(:, 1:end - 1)); 
AluminiumTested = predict(regressionKernel.Trained{1}, AluminiumTest(:, 1:end - 1));
fprintf('\nLinear Method\n');
fprintf('\nAccuracy Metrics for Aluminium Testing Dataset');
AccuracyAluminiumTest = accuracyAnalysis(AluminiumTest(:, end), AluminiumTested);



SteelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Test'));
%SteelTested = regressionKernel.predict(SteelTest(:, 1:end - 1)); 
SteelTested = predict(regressionKernel.Trained{1}, SteelTest(:, 1:end - 1));
fprintf('\nLinear Method\n');
fprintf('\nAccuracy Metrics for Steel Testing Dataset');
AccuracySteelTest = accuracyAnalysis(SteelTest(:, end), SteelTested);


AccuracyTest = [AccuracyInconelTest', AccuracyAluminiumTest', AccuracySteelTest'];





% -------------------------------------------------------------------------
% writing on excel file
filename = 'FinalDataSet XProject2025 Final.xlsx';
xlRange = 'D2';
InconelTrained = validationPredictions(1:size(InconelTrain,1));
writematrix(InconelTrained,filename,"Sheet",'Inconel - Train',"Range",xlRange);
writematrix(InconelTested,filename,"Sheet",'Inconel - Test',"Range",xlRange);

AluminiumTrained = validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1));
writematrix(AluminiumTrained,filename,"Sheet",'Aluminium - Train',"Range",xlRange);
writematrix(AluminiumTested,filename,"Sheet",'Aluminium - Test',"Range",xlRange);

SteelTrained = validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1));
writematrix(SteelTrained,filename,"Sheet",'Steel - Train',"Range",xlRange);
writematrix(SteelTested,filename,"Sheet",'Steel - Test',"Range",xlRange);
