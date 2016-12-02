%
% * input
% 1) datafile
% 2) pRatioTrain:[0,1] sampled positives / original postives for training
% 3) nRatioTrain:[1,171] sampled negatives / sampled postives for training
% 4) nRatioTest:[1,171] sampled negative / sampled positives for testing
%
% * output
% 1) Xtrain: sampled training data (random positves; random negatives)
% 2) Xtest: sampled testing dadta (random postives; random negatives)

function [Xtrain, Xtest] = sampling (datafile, pRatioTrain, nRatioTrain, nRatioTest)

    pNum = 6879;        % the number of positives
    nNum = 1176868;     % the number of negatives

    pNumTrain = floor(pNum * pRatioTrain);      % the number of sampled postives for training
    nNumTrain = floor(pNumTrain * nRatioTrain); % the number of sampled negatives for training
    
    pNumTest = pNum - pNumTrain;                % the number of sampled positive for testing
    nNumTest = floor(pNumTest * nRatioTest);    % the number of sampled negative for testing
    
    fname = strsplit(datafile,'.');
    
    X = csvread(datafile);          % load train data
    [xnum, dim] = size(X);
    
    Xpos = cell(pNum,1);            % separate pos/neg from the file
    Xneg = cell(nNum,1);
    Xposidx = 0; Xnegidx = 0;
    for i=1:xnum
       if isequal(X(i, dim), 0)
           Xnegidx = Xnegidx + 1;
           Xneg{Xnegidx} = X(i,:);
       else
           Xposidx = Xposidx + 1; 
           Xpos{Xposidx} = X(i,:);
       end
    end

    Xprand = randperm(pNum);
    Xnrand = randperm(nNum);
    pXtrain = Xpos(Xprand(1:pNumTrain),:);
    nXtrain = Xneg(Xnrand(1:nNumTrain),:);
    pXtest = Xpos(Xprand(pNumTrain+1:pNum),:);
    nXtest = Xneg(Xnrand(nNumTrain+1:nNumTrain+nNumTest),:);
    
    Xtrain = [pXtrain; nXtrain];
    Xtest = [pXtest; nXtest];

    Xtrain = cell2mat(Xtrain);
    Xtest = cell2mat(Xtest);
    
    % training data: randomly sampled positive + negative 
    outfname = strcat(fname{1},'_p',num2str(pNumTrain),'_n',num2str(nNumTrain),'.',fname{2});
    csvwrite(outfname, Xtrain);
    fprintf('%s\n', outfname);

    % reference ID for training
    outfnameid = strsplit(outfname, '.');
    outfnameid = strcat(outfnameid{1}, '_id.', outfnameid{2});
    csvwrite(outfnameid, Xtrain(:,1));
    fprintf('%s\n', outfnameid);

    
    % testing data: randomly sampled positive + negative 
    if (pRatioTrain < 1) % if pRatioTrain == 1, there is no positive data for testing
        outfname = strcat(fname{1},'_p',num2str(pNumTest),'_n',num2str(nNumTest),'.', fname{2});
        csvwrite(outfname, Xtest);
        fprintf('%s\n', outfname);
        
        % reference ID for testing
        outfnameid = strsplit(outfname, '.');
        outfnameid = strcat(outfnameid{1}, '_id.', outfnameid{2});
        csvwrite(outfnameid, Xtest(:,1));
        fprintf('%s\n', outfnameid);
    end
    
end
