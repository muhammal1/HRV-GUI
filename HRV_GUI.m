function HRV_GUI
%% HRV_GUI - Heart Rate Variability Analysis Tool 

close all; clc;

%%  Global Variables 
global y Fs ECG peak_loc RR peak_th peak_dis studytype
global results_table ax axRR ecgSlider rrSlider sliderWindow currXLim currYLim currXLimRR currYLimRR
global sliderWindowRR
global y_history
global thrLine
y_history = {};  % initialize undo history
global ECGinfoText

%% Initialize globals
y = []; Fs = []; ECG = []; peak_loc = []; RR = [];
peak_th = 0.2; peak_dis = 240; studytype = 'Human';
results_table = []; ax = []; axRR = [];
ecgSlider = []; rrSlider = []; sliderWindow = 60; sliderWindowRR = 60;
currXLim = []; currYLim = []; currXLimRR = []; currYLimRR = [];

%%  GUI Figure 
f = figure('Position',[50 50 1200 900],...
    'Name','HRV Analysis by M. Khawar Ali','NumberTitle','off');

%% ----------------- ECG Axis (Top) -----------------
ax = axes('Parent',f,'Units','pixels','Position',[50 650 900 200]);
%  Enable mouse editing of peaks 
set(ax,'ButtonDownFcn',@editPeaks);

%% ----------------- Study Type & Buttons (Right column) -----------------
uicontrol(f,'Style','text','Position',[1020 840 120 20],'String','Study Type', 'FontWeight', 'bold','FontSize', 10);
study_menu = uicontrol(f,'Style','popupmenu',...
    'Position',[1000 810 160 30],...
    'String',{'Human','Rat'},...
    'Callback',@setStudyType);

uicontrol(f,'Style','pushbutton','String','Load ECG',...
    'Position',[1000 750 160 40],'Callback',@loadECG, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Load RR',...
    'Position',[835 330 115 30],'Callback',@loadRR, ...
    'FontWeight', 'bold','FontSize', 10);
%--------------Save/Load Session----------
uicontrol(f,'Style','pushbutton','String','Save Session',...
    'Position',[400 40 160 40],'Callback',@saveSession, 'FontWeight','bold','FontSize',10);

uicontrol(f,'Style','pushbutton','String','Load Session',...
    'Position',[600 40 160 40],'Callback',@loadSession, 'FontWeight','bold','FontSize',10);

uicontrol(f,'Style','text','Position',[990 715 120 20],'String','Peak Threshold',...
    'FontWeight', 'bold','FontSize', 10);
th_box = uicontrol(f,'Style','edit','Position',[1110 715 50 30],...
    'String','0.2','Callback',@setThreshold);

uicontrol(f,'Style','text','Position',[990 650 120 20],'String','Peak Distance',...
    'FontWeight', 'bold','FontSize', 10);
dis_box = uicontrol(f,'Style','edit','Position',[1110 650 50 30],...
    'String','240','Callback',@setDistance);

uicontrol(f,'Style','pushbutton','String','Delete Segment',...
    'Position',[600 580 115 30],'Callback',@deleteSegment,'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Select Segment',...
    'Position',[1000 560 160 40],'Callback',@selectSegment,'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Detect R Peaks',...
    'Position',[725 580 115 30],'Callback',@detectPeaks, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Generate RR',...
    'Position',[1000 510 160 40],'Callback',@generateRR, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Compute HRV',...
    'Position',[1000 460 160 40],'Callback',@computeMetrics, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Export Results',...
    'Position',[1000 410 160 40],'Callback',@exportResults, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Export RR',...
    'Position',[1000 360 160 40],'Callback',@exportRR, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Show Plots',...
    'Position',[1000 310 160 40],'Callback',@showPlots, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Undo',...
    'Position',[800 40 160 40],'Callback',@undoAction, 'FontWeight', 'bold','FontSize', 10);

