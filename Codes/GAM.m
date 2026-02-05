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



regressionGAM = fitrgam( ...
                            predictors, ...
                            response, ...
                            "FitStandardDeviation",true, ...
                            "InitialLearnRateForInteractions", 0.5, ...
                            "InitialLearnRateForPredictors", 0.5, ...
                            "Interactions","all", ...
                            "MaxNumSplitsPerInteraction", 10, ...
                            "MaxNumSplitsPerPredictor", 2, ...
                            "MaxPValue", 0.5, ...
                            "KFold", 5);


validationPredictions = kfoldPredict(regressionGAM);
fprintf('\nGAM Method\n');
fprintf('\nAccuracy Metrics for Total Training Dataset');
AccuracyTotoalTrain = accuracyAnalysis(response, validationPredictions);
AccuracyInconelTrain = accuracyAnalysis(InconelTrain(:, end), validationPredictions(1:size(InconelTrain,1)));
AccuracyAluminiumTrain = accuracyAnalysis(AluminiumTrain(:, end), validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1)));
AccuracySteelTrain = accuracyAnalysis(SteelTrain(:, end), validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1)));
AccuracyTrain = [AccuracyTotoalTrain', AccuracyInconelTrain', AccuracyAluminiumTrain', AccuracySteelTrain'];




InconelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Inconel - Test'));
%InconelTested = regressionGAM.predict(InconelTest(:, 1:end - 1)); 
InconelTested = predict(regressionGAM.Trained{1}, InconelTest(:, 1:end - 1));
fprintf('\nGAM Method\n');
fprintf('\nAccuracy Metrics for Inconel Testing Dataset');
AccuracyInconelTest = accuracyAnalysis(InconelTest(:, end), InconelTested);



AluminiumTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Test'));
%AluminiumTested = regressionGAM.predict(AluminiumTest(:, 1:end - 1)); 
AluminiumTested = predict(regressionGAM.Trained{1}, AluminiumTest(:, 1:end - 1));
fprintf('\nGAM Method\n');
fprintf('\nAccuracy Metrics for Aluminium Testing Dataset');
AccuracyAluminiumTest = accuracyAnalysis(AluminiumTest(:, end), AluminiumTested);



SteelTest = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Test'));
%SteelTested = regressionGAM.predict(SteelTest(:, 1:end - 1)); 
SteelTested = predict(regressionGAM.Trained{1}, SteelTest(:, 1:end - 1));
fprintf('\nGAM Method\n');
fprintf('\nAccuracy Metrics for Steel Testing Dataset');
AccuracySteelTest = accuracyAnalysis(SteelTest(:, end), SteelTested);




AccuracyTest = [AccuracyInconelTest', AccuracyAluminiumTest', AccuracySteelTest'];





% -------------------------------------------------------------------------
% writing on excel file
filename = 'FinalDataSet XProject2025 Final.xlsx';
xlRange = 'E2';
InconelTrained = validationPredictions(1:size(InconelTrain,1));
writematrix(InconelTrained,filename,"Sheet",'Inconel - Train',"Range",xlRange);
writematrix(InconelTested,filename,"Sheet",'Inconel - Test',"Range",xlRange);

AluminiumTrained = validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1));
writematrix(AluminiumTrained,filename,"Sheet",'Aluminium - Train',"Range",xlRange);
writematrix(AluminiumTested,filename,"Sheet",'Aluminium - Test',"Range",xlRange);

SteelTrained = validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1));
writematrix(SteelTrained,filename,"Sheet",'Steel - Train',"Range",xlRange);
writematrix(SteelTested,filename,"Sheet",'Steel - Test',"Range",xlRange);