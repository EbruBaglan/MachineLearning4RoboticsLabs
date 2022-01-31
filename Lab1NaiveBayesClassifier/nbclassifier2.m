function freq_for_test_mat = nbclassifier2(train,test,n,d,nLevelsGiven,a)

% Number of levels are obtained for each class including target.
nLevels = zeros(d+1,1);
for i = 1 : d+1
    nLevels(i,1) = max(train(:,i));
end

% Number of levels are obtained for each class including target.
nLevelsGiven = [nLevelsGiven'; 2];

% Freq. table (cell) is initialized with its level number size.
% deal function is used to assign zero matrices inside cells.
nTarget = nLevelsGiven(d+1,1);
freqtable = cell(nTarget,d);
for i = 1:d
    [freqtable{1:nTarget,i}] = deal(zeros(nLevelsGiven(i,1),1));
end
% Necessary matrices for intermediate steps are initialized.

% Matrices are divided depending on the target level in matrixstore
% (Yes rows, and No Rows). Later this matrices' classes, levels,
% occurences and their likelihood are taken into intermatrices
% using tabulate function. Note: tabulate function writes
% frequency of even non-existence values. For instance if
% there is only level '3' exists in a class, it still tabulates
% '1' and '2' levels, noting 0 frequency for them.
matrixstore = cell(nTarget,1);
intermatrices = cell(nTarget,d);
for i = 1: nTarget
    matrixstore{i,1} = train((find(train(:,d+1)==i)).',:);
    for j = 1:d
        intermatrices{i,j} = tabulate(matrixstore{i,1}(:,j));
    end
end

% Correction to intermatrices, as max level rows are not available,
% in case training data does not include them
for i = 1: nTarget
    for j = 1:d
        lastLevel = size(intermatrices{i,j}(:,:),1);
        nLevelDiff = nLevelsGiven(j,1) - lastLevel;
        if  nLevelDiff > 0
            addition = zeros(nLevelDiff,3);
            for k = 1:nLevelDiff
                addition(k,1) = lastLevel + k;
            end
            intermatrices{i,j} = [intermatrices{i,j}; addition];
        end
    end
end


% Time for Laplace smoothing.
smoothintermatrices = cell(nTarget,d);
for i = 1:d
    [smoothintermatrices{1:nTarget,i}] = deal(zeros(nLevelsGiven(i,1),1));
end

for i = 1: nTarget
    for j = 1:d
        for k = 1:nLevelsGiven(j,1)
            smoothintermatrices{i,j}(k,1) = (intermatrices{i,j}(k,2) + a)/...
                (sum(intermatrices{i,j}(:,2)) + a * nLevelsGiven(j,1) );
        end
    end
end

% Initialization of matrices to calculate probability of test data.
nTest = size(test,1);
freq_for_test = cell(nTest,1);
for i = 1:nTest
    freq_for_test{i,1} = zeros(nTarget,d+1);
end
freq_for_test_mat = zeros(nTest,1);

for i = 1:nTest
    for j = 1:d
        for k =1:nTarget
            freq_for_test{i,1}(k,j) = ...
                smoothintermatrices{k,j}(test(i,j),1);
        end
    end
end

% Multiplication is taken here for Yes and No results.
for i = 1:nTest
    for j  =1:nTarget
        freq_for_test{i,1}(:,end) = prod(freq_for_test{i,1}(:,1:d),2);
    end
end

% Maximum probability value taken here and result is returned.
for i = 1:nTest
    [~,freq_for_test_mat(i,1)] = max(freq_for_test{i,1}(:,end));
end

end