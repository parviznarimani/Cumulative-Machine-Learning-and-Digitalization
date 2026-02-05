function [MSE] = accuracyAnalysisMSE(actual_Data, predicted_Data)

%--------------------------------------------------------------------------
% calculating Accuracy and all related parametres
error = (predicted_Data - actual_Data);

error_percentage = round(error ./ actual_Data .* 100);

accuracy = 100 .* ones(size(error_percentage)) - abs(error_percentage);
mean_Acc = round(mean(accuracy));
std_Acc = round(std(accuracy));
max_Acc = max(accuracy);
min_Acc = min(accuracy);
% calculating MSE
meanActual = mean(actual_Data);
meanPredicted = mean(predicted_Data);
a_R = (1 / size( actual_Data , 1))* sum((actual_Data - meanActual) .* (predicted_Data - meanPredicted));
b_R = sqrt(((1 / size( actual_Data , 1))* sum((actual_Data - meanActual) .^2))) * sqrt(((1 / size( actual_Data , 1))* sum((predicted_Data - meanPredicted) .^2))); 
R = a_R / b_R;

a_R2 = sum((actual_Data - predicted_Data).^ 2);
b_R2 = sum((actual_Data - meanActual).^ 2);
R2 = 1 - (a_R2 / b_R2);
MSE = (1 / size( actual_Data , 1)) * sum( (predicted_Data - actual_Data).^2);
RMSE = sqrt(MSE);
MAE = (1 / size( actual_Data , 1)) * sum( abs(predicted_Data - actual_Data));
MAPE = (100 / size( actual_Data , 1)) * sum(abs((predicted_Data - actual_Data) ./ actual_Data));
SMAPE = (100 / size( actual_Data , 1)) * sum(abs((predicted_Data - actual_Data) ./ ((abs(predicted_Data) + abs(actual_Data)) / 2)));

results = [mean_Acc;std_Acc;max_Acc;min_Acc;R;R2;MSE; RMSE; MAE; MAPE; SMAPE];
%disp(' ');
%disp('Table Analysis: selected test data for main data-set');

disp(' ');
print_table(results ,...
            {'%8g'},...
            {'Results'},...
            {'Analysis Type','Acc(mean)','Acc(std)','Acc(MAX)','Acc(Min)','R','R2','MSE','RMSE','MAE','MAPE','SMAPE'}, ...
            'printBorder',...
            1);
disp(' ');

%AccuracyResults = [R2, MSE, RMSE, MAE, MAPE, SMAPE]';
AccuracyResults = [mean_Acc, RMSE, R2, MAPE, MSE];
end