uicontrol(f,'Style','pushbutton','String','Exit','Position',[1000 40 160 40],...
    'Callback',@exitGUI, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','togglebutton','String','Edit Peaks',...
    'Position',[850 580 110 30],...
    'Callback',@togglePeakEditing, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','togglebutton',...
    'Position',[480 580 110 30],...
    'String','Invert ECG','FontWeight','bold','FontSize',10,...
    'Callback',@invertECG);
%  Threshold Slider 
uicontrol(f,'Style','slider',...
    'Position',[1000 690 160 20],...
    'Min',0,'Max',1,'Value',peak_th,...
    'Callback',@thresholdSlider);
%  Peak Distance Slider 
dis_slider = uicontrol(f,'Style','slider',...
    'Position',[1000 625 160 20],...        % below the edit box
    'Min',50,'Max',500,'Value',peak_dis,... 
    'SliderStep',[1/450 10/450],...         % small/large steps
    'Callback',@distanceSlider);            
% ----------------- Display Loaded File Name -----------------
fileNameText = uicontrol(f,'Style','text',...
    'Position',[1000 790 160 20],...
    'String','No file loaded','FontSize',9,'HorizontalAlignment','left');

%% ----------------- Zoom Buttons for ECG -----------------
uicontrol(f,'Style','pushbutton','String','Zoom In X','Position',[50 580 90 30],...
    'Callback',@zoomInX, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','pushbutton','String','Zoom Out X','Position',[150 580 90 30],...
    'Callback',@zoomOutX, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','pushbutton','String','Zoom In Y','Position',[250 580 90 30],...
    'Callback',@zoomInY, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','pushbutton','String','Zoom Out Y','Position',[350 580 90 30],...
    'Callback',@zoomOutY, 'FontWeight', 'bold','FontSize', 10);

%% ----------------- Slider for scrolling ECG -----------------
ecgSlider = uicontrol(f,'Style','slider','Min',1,'Max',100,'Value',1,...
    'Position',[50 550 900 20],'Callback',@scrollECG);

%% ----------------- RR Interval Axis (Below ECG) -----------------
axRR = axes('Parent',f,'Units','pixels','Position',[50 390 900 120]);
title(axRR,'RR Intervals'); xlabel(axRR,'RRn'); ylabel(axRR,'ms');

%% ----------------- Zoom Controls for RR -----------------
uicontrol(f,'Style','pushbutton','String','Zoom In X','Position',[50 330 90 30],...
    'Callback',@zoomInXRR, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','pushbutton','String','Zoom Out X','Position',[140 330 90 30],...
    'Callback',@zoomOutXRR, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','pushbutton','String','Zoom In Y','Position',[230 330 90 30],...
    'Callback',@zoomInYRR, 'FontWeight', 'bold','FontSize', 10);
uicontrol(f,'Style','pushbutton','String','Zoom Out Y','Position',[320 330 90 30],...
    'Callback',@zoomOutYRR, 'FontWeight', 'bold','FontSize', 10);

%% ----------------- Slider for RR -----------------
rrSlider = uicontrol(f,'Style','slider','Min',1,'Max',100,'Value',1,...
    'Position',[50 300 900 20],'Callback',@scrollRR);

%% ----------------- Results Table (Below RR slider, two rows) -----------------
results_table = uitable(f,'Position',[50 90 1110 150],...
    'ColumnName',{'Heart_Rate','SI','RMSSD','HF','LF','LF/HF','RSA','SD1','SD2','SD2/SD1',...
    'SDNN','SDSD','SDANN','SDNN_Index','pNN50','LFn','HFn','LFn/HFn'},...
    'RowName',[]);

%%  Nested Functions 

function setStudyType(src,~)
    val = src.Value;
    if val==1
        studytype='Human'; peak_th=0.2; peak_dis=240;
        set(th_box,'String','0.2'); set(dis_box,'String','240');
    else
        studytype='Rat'; peak_th=0.06; peak_dis=130;
        set(th_box,'String','0.06'); set(dis_box,'String','130');
    end
end

    function loadECG(~,~)

    [file,path]=uigetfile('*.wav'); 
    if file==0, return; end

    [y,Fs]=audioread(fullfile(path,file));
