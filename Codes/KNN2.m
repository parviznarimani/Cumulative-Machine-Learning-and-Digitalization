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



regressionKNN = fitcknn(...
                            predictors, ...
                            response, ...
                            'NumNeighbors', 9, ...
                            'Standardize', true, ...
                            'NSMethod','exhaustive', ...
                            'Distance','minkowski', ...
                            "KFold", 5);
validationPredictions = kfoldPredict(regressionKNN);


AccuracyTotoalTrain = accuracyAnalysis(response, validationPredictions);



% -------------------------------------------------------------------------
AccuracyInconelTrain = accuracyAnalysis(InconelTrain(:, end), validationPredictions(1:size(InconelTrain,1)));
AccuracyAluminiumTrain = accuracyAnalysis(AluminiumTrain(:, end), validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1)));
AccuracySteelTrain = accuracyAnalysis(SteelTrain(:, end), validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1)));


AccuracyTrain = [AccuracyTotoalTrain', AccuracyInconelTrain', AccuracyAluminiumTrain', AccuracySteelTrain'];

InconelTrained = validationPredictions(1:size(InconelTrain,1));
AluminiumTrained = validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1));
SteelTrained = validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1));






InconelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Inconel - Test'));
%InconelTested = regressionANN.predict(InconelTest(:, 1:end - 1));
InconelTested = predict(regressionKNN.Trained{1}, InconelTest(:, 1:end-1));
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Inconel Testing Dataset');
AccuracyInconelTest = accuracyAnalysis(InconelTest(:, end), InconelTested);


AluminiumTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Test'));
%AluminiumTested = regressionANN.predict(AluminiumTest(:, 1:end - 1));
AluminiumTested = predict(regressionKNN.Trained{1}, AluminiumTest(:, 1:end-1));
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Aluminium Testing Dataset');
AccuracyAluminiumTest = accuracyAnalysis(AluminiumTest(:, end), AluminiumTested);



SteelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Test'));
%SteelTested = regressionANN.predict(SteelTest(:, 1:end - 1)); 
SteelTested = predict(regressionKNN.Trained{1}, SteelTest(:, 1:end-1));
fprintf('\nANN Method\n');
fprintf('\nAccuracy Metrics for Steel Testing Dataset');
AccuracySteelTest = accuracyAnalysis(SteelTest(:, end), SteelTested);

TotalTestValue = [InconelTest; AluminiumTest; SteelTest];
TotalTested = predict(regressionKNN.Trained{1}, TotalTestValue(:, 1:end - 1));
%TotalTested = regressionGP.predict(TotalTestValue(:, 1:end - 1));
fprintf('\Ensemble Method\n');
fprintf('\nAccuracy Metrics for Total Testing Dataset');
AccuracyTotalTest = accuracyAnalysis(TotalTestValue(:, end), TotalTested);

AccuracyTest = [AccuracyTotalTest', AccuracyInconelTest', AccuracyAluminiumTest', AccuracySteelTest'];


