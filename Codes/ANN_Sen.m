close all;
clc;
format bank;


excelFileName = 'FinalDataSet XProject2025 E3';

InconelTrain = table2array(readtable(excelFileName, 'FileType','spreadsheet','Sheet', 'Inconel - Train'));
AluminiumTrain = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Aluminium - Train'));
SteelTrain = table2array(readtable(excelFileName, 'FileType','spreadsheet', 'Sheet','Steel - Train'));

headers = readtable(excelFileName, 'FileType','spreadsheet','Sheet', 'Inconel - Train');
headers = (headers.Properties.VariableNames)';

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

partitionedModel = crossval(regressionANN, 'KFold', 5);
validationPredictions = kfoldPredict(partitionedModel);




MSE = accuracyAnalysisMSE(response, validationPredictions);
MSE_Inconel = accuracyAnalysisMSE(InconelTrain(:, end), validationPredictions(1:size(InconelTrain,1)));
MSE_Aluminum = accuracyAnalysisMSE(AluminiumTrain(:, end), validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1)));
MSE_Steel = accuracyAnalysisMSE(SteelTrain(:, end), validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1)));
%AccuracyTrain = [AccuracyTotoalTrain', AccuracyInconelTrain', AccuracyAluminiumTrain', AccuracySteelTrain'];


All_MSE_i = zeros(size(predictors,2),4);
W_i = zeros(size(predictors,2),4);

for i = 1:size(predictors,2)
    input = predictors;
    input(:,i) = [];
    regressionANN = fitrnet(...
                        predictors, ...
                        response, ...
                        'LayerSizes', [30, 100], ...
                        'Activations', 'relu', ...
                        'Lambda', 0, ...
                        'IterationLimit', 1000, ...
                        'Standardize', true);

    partitionedModel = crossval(regressionANN, 'KFold', 5);
    validationPredictions = kfoldPredict(partitionedModel);
    MSE_i = accuracyAnalysisMSE(response, validationPredictions);
    MSE_Inconel_i = accuracyAnalysisMSE(InconelTrain(:, end), validationPredictions(1:size(InconelTrain,1)));
    MSE_Aluminum_i = accuracyAnalysisMSE(AluminiumTrain(:, end), validationPredictions(1 + size(InconelTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1)));
    MSE_Steel_i = accuracyAnalysisMSE(SteelTrain(:, end), validationPredictions(1 + size(InconelTrain,1) + size(AluminiumTrain,1):size(InconelTrain,1) + size(AluminiumTrain,1) + size(SteelTrain,1)));
    
    All_MSE_i(i,:) = [MSE_i,MSE_Inconel_i,MSE_Aluminum_i,MSE_Steel_i];
    W_i(i,:) = [MSE_i / MSE,MSE_Inconel_i / MSE_Inconel, MSE_Aluminum_i / MSE_Aluminum,MSE_Steel_i / MSE_Steel];

end 



