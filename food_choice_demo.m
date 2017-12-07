%=========================================================================
% Probe task code
%=========================================================================

function food_choice_demo(subjid,test_comp,exp_init,scan,task_order,kbid)

Screen('Preference', 'VisualDebugLevel', 0);

c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'

%subjid=input('Enter subject id used from BDM: ', 's');
%order=input('Enter order 1 or 2 ');
%sort_bdm(subjid);

%test_comp=input('Are you scanning? 2 imac, 1 MRI, 0 if testooom: ');


outpath='Output/';

%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------

pixelSize=32;
[w] = Screen('OpenWindow',0,[],[],pixelSize);

% Here Be Colors
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
yellow=[0 255 0]; % actually it is green, but I'm lazy to change the name..


% set up screen positions for stimuli
[wWidth, wHeight]=Screen('WindowSize', w);
xcenter=wWidth/2;
ycenter=wHeight/2;

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);

% text stuffs
theFont='Arial';
Screen('TextFont',w,theFont);
instrSZ=40;
betsz=60;
Screen('TextSize',w, instrSZ);

%---------------------------------------------------------------
%% 'ASSIGN response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');
%MRI=0;
switch scan                 % this is 1 if in MRI scanner
    case 0
        leftstack='u';      % to choose left, they press u key if not in scanner
        rightstack= 'i';    % to choose right, they press i key if not in scanner
        badresp='x';
    case 1
        leftstack='3#';      % to choose left they press the blue 'b' button on button box
        rightstack='4$';    % to choose right they press the yellow 'y' button on button box
        badresp='x';
end
%[shuff_names,shuff_ind]=Shuffle(names);
%shuff_stop=stop(shuff_ind);
% shuff_oneSeveral=oneSeveral(shuff_ind);
%-----------------------------------------------------------------
% set phase times

maxtime=3;      % 3 second limit on each selection, I guess i gave them 3 seconds in the end, I might reduce this.

%-----------------------------------------------------------------
% stack locations

stackW=576; % food image width
stackH=432; %food image height

leftRect=[xcenter-stackW-100 ycenter-stackH/2 xcenter-100 ycenter+stackH/2];  %to position food on left
rightRect=[xcenter+100 ycenter-stackH/2 xcenter+stackW+100 ycenter+stackH/2]; %to position food on right


penWidth=10;

%-----------------------------------------------------------------
% determine stimuli to use based on order number
% this is a bunch of counterbalancing things, to make sure the higher value
% "correct item" is not always on the left or always on the right

%load([outpath, subjid '_food_choice_setup.mat']);

fid=fopen([outpath subjid '_BDM_demo.txt']);     %if multiple BDM files, open the last one
C=textscan(fid, '%s%f' , 'HeaderLines', 1);     %read in BDM output file into C
fclose(fid);

names=C{1};
bid=C{2};
index=Shuffle(1:6);
leftIndex=index(1:3);
leftname=names(index(1:3));
leftbid=bid(index(1:3));
rightIndex=index(4:6);
rightname=names(index(4:6));
rightbid=bid(index(4:6));

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

food_items=cell(1,length(names)); %load in food images
for i=1:length(names)
    food_items{i}=imread(sprintf('stim/demo/%s',names{i}));
end


onsetlist=[0 4.5 9 13.5]+2;


ListenChar(2); %suppresses terminal ouput

KbQueueCreate(kbid);
KbQueueStart(kbid);
%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------


fid1=fopen(['Output/' subjid '_food_choice_demo_' timestamp '.txt'], 'a'); % open output text file, I append output to text file on each trial in case something goes wrong, i still have partial data..

%write the header line
fprintf(fid1,'subjid scanner room experimenter task_order trial onsettime ImageLeft ImageRight Response RT bidLeft bidRight\n');

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------
KbQueueFlush(kbid);
Screen('TextSize',w, instrSZ);
% CenterText(w,'This is similar to the choice part you did before.', white,0,-380);
% CenterText(w,'However this time there are NO POINTS associated with the items.', white,0,-325);
CenterText(w,'In this part two pictures of food items will be presented on the screen.', white,0,-270);
CenterText(w,'For each trial, we want you to choose one of the items.', white,0,-215);
CenterText(w,'You will have 3 seconds to make your choice on each trial, so please', white,0,-160);
CenterText(w,'try to make your choice quickly.', white,0,-105);
CenterText(w,'Your goal is to choose the item you prefer.', white,0,-50);

CenterText(w,'Press any key to continue', white,0,180);

