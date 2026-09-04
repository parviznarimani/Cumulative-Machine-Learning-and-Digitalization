function AccuracyResults = accuracyAnalysis(actual, predicted)
    %--------------------------------------------------------------------------
    % calculating Accuracy and all related parametres
    error = (predicted - actual);
    
    error_percentage = round(error ./ actual .* 100);
    
    accuracy = 100 .* ones(size(error_percentage)) - abs(error_percentage);
    mean_Acc = round(mean(accuracy));
    std_Acc = round(std(accuracy));
    max_Acc = max(accuracy);
    min_Acc = min(accuracy);
    % calculating MSE
    meanActual = mean(actual);
    meanPredicted = mean(predicted);
    a_R = (1 / size( actual , 1))* sum((actual - meanActual) .* (predicted - meanPredicted));
    b_R = sqrt(((1 / size( actual , 1))* sum((actual - meanActual) .^2))) * sqrt(((1 / size( actual , 1))* sum((predicted - meanPredicted) .^2))); 
    R = a_R / b_R;
    
    a_R2 = sum((actual - predicted).^ 2);
    b_R2 = sum((actual - meanActual).^ 2);
    R2 = 1 - (a_R2 / b_R2);
    MSE = (1 / size( actual, 1)) * sum( (predicted - actual).^2);
    RMSE = sqrt(MSE);
    MAE = (1 / size( actual , 1)) * sum( abs(predicted - actual));
    MAPE = (100 / size( actual , 1)) * sum(abs((predicted - actual) ./ actual));
    SMAPE = (100 / size( actual, 1)) * sum(abs((predicted - actual) ./ ((abs(predicted) + abs(actual)) / 2)));
    
    AccuracyResults = [mean_Acc;std_Acc;max_Acc;min_Acc;R;R2;MSE; RMSE; MAE; MAPE; SMAPE];     
end