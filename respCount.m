% Algorithm respiratory count using findpeaks local maxima detector and
% algorithm threshold; also takes values from medianDetermination and
% optimusPrime for accuracy, sensitivity/specificity values and stores them
% in the stats matrix

clear all;

% All six samples (x), segments (y), and times (z)
x = [4 5 7 9 10 15];
y = [1 3 1 3 4 1];
z = [9 33 22 11 25 3];

for n = 1:6
    
sampleNum = x(n);
segmentNum = y(n);
startTime = z(n);

% Extract data from Excel spreadsheet of nursery data
switch segmentNum
    case 1
        xlsRange = 'A2:A5586';
    case 2
        xlsRange = 'A5588:A11172';
    case 3
        xlsRange = 'A11444:A17028';
    case 4
        xlsRange = 'A17300:A22884';
    case 5
        xlsRange = 'A23156:A28740';
    otherwise
        msg = 'Error occurred. Segment number not in range.';
        error(msg);
end

load('nemoLPF.mat');

%% Setup - initialize sample, frequency, and time
originalSample(:,1) = xlsread('Nursery - Master Copy.xlsx',sampleNum,xlsRange);
originalSample = originalSample - mean(originalSample);
totalTime = 65;
fs = length(originalSample)/totalTime;
ts = 1/fs;
f = fs/length(originalSample)*(0:(length(originalSample)-1));
t = (ts*(0:(totalTime/ts)-1))';

startSeg = ceil((startTime)*fs)+1;
endSeg = ceil((startTime+30)*fs)+1;

%% Apply lowpass (fc = 1.5), highpass (fc = 0.2), and moving average filters
[b,a] = sos2tf(lowpass);
% [d,c] = sos2tf(highpass);
% [b,a] = butter(3, 1.8/fs);
[d,c] = butter(5, 0.2/fs,'high');
sample = filtfilt(b,a,originalSample);
sample = filtfilt(d,c,sample);
sample = movmean(sample,[15 15]);
maxS = max(abs(sample));
sample = sample/maxS;

% Plot Original vs Processed Sample
% figure; plot(t(1:(endSeg-startSeg+1)),originalSample(startSeg:endSeg)/max(abs(originalSample))); 
% hold on; plot(t(1:(endSeg-startSeg+1)),sample(startSeg:endSeg));
figure;findpeaks(sample(startSeg:endSeg),t(1:(endSeg-startSeg+1)));
title('Original Sample vs Processed Sample','FontSize',16);
xlabel('time (s)','FontSize',16);

%% Plot findpeaks (Determine breath count) and amplitude threshold
measCount = 0;
[pks,locs,w,p] = findpeaks(sample(startSeg:endSeg));

% figure; plot(t(1:(endSeg-startSeg+1)),sample(startSeg:endSeg)); hold on;
% title('Measured Count vs True Count','FontSize',16)
% xlabel('time (s)','FontSize',16);

idx = 1;
for i = 1:length(p)
    if p(i) >= 0
        measCount = measCount + 1;
        breathTime_algorithm(idx,1) = locs(i)/fs;
        idx = idx + 1;
    end
end

[breathTime_true, errRange, noCount, noCountErrRange] = medianDetermination(sampleNum,segmentNum);

trueCount = length(breathTime_true);
acc = 1 - abs(trueCount - measCount)/trueCount;

[sens, spec] = optimusPrime(breathTime_algorithm, breathTime_true, errRange, noCount, noCountErrRange);

% disp(['Algorithm count: ' num2str(measCount)]);
% disp(['True Count: ' num2str(trueCount) newline]);
% disp(['Accuracy: ' num2str(acc) newline]);
% disp(['Sensitivity: ' num2str(sens)]);
% disp(['1 - Specificity: ' num2str(1-spec)]);

stats(n,1:3) = [acc sens 1-spec];
clearvars -except stats n x y z
% save('optimusPrime','breathTime_algorithm','breathTime_true','errRange','noCount','noCountErrRange');

end
