function [ResultsRNN, status, Message] = CNN(TrainingData, TestingData)
    %[~, TrainingData, TestingData, ~, ~, ~, ~] = readExcel();
    parameters = hyperparameters();
    numFeatures = size(TrainingData(:, 1:end-1), 2);
    numResponses = size(TrainingData(:,end), 2);
    filterSize = numFeatures;
    numHiddenUnits = 10;

    layers = [ ...
         % numFeatures is the dimension of your input at each time step
         sequenceInputLayer(numFeatures)

         % numHiddenUnits for the LSTM layer
        lstmLayer(numHiddenUnits,'OutputMode','sequence') 
    
         % numResponses is the dimension of your output at each time step
        fullyConnectedLayer(numResponses) 
    
        
        regressionLayer];


     Epsilon = iqr(TrainingData(:,end))/13.49;
    % Specify training options
    %{
    options = trainingOptions('adam', ...
        'MaxEpochs',100, ...
        'MiniBatchSize',20, ...
        'Verbose',false, ...
        'Plots','none', ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod', 20, ...
        'LearnRateDropFactor', 0.1, ...
        'Metrics','rmse', ...
        'Epsilon', Epsilon, ...
        'Shuffle','every-epoch');
    
    %}
    options = trainingOptions('adam', ...
        'MaxEpochs',100, ...
        'MiniBatchSize',20);

    XTrain = TrainingData(:,1:end-1);
    YTrain = TrainingData(:,end);
    XTest  = TestingData(:, 1:end -1);
    YTest  = TestingData(:, end);


    numSamplesTrain = size(XTrain, 1);
    numSamplesTest  = size(XTest, 1);
    numFeatures = size(XTrain, 2);
    %XTrain = reshape(XTrain, [1, numFeatures, 1, numSamplesTrain]);
    %XTest = reshape(XTest, [1, numFeatures, 1, numSamplesTest]);
    
    net = trainNetwork(XTrain, YTrain, layers, options);
    
    validationPredictions = predict(net,XTrain);
    yfit = predict(net,XTest);



    ResultsRNN.TrainedData = validationPredictions;
    ResultsRNN.TestedData = yfit;
    ResultsRNN.AccuracyTrain = accuracyAnalysis(TrainingData(:, end), validationPredictions);
    ResultsRNN.AccuracyTest  = accuracyAnalysis(TestingData(:, end), yfit);
    pause(0.5);

    R2Train = ResultsRNN.AccuracyTrain(6);
    R2Test  = ResultsRNN.AccuracyTest(6);
    MAPETrain = ResultsRNN.AccuracyTrain(10);
    MAPETest  = ResultsRNN.AccuracyTest(10);

    Message = sprintf(['Train Process\n' ...
                          'R2 %.1f, MAPE %.1f%%\n' ...
                          '-----------------------\n' ...
                          'Test Process\n' ...
                          'R2 %.1f, MAPE %.1f%%' ], R2Train,   ...
                                                    MAPETrain, ...
                                                    R2Test,    ...
                                                    MAPETest      );
  if(R2Train >= 0.98 &&  R2Test >= 0.98 && MAPETrain <= 5 && MAPETest <= 5)
      status = 1;
  elseif (R2Train >= 0.95  &&   R2Train < 0.98 && ...
          R2Test  >= 0.95  &&   R2Test  < 0.98 && ...
          MAPETrain <= 10  &&   MAPETrain > 5  && ...
          MAPETest  <= 10  &&   MAPETest  > 5)
      status = 2;
  elseif (R2Train >= 0.90  &&   R2Train < 0.95 && ...
          R2Test  >= 0.90  &&   R2Test  < 0.95 && ...
          MAPETrain <= 15  &&   MAPETrain > 10  && ...
          MAPETest  <= 15  &&   MAPETest  > 10)
      status = 3;
  else
      status = 4;
  end
end