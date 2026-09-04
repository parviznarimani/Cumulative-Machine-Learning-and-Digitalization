function [MBDF, nMBDF] = MBDFCalculator(trainingInput, testingInput, ...
                                        trainedResults, testedResults)
    
    %% --------------------------------------------------------------------
    % data pre-porcessing unit, make data hemogenious in a single column

    if isrow(trainingInput) 
        trainingInput = trainingInput';        % transpose to column end
    end

    if isrow(testingInput) 
        testingInput = testingInput';          % transpose to column end
    end
    
    if isrow(trainedResults) 
        trainedResults = trainedResults';      % transpose to column end
    end

    if isrow(testedResults) 
        testedResults = testedResults';        % transpose to column end
    end


    inputData_Real = [trainingInput; testingInput];
    inputData_Simulated = [trainedResults; testedResults];

    %% --------------------------------------------------------------------
    % calculating Standard Deviation for Real and Simulated Data with
    % numerically stable implementation

    % SD for Real data (Sigma_f)
    n = length(inputData_Real); 
    mean_val = mean(inputData_Real); 
    Sigma_f = sqrt(sum((inputData_Real - mean_val).^2) / (n-1));
    clear n;
    clear mean_val;

    % SD for Simulated Data (Sigma_r)
    n = length(inputData_Simulated); 
    mean_val = mean(inputData_Simulated); 
    Sigma_r = sqrt(sum((inputData_Simulated - mean_val).^2) / (n-1));
    clear n;
    clear mean_val;

    
    %% --------------------------------------------------------------------
    % calculating centerd RMSE with Real and Simulated Data with
    % numerically stable implementation

    mean_f = mean(inputData_Simulated); 
    mean_r = mean(inputData_Real);

    anomaly_f = inputData_Simulated - mean_f; 
    anomaly_r = inputData_Real - mean_r;

    N = length(inputData_Simulated); 
    cRMSE = sqrt( sum( (anomaly_f - anomaly_r).^2 ) / N );
    
    clear mean_f;
    clear mean_r;
    clear anomaly_r;
    clear anomaly_f;
    clear N;


    %% --------------------------------------------------------------------
    % calculating coefficient of correlation with Real and Simulated Data 
    % with numerically stable implementation
    
    mean_f = mean(inputData_Simulated); 
    mean_r = mean(inputData_Real);

    N = length(inputData_Simulated); 
    covariance = sum( (inputData_Simulated - mean_f) .* ...
                         (inputData_Real - mean_r) ) / (N-1);

    r = covariance / (Sigma_f * Sigma_r);

    clear N;
    clear mean_f;
    clear mean_r;
    clear covariance;


    %% --------------------------------------------------------------------
    % calculating MBDF value and normalized MBDF value

    MBDF = sqrt((1 - r) .^ 2 + (Sigma_r - Sigma_f) .^ 2 + cRMSE .^ 2);
    
    gamma = 0.85;
    nMBDF = exp(-1 .* gamma .* MBDF ./ Sigma_r);




end