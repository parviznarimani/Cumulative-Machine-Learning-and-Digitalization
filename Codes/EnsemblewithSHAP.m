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



regressionEnsemble = fitrensemble( ...
                            predictors, ...
                            response, ...
                            "Learners","tree", ...
                            "Method","LSBoost",...
                            "LearnRate", 0.1, ...
                            "NumLearningCycles", 100, ...
                            'NumBins',50, ...
                            "KFold", 5);

validationPredictions = kfoldPredict(regressionEnsemble);


%% ------------------------------------------------------------------------
Mdl = fitrensemble(predictors, response, 'Method', 'LSBoost', 'NumLearningCycles', 100, 'NumBins',50);

idx = randperm(size(predictors, 1), 100);

queryPoint = predictors(idx,:);


shapObj = shapley(Mdl, predictors,QueryPoints=queryPoint);
%plot(shapObj);
%plot(shapObj, 'Summary');
swarmchart(shapObj)