switch scan
    case 0
        CenterText(w,'Please use the `u` or `i` keys on the keyboard ', white,0,5); %different keys to press if in the MRI scanner
        CenterText(w,'for the left and right items respectively.', white, 0,60);
    case 1
        CenterText(w,'Please use the `1` or `2` keys on the keypad ', white,0,5); %different keys to press if in the MRI scanner
        CenterText(w,'for the left and right items respectively.', white, 0,60);
end
HideCursor;
Screen('Flip', w);
KbQueueWait(kbid);         % wait for keypress when they read and understood instructions
KbQueueFlush(kbid);


Screen('TextSize',w, betsz);
CenterText(w,'+', white,0,0); %draw a fixation cross for 2 sec
runStart=Screen(w,'Flip');

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------

for trial=1:3
    
    colorleft=black;
    colorright=black;
    out=999;
    %-----------------------------------------------------------------
    % display images
    %place right and left item on screen
    Screen('PutImage',w,food_items{leftIndex(trial)}, leftRect);
    Screen('PutImage',w,food_items{rightIndex(trial)}, rightRect);
    CenterText(w,'+', white,0,0);
    StimOnset=Screen(w,'Flip', runStart+onsetlist(trial));
    KbQueueFlush(kbid);
    
    %-----------------------------------------------------------------
    % get response
    
    
    noresp=1;
    goodresp=0;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(kbid);
        
        
        if keyIsDown && noresp
            keyPressed=KbName(firstPress);
            if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed=char(keyPressed);
                keyPressed=keyPressed(1);
            end
            switch keyPressed
                case leftstack
                    respTime=firstPress(KbName(leftstack))-StimOnset;
                    noresp=0;
                    goodresp=1;
                case rightstack
                    respTime=firstPress(KbName(rightstack))-StimOnset;
                    noresp=0;
                    goodresp=1;
            end
        end
        
        
        % check for reaching time limit
        if noresp && GetSecs-runStart >= onsetlist(trial)+maxtime
            noresp=0;
            keyPressed=badresp;
            respTime=maxtime;
            
        end
    end
    
    
    %-----------------------------------------------------------------
    
    
    % determine what bid to highlight
    
    switch keyPressed
        case leftstack
            colorleft=yellow;
        case rightstack
            colorright=yellow;
    end
    
    if goodresp==1
        
        Screen('PutImage',w,food_items{leftIndex(trial)}, leftRect);
        Screen('PutImage',w,food_items{rightIndex(trial)}, rightRect);
        
        Screen('FrameRect', w, colorleft, leftRect, penWidth);
        Screen('FrameRect', w, colorright, rightRect, penWidth);
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(trial)+respTime);
        
    else
        CenterText(w, 'TOO SLOW!', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(trial)+respTime);
    end
    
    
    %-----------------------------------------------------------------
    % show fixation ITI
    CenterText(w,'+', white,0,0);
    Screen(w,'Flip',runStart+onsetlist(trial)+respTime+.5);
    
    if goodresp ~= 1
        respTime=999;
    end
    
    %-----------------------------------------------------------------
    % write to output file
    fprintf(fid1,'%s %d %s %s %d %d %d %s %s %s %f %f %f \n', subjid, scan, test_comp, exp_init, task_order, trial, StimOnset-runStart, char(leftname(trial)), char(rightname(trial)), keyPressed, respTime, leftbid(trial), rightbid(trial));
    
    KbQueueFlush(kbid);
end



fclose(fid1);

Screen('TextSize',w, betsz);
CenterText(w,'Thank you!', yellow,0,-100);
CenterText(w,'We will continue shortly ...', yellow,0,0);

Screen('Flip', w, StimOnset+4);
WaitSecs(5);

%if scan==1
%    fprintf(['\n \n \n You just ran probe( `' subjid '`,' num2str(order) ',' num2str(test_comp) '). Next you want to run one_sev( `' subjid '`,2,One/Several_order' num2str(MRI) ') \n \n \n']);
%end

% noresp=1;
% while noresp
%     [keyIsDown,secs,keyCode] = KbCheck;
%     if find(keyCode)==44 & keyIsDown & noresp
%         noresp = 0;
%     end
% end

%time=clock;
outfile=strcat(outpath, sprintf('%s_food_choice_demo_%s_%02.0f-%02.0f.mat',subjid,date,c(4),c(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;

run_info.script_name=mfilename;
clear food_items ;
save(outfile);


ListenChar(0);
ShowCursor;
sca




