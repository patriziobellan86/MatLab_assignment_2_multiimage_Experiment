KbName('UnifyKeyNames');

% clear the workspace
clear;
% suppress all warning
Screen('Preference', 'SuppressAllWarnings', 1);
warning('off','all');

% get screen dimensions
% [startx starty screen_h screen_v] = get( groot, 'Screensize' )
screenSize = get( groot, 'Screensize' );

% constants
fixationTime = 0.5;

% beep
freqNo = 250;
freqYes = 650;
duration = 0.15;
beepYes = MakeBeep(freqYes,duration);
beepNo = MakeBeep(freqNo, duration);

% Screen size
% NOT IN A FULL SCREEN!!!
screen_h = floor(screenSize(3)*0.75);
screen_v = floor(screenSize(4)*0.75);

% numTrials=2;   
numImagesDisplayed=9;
numImagesExperiment=4;
presentationTime=0.2;

% fixation point
dim = 25;   
spess=5;

% imgSize
dimImg  = floor(screen_v/4);
% boreder size
border = floor(dimImg/4);
dimImg = [dimImg dimImg];

% grid images coords
myCounter=0;
for x=border:dimImg(1)+border:screen_v
% for x=border+(screen_h-screen_v)/2:dimImg(1)+border:screen_v    
    for y=border:dimImg(1)+border:screen_v
        if x+dimImg(1) < screen_v & y+dimImg(1) < screen_v
            myCounter=myCounter+1;
            myRectsGrid(myCounter,:)=[x y x+dimImg(1) y+dimImg(1)];
        end
    end
end

% load all the images in the folder
% get current folder 
[current_folder name ext] = fileparts(mfilename('fullpath'));
current_folder = [current_folder '/src/'];

% list of imeage files
fileslist = dir (current_folder);
fileslist = {fileslist.name};  % transformation of array files into array list

% delection of . and ..
% method 1  - naive method!
%fileslist = fileslist(3:end)  
% method 2
fileslist = setdiff(fileslist,'.');
fileslist = setdiff(fileslist,'..');

% adding current_folder to fileslist and load image
for i=1:length(fileslist)
    img = strcat(current_folder,fileslist{i});

%   load and reshape all the images into the propper dimension
    trialsImages(i).img = imresize(imread(img), dimImg);
    trialsImages(i).showed = 0;
    trialsImages(i).selected = 0;   
end

% creation of the screen pointer and object
% win=Screen('OpenWindow',0,[255 255 255],[0 0 screen_h screen_v]);
screenW_x = floor((screenSize(3) - floor(screenSize(3)*0.75))/2);
screenW_y = floor((screenSize(4) - floor(screenSize(4)*0.75))/2);

screenW_h = screen_h + floor((screenSize(3) - floor(screenSize(3)*0.75))/2);
screenW_v = screen_v + floor((screenSize(4) - floor(screenSize(4)*0.75))/2);

win=Screen('OpenWindow',0,[255 255 255],[screenW_x screenW_y screenW_h screenW_v]);

Screen(win,'flip');

% Show experiment instruction
DrawFormattedText(win, 'Assignment 2 Patrizio Bellan', 'center','center');
Screen(win,'flip');
pause(2);
DrawFormattedText(win, 'Click on the image that you see as fast as possible', 'center','center');
Screen(win,'flip');
pause(2);

% parameters setting
% asking for the numer of trials
while true
%     [string,terminatorChar] = GetEchoString(win, 'How many trials?', 50, 50, [100 100 100], [250 250 250],'Return'); %  useKbCheck, varargin)
    [string] = GetEchoString(win, 'How many trials?', 50, 50, [100 100 100], [250 250 250]); %,'Return'); %  useKbCheck, varargin)
    if isstrprop(string, 'digit') 
        numTrials = str2num(string);
        break;
    end
    Screen(win,'flip');
end

% asking for the partecipant's name
% [string,terminatorChar] = GetEchoString(win, 'Partecipant name?', 50, 50, [100 100 100], [250 250 250],'Return'); %  useKbCheck, varargin)
[string] = GetEchoString(win, 'Partecipant name?', 50, 50, [100 100 100], [250 250 250]); %,'Return'); %  useKbCheck, varargin)
partecipant_name = string;
Screen(win,'flip');

DrawFormattedText(win, 'start', 'center','center');
Screen(win,'flip');
pause(2);