set(fileNameText,'String',file);  % display the loaded file name
    % --- Downsample if RAT study ---
    if strcmp(studytype,'Rat')

        targetFs = 1000; % recommended for rat ECG

        if Fs > targetFs
            factor = round(Fs/targetFs);
            y = downsample(y,factor);
            Fs = Fs/factor;
        end

    end

    % reset undo history
    y_history = {};

    t=(0:length(y)-1)/Fs;

    plot(ax,t,y,'b');
    xlabel(ax,'Time (s)');
    ylabel(ax,'Amplitude');
    title(ax,'Raw ECG')

    currXLim = ax.XLim;
    currYLim = ax.YLim;

end

function setThreshold(src,~)
    peak_th=str2double(src.String);
end

function setDistance(src,~)
    peak_dis=str2double(src.String);
end

function deleteSegment(~,~)
    if isempty(y), return; end
    % Save current state to history
    y_history{end+1} = y;  
    
    title(ax,'Select start and end'); 
    [x,~] = ginput(2);
    s = round(x(1)*Fs); e = round(x(2)*Fs);
    y(s:e) = []; 
    t = (0:length(y)-1)/Fs;
    plot(ax,t,y,'b'); xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude'); title(ax,'ECG Signal');
    if ~isempty(currXLim), ax.XLim = currXLim; end
    if ~isempty(currYLim), ax.YLim = currYLim; end
end

