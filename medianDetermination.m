% Using true count samples (as made using the createTrueCount script that takes
% in user input for breath times by observing a video), determine the
% median value and IQR range for each breath for comparison with algorithm
% count to determine sensitivity/specificity values

function [pkTime,errRange,noCount,noCountErrRange] = medianDetermination(sample,segment)
% clear all;
% sample = 15;
% segment = 1;
sampleNum = sample;
segmentNum = segment;

fs = 85.9231;
totalTime = 65;
ts = 1/fs;
t = (ts*(0:(totalTime/ts)-1))';


% If 15 sets of timerVal don't exist, use 12 sets
if (exist(sprintf('timerVal%d-%d-%d.mat',sampleNum,segmentNum,15)) ~= 0)
    set = 1:15;
else
    set = 1:12;
end

for i = set
    timerVal(:,i) = load(sprintf('timerVal%d-%d-%d.mat',sampleNum,segmentNum,i));
    for j = 1:length(timerVal(i).timerVal) % Remove breaths obtained outside the 30s mark
        if timerVal(i).timerVal(j) > 31
            timerVal(i).timerVal(j:end) = [];
            break;
        end
    end
    sampleVal(i) = struct('sampleVal',ceil(timerVal(i).timerVal*85.9231));
%     trueCount(i,1:2663) = 0;
%     for j = 1:length(sampleVal(i).sampleVal)
%         trueCount(i,sampleVal(i).sampleVal(j)) = 1;
%     end
%     plot(trueCount(i,:)); hold on;
end



%% Sum all count arrays into a single array
maximum = 0; % determine count of max length (to size array)
avgCount = 0; % average number of counts in the sample
for i = set
    avgCount = avgCount + length(sampleVal(i).sampleVal);
    if length(sampleVal(i).sampleVal) > maximum
        maximum = length(sampleVal(i).sampleVal);
    end
end

avgCount = avgCount/length(set);

% Determine medians and IQR for each count
for i = 1:round(avgCount)
    idx = 1;
    j = 1;
    countPool = double.empty([0 0]);
    while j <= length(set)
        while length(timerVal(j).timerVal) < i
            if j == length(set)
                break;
            else
                j = j + 1;
            end
        end
        
        if length(timerVal(j).timerVal) < i && j >= length(set)
            break;
        end
        countPool(idx) = timerVal(j).timerVal(i);
        idx = idx + 1;
        j = j + 1;
    end
    countMedian(i) = median(countPool);
    countIQR(i) = iqr(countPool);
    countRange(i) = range(countPool);
end

% Make no count array
for i = 1:length(countMedian)
    if i == 1
        noCount(i) = countMedian(i)/2;
        noCountRange(i) = countMedian(i)/2;
    else
        noCount(i) = countMedian(i) - (countMedian(i)-countMedian(i-1))/2;
        noCountRange(i) = (countMedian(i)-countMedian(i-1))/2;
    end
end

%%% Output variables-----------
pkTime = countMedian';
errRange = countRange'/2;
noCount = noCount';
noCountErrRange = noCountRange'/2;
%%%---------------------------

countArray(:,1) = t(1:2663);
countArray(1:2663,2) = -0.5;

noCountArray(:,1) = t(1:2663);
noCountArray(1:2663,2) = -0.5;

errorArray(1:2663) = 0;
noCountErrorArray(1:2663) = 0;

% Plot medians
for i = 1:length(countMedian)
    s = round(countMedian(i)*fs);
    countArray(s,2)= 0.1;
    errorArray(s) = countRange(i)/2;
end

for i = 1:length(noCount)
    s = round(noCount(i)*fs);
    noCountArray(s,2)= 0.1;
    noCountErrorArray(s) = noCountRange(i)/2;
end

% plot(countArray(:,1),countArray(:,2));
% errorbar(countArray(:,1),countArray(:,2),errorArray,'horizontal');
% hold on; errorbar(noCountArray(:,1),noCountArray(:,2),noCountErrorArray,'horizontal'); hold off;
end

% for i = set
%     for j = 1:length(sampleVal(i).sampleVal)
%         countArray(sampleVal(i).sampleVal(j),2)= countArray(sampleVal(i).sampleVal(j),2) + 1;
%     end
% end
% 
% % figure; plot(t(1:2663),countArray(:,2)/10);
% regCount = movmean(countArray(:,2),[30 30]);
% for i = 1:5
%     regCount = movmean(regCount,[10 10]);
% end
% figure; plot(t(1:2663),regCount); hold off;
% title('Processed Sample vs True Count');

% %% Counts peaks of trueCount sample (NEEDS WORK)
% [pks,locs,w,p] = findpeaks(regCount);
% % figure; findpeaks(regCount);
% breathCount = 0;
% index = 1;
% for i = 1:length(p)
%     if p(i) >= 5e-4
%         breathCount = breathCount + 1;
%         pkTime(index) = p(i);
%         index = index + 1;
%     end
% end
% 
% disp(['True Count (findpeaks): ' num2str(breathCount)]);
% 
% end