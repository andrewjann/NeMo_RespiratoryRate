% Make sensitivity/specificity measurement by finding the true
% positive/negative and false positive negative rates of each sample

function [sens, spec] = optimusPrime(measCount,trueCount,errRange,noCount,noCountErrRange)

% clear all;
% load('optimusPrime.mat');
% measCount = breathTime_algorithm;
% trueCount = breathTime_true;

tP = double.empty([3 0]);
fP = double.empty([3 0]);
idx_tP = 1;
idx_tN = 1;
idx_fP = 1;
idx_fN = 1;

% True Positive and False Negative Determinations (if measCount is within 
% error range of trueCount, then index as true positive; if not, then 
% index as false negative)
for i = 1:length(trueCount)
    j = 1;
    while j <= length(measCount)
        if abs(trueCount(i) - measCount(j)) <= errRange(i)
            if find(tP == measCount(j)) ~= 0
                j = j + 1;
            else
                tP(idx_tP,1:3) = [i trueCount(i) measCount(j)];
                idx_tP = idx_tP + 1;
                break;
            end
        elseif j == length(measCount)
            fN(idx_fN,1:2) = [i trueCount(i)];
            idx_fN = idx_fN + 1;
        end
        j = j + 1;
    end
end

% False Positive Determination (if it's not within true positive array, 
% index the measCount value)
for i = 1:length(measCount)
    if isempty(find(tP == measCount(i),1)) == 1
        fP(idx_fP,1:2) = [i measCount(i)];
        idx_fP = idx_fP + 1;
    end
end

% True Negative Determination (if it's outside the error range for the
% midpoint of two true breaths, index as true negative)
for i = 1:length(noCount)
    for j = 1:length(measCount)
        if abs(noCount(i) - measCount(j)) > noCountErrRange
            tN(idx_tN,1) = i;
            idx_tN = idx_tN + 1;
            break;
        end
    end
end
    
sens = length(tP)/(length(tP)+length(fN));
spec = length(tN)/(length(tN)+length(fP));
end