function detectPeaks(~,~)
    if isempty(y), return; end
    N=length(y); t=(0:N-1)/Fs;
    [p,~,mu]=polyfit((1:numel(y))',y,6);
    fy=polyval(p,(1:numel(y))',[],mu);
    ECG=lowpass(y-fy,40,Fs);
    [peak_val,peak_loc]=findpeaks(ECG,'MinPeakHeight',peak_th,'MinPeakDistance',peak_dis);
    hECG = plot(ax,t,ECG,'b');
set(hECG,'HitTest','off')   % allow axis to receive mouse clicks 
    hold(ax,'on'); 

plot(ax,peak_loc/Fs,peak_val,'ro');

%  R-peak detection Threshold Line 
thrLine = yline(ax,peak_th,'r--','LineWidth',1.5);

hold(ax,'off');
    title(ax,'Detected R Peaks'); xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude');
end

function generateRR(~,~)
    if isempty(peak_loc), return; end
    RR=diff(peak_loc/Fs)*1000;
    axes(axRR); cla(axRR); plot(axRR,RR,'b');
    xlabel(axRR,'RRn'); ylabel(axRR,'ms'); title(axRR,'RR Intervals');
    if ~isempty(currXLimRR), axRR.XLim = currXLimRR; end
    if ~isempty(currYLimRR), axRR.YLim = currYLimRR; end
end

function computeMetrics(~,~)
     if isempty(RR)
        % If no RR available, try to calculate from peaks
        if isempty(peak_loc)
            errordlg('No RR intervals or detected peaks available.'); return;
        end
        RR = diff(peak_loc/Fs)*1000; 
    end

    RR = RR(:); % ensure column vector
    mrr=mean(RR); heart_rate=60*1000/mrr;
    SD=diff(RR); RMSSD=rms(SD); SDNN=std(RR); SDSD=std(SD);
    nn=abs(SD); nn50=nn(nn>50); pNN50=(length(nn50)/length(SD))*100;

    % Poincare
    x1=(RR(1:end-1)-RR(2:end))/sqrt(2); x2=(RR(1:end-1)+RR(2:end)-2*mean(RR))/sqrt(2);
    SD1=std(x1); SD2=std(x2); SD2SD1_Ratio=SD2/SD1;

    % Stress Index
    RR_sec=RR/1000; Mo=mode(RR_sec);
    if strcmp(studytype,'Human'), edges=0.5:0.05:1.8; else, edges=0:0.015:0.5; end
    counts=histcounts(RR_sec,edges); n1=max(counts); N1=length(RR_sec); AMo=n1/N1; MxDMn=max(RR_sec)-min(RR_sec); SI=(AMo*100)/(2*Mo*MxDMn);

       
% SDANN & SDNN Index (5-minute segments)
segmentDuration = 5*60*1000; % milliseconds
tRR = [0; cumsum(RR(1:end-1))];
nSeg = floor(sum(RR)/segmentDuration);

segMean = [];
segSD = [];

for j = 1:nSeg
    idx = tRR >= (j-1)*segmentDuration & ...
          tRR < j*segmentDuration;
    segment = RR(idx);

    if numel(segment) > 1
        segMean(end+1) = mean(segment);
        segSD(end+1) = std(segment);
    end
end

if numel(segMean) >= 2
    SDANN = std(segMean);
    SDNN_Index = mean(segSD);
else
    SDANN = NaN;
    SDNN_Index = NaN;
end


    % Frequency Analysis
    n=length(RR); x=zeros(1,n); x(1)=RR(1);
    for i=1:n-1, x(i+1)=x(i)+RR(i+1); end
    if strcmp(studytype,'Human')
    Fs_interp = 10;
    LF_band = [0.04 0.15];
    HF_band = [0.15 0.5];
else
    Fs_interp = 20;
    LF_band = [0.2 0.8];
    HF_band = [0.8 3];
end

xq = x(1):1000/Fs_interp:x(end);
RR1 = interp1(x,RR,xq,'pchip');
    
    [Pxx,F]=periodogram(RR1,hamming(length(RR1)),length(RR1),Fs_interp);
    HF=bandpower(Pxx,F,HF_band,'psd'); LF=bandpower(Pxx,F,LF_band,'psd');
    LFHFratio=LF/HF; LFn=LF/(LF+HF); HFn=HF/(LF+HF); nRatio=LFn/HFn; RSA=log(HF);

    results_table.Data=[heart_rate SI RMSSD HF LF LFHFratio RSA SD1 SD2 SD2SD1_Ratio ...
        SDNN SDSD SDANN SDNN_Index pNN50 LFn HFn nRatio];
end

    function exportResults(~,~)
    if isempty(results_table.Data)
        errordlg('No results to export');
        return;
    end

    % Ask user for filename
    prompt = {'Enter filename for HRV results (without extension):'};
    dlgtitle = 'Save HRV Results';
    dims = [1 50];
    definput = {'HRV_results'};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    if isempty(answer), return; end
    defaultFile = [answer{1}, '.xlsx'];

    % Let user choose folder and filename
    [file, path] = uiputfile('*.xlsx', 'Save HRV Results As', defaultFile);
    if isequal(file,0) || isequal(path,0)
        return;  % user canceled
    end

    % Save table
    headers = {'heart_rate','SI','RMSSD','HF','LF','LFHFratio','RSA','SD1','SD2','SD2SD1_Ratio', ...
               'SDNN','SDSD','SDANN','SDNN_Index','pNN50','LFn','HFn','nRatio'};
    T = array2table(results_table.Data,'VariableNames',headers);
    writetable(T, fullfile(path, file));
    msgbox(['HRV results saved successfully as ' file]);
end

function exportRR(~,~)
    if isempty(RR)
        errordlg('Generate or load RR intervals first');
        return;
    end

    % Ask user for filename
    prompt = {'Enter filename for RR intervals (without extension):'};
    dlgtitle = 'Save RR Intervals';
    dims = [1 50];
    definput = {'RR_intervals'};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    if isempty(answer), return; end
    defaultFile = [answer{1}, '.xlsx'];

    % Let user choose folder and filename
    [file, path] = uiputfile('*.xlsx', 'Save RR Intervals As', defaultFile);
    if isequal(file,0) || isequal(path,0)
        return;  % user canceled
    end

    % Save RR table
    T = table(RR, 'VariableNames', {'RR_ms'});
    writetable(T, fullfile(path, file));
    msgbox(['RR intervals saved successfully as ' file]);
end

function showPlots(~,~)
    if isempty(RR), errordlg('Generate RR intervals first'); return; end
    figure('Name','Poincare & SI Histogram','Position',[200 200 900 400]);

    % Poincaré Plot
    subplot(1,2,1)
    rr1 = RR(1:end-1); rr2 = RR(2:end);
    scatter(rr1,rr2,25,'filled'); xlabel('RR(n) [ms]'); ylabel('RR(n+1) [ms]');
    title('Poincaré Plot'); grid on; axis square;
    x1 = (rr1 - rr2)/sqrt(2); x2 = (rr1 + rr2 - 2*mean(RR))/sqrt(2);
    SD1=std(x1); SD2=std(x2);
    hold on; scatter(mean(RR),mean(RR),'r','filled');
    legend(['SD1=' num2str(SD1,'%.2f') ', SD2=' num2str(SD2,'%.2f')],'Location','best');

    % SI Histogram
    subplot(1,2,2)
    RR_sec = RR/1000;  
    if strcmp(studytype,'Human')
        edges = 0.5:0.05:1.8;
    else
        edges = 0:0.015:0.5;
    end
    counts = histcounts(RR_sec,edges);
    [~,idx] = max(counts);
    Mo = (edges(idx)+edges(idx+1))/2;  
    MxDMn = max(RR_sec)-min(RR_sec);
    AMo = max(counts)/length(RR_sec);
    SI = (AMo*100)/(2*Mo*MxDMn);
    histogram(RR_sec,edges,'FaceColor',[0.2 0.6 0.2]);
    xlabel('RR Interval [s]'); ylabel('Count'); 
    title(['Sympathetic Index (SI) = ' num2str(SI,'%.2f')]);
    grid on;
end

%%  Undo Function
function undoAction(~,~)
    if isempty(y_history)
        msgbox('Nothing to undo','Undo','warn'); return;
    end
    y = y_history{end};  % restore last state
    y_history(end) = [];  % remove from history
    
    % Update plot
    t = (0:length(y)-1)/Fs;
    plot(ax,t,y,'b'); xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude'); title(ax,'ECG Signal');
    if ~isempty(currXLim), ax.XLim = currXLim; end
    if ~isempty(currYLim), ax.YLim = currYLim; end
end

%%  Zoom & Slider Callbacks 
function zoomInX(~,~), xl=ax.XLim; mid=mean(xl); range=diff(xl)/1.5; ax.XLim=mid+[-range/2 range/2]; currXLim=ax.XLim; end
function zoomOutX(~,~), xl=ax.XLim; mid=mean(xl); range=diff(xl)*1.5; xl_new=mid+[-range/2 range/2]; xl_new(1)=max(xl_new(1),0); xl_new(2)=min(xl_new(2),length(y)/Fs); ax.XLim=xl_new; currXLim=ax.XLim; end
function zoomInY(~,~), yl=ax.YLim; mid=mean(yl); range=diff(yl)/1.5; ax.YLim=mid+[-range/2 range/2]; currYLim=ax.YLim; end
function zoomOutY(~,~), yl=ax.YLim; mid=mean(yl); range=diff(yl)*1.5; ax.YLim=mid+[-range/2 range/2]; currYLim=ax.YLim; end

function zoomInXRR(~,~), xl=axRR.XLim; mid=mean(xl); range=diff(xl)/1.5; axRR.XLim=mid+[-range/2 range/2]; currXLimRR=axRR.XLim; end
function zoomOutXRR(~,~), xl=axRR.XLim; mid=mean(xl); range=diff(xl)*1.5; axRR.XLim=mid+[-range/2 range/2]; currXLimRR=axRR.XLim; end
function zoomInYRR(~,~), yl=axRR.YLim; mid=mean(yl); range=diff(yl)/1.5; axRR.YLim=mid+[-range/2 range/2]; currYLimRR=axRR.YLim; end
function zoomOutYRR(~,~), yl=axRR.YLim; mid=mean(yl); range=diff(yl)*1.5; axRR.YLim=mid+[-range/2 range/2]; currYLimRR=axRR.YLim; end

function scrollECG(src,~)
    val = src.Value; N = length(y); totalTime = N/Fs;
    if isempty(currXLim), windowWidth = min(sliderWindow,totalTime); else, windowWidth=diff(currXLim); end
    startTime=(totalTime-windowWidth)*(val/100); endTime=startTime+windowWidth;
    if endTime>totalTime, endTime=totalTime; startTime=endTime-windowWidth; end
    ax.XLim=[startTime endTime];
end

function scrollRR(src,~)
    val = src.Value; 
    N = length(RR);
    windowWidth = min(sliderWindowRR,N);  % visible RR intervals
    startIdx = round((N-windowWidth)*(val/100)) + 1;
    endIdx = startIdx + windowWidth - 1;
    if endIdx > N, endIdx = N - windowWidth + 1; end
    axes(axRR);
    cla(axRR);
    plot(axRR, startIdx:endIdx, RR(startIdx:endIdx), 'b', 'LineWidth', 1.2);
    xlabel(axRR,'RRn'); ylabel(axRR,'ms'); title(axRR,'RR Intervals');
    if ~isempty(currXLimRR), axRR.XLim = [startIdx endIdx]; end
    if ~isempty(currYLimRR), axRR.YLim = currYLimRR; end
end

function exitGUI(~,~)
    choice = questdlg('Do you want to save results and RR intervals before exiting?', ...
        'Exit HRV GUI', ...
        'Yes','No','Cancel','Yes');
    
    switch choice
        case 'Yes'
            try, exportResults(); end
            try, exportRR(); end
            close(f);
        case 'No'
            close(f);
        case 'Cancel'
            return;
    end
end

function thresholdSlider(src,~)
    peak_th = src.Value;
    set(th_box,'String',num2str(peak_th));

    % update threshold line if it exists
    if ~isempty(thrLine) && isvalid(thrLine)
        thrLine.Value = peak_th;
    end
end
% Manual R-peak editing
    function editPeaks(~,~)
    if isempty(ECG)
        return
    end

    cp = get(ax,'CurrentPoint');
    xClick = cp(1,1);
    idx = round(xClick*Fs);

    % Ensure idx is a valid scalar within bounds
    if isempty(idx) || ~isnumeric(idx) || idx < 1 || idx > length(ECG)
        return;
    end

    clickType = get(f,'SelectionType');

    % Save current zoom limits
    xlim_current = ax.XLim;
    ylim_current = ax.YLim;

    % Force peak_loc to be a column vector
    peak_loc = peak_loc(:);
    idx = idx(:);

    if strcmp(clickType,'normal')
    % LEFT CLICK → ADD PEAK
    % Find the nearest local maximum in a small window around idx
    win = round(0.05*Fs);  % 50 ms window
    startIdx = max(1, idx-win);
    endIdx   = min(length(ECG), idx+win);
    [~, localMaxIdx] = max(ECG(startIdx:endIdx));
    idx = startIdx + localMaxIdx - 1;  % update idx to true peak
    peak_loc = sort([peak_loc; idx]);  % add new peak

    elseif strcmp(clickType,'alt')
        % RIGHT CLICK → DELETE NEAREST PEAK
        if isempty(peak_loc), return; end
        [~,i] = min(abs(peak_loc - idx));
        peak_loc(i) = [];
    end

    % redraw ECG and peaks
    t = (0:length(ECG)-1)/Fs;
    axes(ax); cla(ax);
    plot(ax,t,ECG,'b'); hold(ax,'on')
    if ~isempty(peak_loc)
        plot(ax,peak_loc/Fs,ECG(peak_loc),'ro')
    end

    % redraw threshold line
    if exist('thrLine','var') && isvalid(thrLine)
        delete(thrLine); % remove old line
    end
    thrLine = yline(ax,peak_th,'r--','LineWidth',1.5);

    hold(ax,'off')

    % Restore zoom
    ax.XLim = xlim_current;
    ax.YLim = ylim_current;
end
function togglePeakEditing(src,~)
    if src.Value == 1
        % Turn on editing mode
        set(ax,'ButtonDownFcn',@editPeaks);
        % Make ECG line ignore clicks
        hLines = findobj(ax,'Type','line');
        for k = 1:length(hLines)
            set(hLines(k),'HitTest','off');
        end
        msgbox('Click LEFT to add peaks, RIGHT to remove peaks','Peak Editing','modal');
    else
        % Turn off editing
        set(ax,'ButtonDownFcn','');
    end
end
function togglePeakEdit(src,~)
    if src.Value == 1
        % Turn ON peak editing
        set(src,'String','Peak Edit Mode ON');
        % Enable axes clicks
        set(ax,'ButtonDownFcn',@editPeaks);
    else
        % Turn OFF peak editing
        set(src,'String','Peak Edit Mode OFF');
        % Disable axes clicks
        set(ax,'ButtonDownFcn','');
    end
end
%  Slider Callback 
function distanceSlider(src,~)
    peak_dis = round(src.Value);              % update global value
    set(dis_box,'String',num2str(peak_dis)); % sync edit box
end


function setDistance1(src,~)
    peak_dis = str2double(src.String);       % update global
    set(dis_slider,'Value',peak_dis);        % sync slider
end
% Callback function
    function loadRR(~,~)
    [file,path] = uigetfile('*.xlsx'); 
    if file==0, return; end

    T = readtable(fullfile(path,file));
    if ~any(strcmp(T.Properties.VariableNames,'RR_ms'))
        errordlg('RR intervals file must have column "RR_ms"'); 
        return; 
    end
    RR = T.RR_ms;

    % Ask user for study type
    choice = questdlg('Select study type for loaded RR intervals:', ...
                      'Study Type', 'Human', 'Rat', 'Human');
    switch choice
        case 'Human'
            studytype = 'Human';
        case 'Rat'
            studytype = 'Rat';
        otherwise
            studytype = 'Human';
    end

    % Plot RR intervals
    axes(axRR); cla(axRR);
    plot(axRR,RR,'b','LineWidth',1.2);
    xlabel(axRR,'RRn'); ylabel(axRR,'ms'); title(axRR,'RR Intervals');

    % Reset zoom limits
    currXLimRR = []; currYLimRR = [];
end

    function saveSession(~,~)
    prompt = {'Enter filename for session (without extension):'};
    dlgtitle = 'Save Session';
    dims = [1 50];
    definput = {'HRV_session'};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    if isempty(answer), return; end
    file = [answer{1}, '.mat'];

    path = uigetdir;
    if path == 0, return; end

    % Save all important variables including Fs
    ECG_signal = ECG;       %#ok<NASGU>
    peaks = peak_loc;       %#ok<NASGU>
    RR_intervals = RR;      %#ok<NASGU>
    HRV_results = results_table.Data; %#ok<NASGU>
    StudyType = studytype;  %#ok<NASGU>
    PeakThreshold = peak_th; %#ok<NASGU>
    PeakDistance = peak_dis; %#ok<NASGU>
    SamplingFreq = Fs;      %#ok<NASGU>

    save(fullfile(path,file), 'ECG_signal','peaks','RR_intervals','HRV_results','StudyType',...
        'PeakThreshold','PeakDistance','SamplingFreq');
    msgbox(['Session saved successfully as ' file]);
end

function loadSession(~,~)
    [file, path] = uigetfile('*.mat', 'Select Session File');
    if file == 0, return; end
    data = load(fullfile(path, file));
% Restore sampling frequency
if isfield(data,'SamplingFreq')
    Fs = data.SamplingFreq;
end
    % Load variables into GUI
    if isfield(data, 'ECG_signal')
        ECG = data.ECG_signal;
        t = (0:length(ECG)-1)/Fs;
        axes(ax); cla(ax);
        plot(ax, t, ECG, 'b'); xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude'); title(ax,'Loaded ECG Signal');
        currXLim = ax.XLim; currYLim = ax.YLim;
    end

    if isfield(data, 'peaks')
        peak_loc = data.peaks;
        hold(ax,'on'); plot(ax, peak_loc/Fs, ECG(peak_loc), 'ro'); hold(ax,'off');
        % redraw threshold line
        if exist('thrLine','var') && isvalid(thrLine)
            delete(thrLine);
        end
        thrLine = yline(ax, peak_th, 'r--','LineWidth',1.5);
    end

    if isfield(data, 'RR_intervals')
        RR = data.RR_intervals;
        axes(axRR); cla(axRR);
        plot(axRR, RR, 'b'); xlabel(axRR,'RRn'); ylabel(axRR,'ms'); title(axRR,'Loaded RR Intervals');
        currXLimRR = axRR.XLim; currYLimRR = axRR.YLim;
    end

    if isfield(data, 'HRV_results')
        results_table.Data = data.HRV_results;
    end

    if isfield(data, 'StudyType')
        studytype = data.StudyType;
        if strcmp(studytype,'Human')
            study_menu.Value = 1;
        else
            study_menu.Value = 2;
        end
    end

    if isfield(data, 'PeakThreshold')
        peak_th = data.PeakThreshold;
        set(th_box,'String',num2str(peak_th));
    end

    if isfield(data, 'PeakDistance')
        peak_dis = data.PeakDistance;
        set(dis_box,'String',num2str(peak_dis));
    end

    msgbox(['Session loaded successfully: ' file]);
end
function selectSegment(~,~)

    if isempty(y), return; end

    choice = questdlg('How do you want to select the segment?', ...
        'Segment Selection', ...
        'Mouse Selection','Time Input','Cancel','Mouse Selection');

    if strcmp(choice,'Cancel')
        return
    end

    % Save state for UNDO
    y_history{end+1} = y;

    %  MOUSE SELECTION 
    if strcmp(choice,'Mouse Selection')

        title(ax,'Select start and end'); 
        [x,~] = ginput(2);

        s = round(x(1)*Fs);
        e = round(x(2)*Fs);

    % TIME INPUT 
    elseif strcmp(choice,'Time Input')

        prompt = {'Start Time (minutes):','End Time (minutes):'};
        dlgtitle = 'Select ECG Segment';
        dims = [1 35];
        definput = {'0','5'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);

        if isempty(answer)
            return
        end

        t1 = str2double(answer{1});
        t2 = str2double(answer{2});

        if isnan(t1) || isnan(t2) || t2 <= t1
            errordlg('Invalid time range');
            return
        end

        s = round(t1*60*Fs);
        e = round(t2*60*Fs);

    end

    % safety bounds
    s = max(1,s);
    e = min(length(y),e);

    %  KEEP ONLY SELECTED SEGMENT 
    y = y(s:e);

    % update plot
    t = (0:length(y)-1)/Fs;

    plot(ax,t,y,'b')
    xlabel(ax,'Time (s)')
    ylabel(ax,'Amplitude')
    title(ax,'ECG Signal (Selected Segment)')

    % reset zoom tracking
    currXLim = ax.XLim;
    currYLim = ax.YLim;

end
function invertECG(src,~)
    if isempty(y), return; end  % nothing loaded

    % Save current state for undo
    y_history{end+1} = y;

    % Flip the signal
    y = -y;

    % Flip detected ECG too if it exists
    if ~isempty(ECG)
        ECG = -ECG;
    end

    % Redraw ECG
    t = (0:length(y)-1)/Fs;
    axes(ax); cla(ax);
    plot(ax,t,y,'b'); xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude'); 
    title(ax,'ECG Signal');

    % Redraw peaks if they exist
    if ~isempty(peak_loc)
        hold(ax,'on');
        plot(ax,peak_loc/Fs,ECG(peak_loc),'ro');
        hold(ax,'off');
    end

    % Redraw threshold line
    if exist('thrLine','var') && isvalid(thrLine)
        delete(thrLine);
    end
    thrLine = yline(ax,peak_th,'r--','LineWidth',1.5);

    % Update ECG info
    duration_min = length(y)/Fs/60;
    set(ECGinfoText,'String',sprintf('ECG length: %.1f minutes | Fs: %d Hz', duration_min, Fs));

    % Update button text
    if src.Value == 1
        src.String = 'ECG Inverted';
    else
        src.String = 'Invert ECG';
    end
end
end