% beginning of the loop for the experiment
for counterTrial=1:numTrials
    str = ['trial number ' num2str(counterTrial) ' of ' num2str(numTrials)]; %strcat('trial number ',string(counterTrial),' on ',string(numTrials));
    DrawFormattedText(win, str, 'center','center');
    Screen(win,'flip');
    pause(2);
    
    % shuffling items
    Shuffle(trialsImages);
    
    % selecting items for the current trial
    i=0;
    index_trial = [];
    while i < numImagesDisplayed 
        % selectign the numer of item to show
        index = randi ([1 length(trialsImages)]);
        if ~ismember(index, index_trial)
            index_trial(end +1) = index;
            i = i + 1;
        end 
    end
    
    % selecting items to show in the current trial
    i=0;
    index_trial_show = [];
    while i <= numImagesExperiment 
        % selectign the numer of item to show
        index = randi ([1 length(trialsImages)]);
        if ismember(index, index_trial) && ~ismember(index, index_trial_show)
            index_trial_show(end +1) = index;
            i = i + 1;
        end 
    end   
    
    % fixation frame
    DrawFormattedText(win, 'look at the fixation point','center', 'center');
    Screen(win,'flip');
    WaitSecs(1);
    
    % fixation point
    Screen('FillRect',win,[100 110 50],[floor(screen_h*0.5-dim) floor(screen_v*0.5-spess) floor(screen_h*0.5+dim) floor(screen_v*0.5+spess)]);      % horizontal line
    Screen('FillRect',win,[100 110 50],[floor(screen_h*0.5-spess) floor(screen_v*0.5-dim) floor(screen_h*0.5+spess) floor(screen_v*0.5+dim)]);      % vertical line
    Screen(win,'flip');
    pause (fixationTime);
    
    % show the ImageBefore the image in the grid
    for i=1:numImagesExperiment
        tex=Screen('MakeTexture', win, trialsImages(index_trial_show(i)).img);
        Screen('DrawTexture',win, tex);
        Screen(win,'flip');    
        % presentation Time
        pause(presentationTime); 
    end
    
    % grid image creation
    for row=1:length(myRectsGrid)
        Screen('PutImage', win, trialsImages(index_trial(row)).img, [myRectsGrid(row,:)]);
    end
    Screen(win,'flip');
    tmpScreen=Screen('GetImage', win);
    
    % read mouse
    correct = 0;     % correct answers
    attempts = 0;   % number of attempts
    myRects = myRectsGrid;
    
    startTime=GetSecs;
    while attempts < numImagesDisplayed
        if correct == numImagesExperiment
            break;
        end
        
        % previous screen
        Screen('PutImage',win, tmpScreen);
        Screen(win,'flip');
        
        [mouseX, mouseY, buttons]=GetMouse(win);
        if buttons(1)
            % check if is in the coord of one rect
            for row=1:length(myRects)
                if mouseX >=  myRects(row,1) &  mouseX <= myRects(row,3) & ...
                   mouseY >=  myRects(row,2) &  mouseY <= myRects(row,4)
               
                    if ismember (index_trial(row), index_trial_show)
                        correct = correct + 1;
                        Snd('Play',beepYes);
                    else
                        Snd('Play',beepNo);
                    end
                    attempts = attempts + 1;
                    
                    Screen('PutImage',win, tmpScreen);
                    Screen ('FillRect', win, [255 255 255], [myRects(row,:)]);
                    Screen (win,'flip');
                    tmpScreen=Screen('GetImage', win);
                    % avoid errors
                    myRects(row,:)=[-1 -1 -1 -1]; 
                end 
            end
        end
    end
    endTime=GetSecs;

    % accuracy 
    accuracy = num2str(correct/attempts*100);
      
    response(counterTrial).RT = endTime - startTime;
    response(counterTrial).accuracy = accuracy;
    
    str = sprintf('Accuracy: %f \n avarage RT: %f msec', ...
        num2str(response(counterTrial).RT), ...
        num2str(response(counterTrial).accuracy));
    
    DrawFormattedText(win, str, 'center','center');
    Screen(win,'flip');
    pause(2); 
end

DrawFormattedText(win, 'end of the experiment', 'center','center');
Screen(win,'flip');
pause(2);

% data save
[current_folder name ext] = fileparts(mfilename('fullpath'));
filename = [current_folder partecipant_name];
str = sprintf('press "y" to save data in \n %s',filename);
[string] = GetEchoString(win, str, 50, 50, [100 100 100], [250 250 250]); %,'Return');
% [string,terminatorChar] = GetEchoString(win, str, 50, 50, [100 100 100], [250 250 250],'Return');

if string == 'y'
    % Save in excel format
    filename =  [current_folder partecipant_name '.xlsx'];
    data=struct2table (response);
    writetable(data,filename);

    % save into csv
    filename = [current_folder partecipant_name '.csv'];
    writetable(data,filename);
    
    DrawFormattedText(win, 'data saved', 'center','center');
    Screen(win,'flip');
    pause(2);

end

% close everything
Screen('CloseAll');
sca

% imshow(imresize(trialsImages(1).img,[1000 950], 'bilinear'));
% if shrinking an image use Antiliasing as interpolation
% imshow(imresize(trialsImages(1).img,[300 300], 'Antialiasing', false));


