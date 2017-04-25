function createTrueCount(x,y,z,startTime)

    startAtTime = startTime; % Enter time at which you start your count relative to the start of the sample
    sampleNum = x;
    segmentNum = y;
    countNum = z;
    
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
    
    load('nemoFilter.mat');
    load(sprintf('timerVal%d-%d-%d.mat',sampleNum,segmentNum,countNum));
    originalSample(:,1) = xlsread('Nursery - Master Copy.xlsx',sampleNum,xlsRange);
%     sample(:,1) = xlsread('Nursery - Master Copy.xlsx',sampleNum,xlsRange);
    totalTime = 65;
    fs = length(originalSample)/totalTime;
    ts = 1/fs;
    t = (ts*(0:(totalTime/ts)-1))';
    
    %Filters
    [b,a] = sos2tf(lowpass);
    [d,c] = butter(5, 0.2/fs,'high');
    sample = filtfilt(b,a,originalSample);
    sample = filtfilt(d,c,sample);
    sample = sample*1E-23;
    sample = movavg(sample, 25, 25);

    frameSize = 30000; % choose frame size in ms
    overlap = 29000;
    n = ts*length(sample)/((frameSize)/1000);
    if overlap == 0
        o = 1;
    elseif overlap ~= 0
        o = ts*length(sample)/((overlap)/1000);
    end


    %% Separate segments
    segNum = ceil(length(sample)/n);
    if overlap == 0
        segOverlap = 0;
    elseif overlap ~= 0
        segOverlap = ceil(length(sample)/o);
    end

    segSample = buffer(sample(:,1),segNum,segOverlap);
    segTime = buffer(t,segNum,segOverlap);

    count = 0;
    removeZeros = segOverlap;

    while removeZeros > 0
        count = count+1;
        removeZeros = segOverlap - count*(segNum-segOverlap);
    end

    segSample = segSample(:,count+1:end);
    segTime = segTime(:,count+1:end);

    %% Choose segment 
    bestSegment = startAtTime + 1;

    
    %% Create true count
    sampleVal = ceil(timerVal*85.9231);

    trueCount(1,1:size(segSample,1)) = 0;
    for i = 1:length(sampleVal)
        trueCount(1,sampleVal(i)) = 1;
    end
    %% Segment true count
    segNum = ceil(length(sample)/n);
    if overlap == 0
        segOverlap = 0;
    elseif overlap ~= 0
        segOverlap = ceil(length(sample)/o);
    end

    segTrueCount = buffer(trueCount,segNum,segOverlap);

    count = 0;
    removeZeros = segOverlap;

    while removeZeros > 0
        count = count+1;
        removeZeros = segOverlap - count*(segNum-segOverlap);
    end

    segTrueCount = segTrueCount(:,count+1:end);
    
    %% Plot sample vs true count
    plot(trueCount*10-5); hold on; plot(segSample(:,bestSegment)); hold off;
end
