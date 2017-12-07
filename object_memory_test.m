%=========================================================================
% Memory test task code
%=========================================================================

function object_memory_test(subjid,test_comp,exp_init,eye,scan,run,task_order,subkbid,expkbid,triggerkbid)

Screen('Preference', 'SkipSyncTests', 1);
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

if run == 1
    fid=fopen([outpath subjid '_object_rating.txt']);     
    vars=textscan(fid, '%s%d%s%f%d' , 'HeaderLines', 1);     
    fclose(fid);
    oldobj=vars{3};
    oldratings=vars{4};
    
    %-----------------------------------------------------------------
    % determine stimuli to use based on order number
    
    isold=zeros(1,200);
    objrating=zeros(1,200);
    stim=cell(1,1);
    num=Shuffle(1:200);
    for i=1:200
        stim{i}=sprintf('%.3d%s',num(i),'.bmp');
        if isempty(find(strcmp(oldobj,stim{i}),1))
            objrating(i)=NaN;
            isold(i)=0;
        else
            objrating(i)=oldratings(find(strcmp(oldobj,stim{i}),1));
            isold(i)=1;
        end
    end
    save([outpath subjid '_memory_test_vars.mat'],'isold', 'objrating', 'stim');
end

load([outpath subjid '_memory_test_vars.mat']);

%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------

pixelSize=32;
[w] = Screen('OpenWindow',0,[],[],pixelSize);

% Here Be Colors
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
yellow=[0 255 0];


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


HideCursor;
KbQueueCreate(expkbid);
KbQueueStart(expkbid);

KbQueueCreate(subkbid);
KbQueueStart(subkbid);


if eye==1
    %==============================================
    %% 'INITIALIZE Eyetracker'
    %==============================================
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initializing eye tracking system %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ListenChar(2);
    dummymode=0;
    eyepos_debug=0;
    
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(w);
    % Disable key output to Matlab window:
    %%%%%%%%%%%%%ListenChar(2);
    
    el.backgroundcolour = black;
    el.backgroundcolour = black;
    el.foregroundcolour = white;
    el.msgfontcolour    = white;
    el.imgtitlecolour   = white;
    el.calibrationtargetcolour = el.foregroundcolour;
    EyelinkUpdateDefaults(el);
    
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end;
    
    [~, vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');
    
    % open file to record data to
    edfFile='recdata.edf';
    Eyelink('Openfile', edfFile);
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    

    
    Screen('TextSize',w, 40);
    CenterText(w,'Continue using eyetracker?', white,0,0);
    CenterText(w,'(y)es', white,-75,100);
    CenterText(w,'/', white,0,100);
    CenterText(w,'(n)o', white,75,100);
    Screen(w,'Flip');
    
    noresp=1;
    while noresp
        [keyIsDown, firstPress] = KbQueueCheck(expkbid);
        if keyIsDown && noresp
            keyPressed=KbName(firstPress);
            if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed=char(keyPressed);
                keyPressed=keyPressed(1);
            end
            switch keyPressed
                case 'y'
                    noresp=0;
                    eye=1;
                    ycol=yellow;
                    ncol=white;
                    CenterText(w,'Continue using eyetracker?', white,0,0);
                    CenterText(w,'(y)es', ycol,-75,100);
                    CenterText(w,'/', white,0,100);
                    CenterText(w,'(n)o', ncol,75,100);
                    Screen(w,'Flip');
                    WaitSecs(.5);
                    % do a final check of calibration using driftcorrection
                    EyelinkDoDriftCorrection(el);
                case 'n'
                    noresp=0;
                    eye=0;
                    ycol=white;
                    ncol=yellow;
                    CenterText(w,'Continue using eyetracker?', white,0,0);
                    CenterText(w,'(y)es', ycol,-75,100);
                    CenterText(w,'/', white,0,100);
                    CenterText(w,'(n)o', ncol,75,100);
                    Screen(w,'Flip');
                    WaitSecs(.5);
            end
        end
    end
    
    
    ListenChar(0);
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Finish Initialization %
    %%%%%%%%%%%%%%%%%%%%%%%%%
end


%---------------------------------------------------------------
%% 'ASSIGN OLD/NEW right/left
%---------------------------------------------------------------
switch task_order
    case 1
        leftisold=1;
        left='OLD';
        right='NEW';
        oldkey='1';
        newkey='2';
    case 2
        leftisold=0;
        left='NEW';
        right='OLD';
        oldkey='2';
        newkey='1';        
end

%---------------------------------------------------------------
%% 'ASSIGN response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');
switch scan
    case 0
        leftstack='u';
        rightstack= 'i';
    case 1
        leftstack='3#';
        rightstack='4$';
end
badresp='x';

%-----------------------------------------------------------------
% set phase times

maxtime=3;      % 3 second limit on each selection

%-----------------------------------------------------------------
% stack locations

stackW=400;
stackH=400;

Rect=[xcenter-stackW/2 ycenter-stackH/2  xcenter+stackW/2 ycenter+stackH/2];

leftRect=[xcenter-200-50 ycenter-300-50  xcenter-200+50 ycenter-300+50];
rightRect=[xcenter+200-50 ycenter-300-50  xcenter+200+50 ycenter-300+50];

%penWidth=5;

r=Shuffle(1:10);
load(['onsets/memory_test_onset_' num2str(r(1)) '.mat']);
%onsetlist=onsetlist.onsetlist;


%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

items=cell(1,50);
switch run
    case 1
        s=1;
    case 2
        s=51;
    case 3
        s=101;
    case 4
        s=151;
end

for i=s:s+49
    items{i}=imread(sprintf('stim/%s',stim{i}));
end

KbQueueFlush(expkbid);
ListenChar(2); %suppresses terminal ouput

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1=fopen(['Output/' subjid '_memory_run_' num2str(run) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid scanner eyetracker room experimenter trial onsettime Image Rating leftOld isold Response Outcome RT timeFixitem timeFixLeft timeFixRight numitemFix numLeftFix numRightFix numOtherFix firstFix firstFixTime\n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, instrSZ);

CenterText(w,'This is a memory test for the objects you rated 2 days ago.', white,0,-270);
CenterText(w,'For each trial, an object will appear.', white,0,-215);
CenterText(w,'Try to remember whether you rated how much you liked that object 2 days ago.', white,0,-160);
CenterText(w,['2 options, ' left ' or ' right ' will appear at the bottom of the screen.'], white,0,-105);
CenterText(w,['Please press `' oldkey '` key for `OLD` if you remember this item,'],white,0,-50);
CenterText(w,['and press `' newkey '` key for `NEW` if you do not remember the item.'], white,0,5);
CenterText(w,'You will have 3 seconds to make a response, so please be quick.', white,0,60);

CenterText(w,'Press any key to continue', white,0,205);

Screen('Flip', w);
KbQueueWait(subkbid);
KbQueueFlush(subkbid);
if scan==1
    CenterText(w,'GET READY!', white, 0, 0);    %this is for the MRI scanner, it waits for a 't' trigger signal from the scanner
    Screen('Flip',w);
    KbTriggerWait(KbName('t'),triggerkbid);
end

if eye==1
    % STEP 5
    % start recording eye position
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    Eyelink('Message', 'SYNCTIME after fixations'); % mark start time in file
    if ~dummymode
        eye_used = Eyelink('EyeAvailable');
        if eye_used == -1
            fprintf('Eyelink aborted - could not find which eye being used.\n');
            cleanup;
        end
    end
end

KbQueueCreate(subkbid);
KbQueueStart(subkbid);

Screen('TextSize',w, betsz);
Screen('DrawText', w, '+', xcenter, ycenter, white);
runStart=Screen(w,'Flip');

if eye==1
    % Eyelink msg
    % - - - - - - -
    Eyelink('Message',strcat('runStart=',num2str(runStart)));
end

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
runtrial=0;
for trial=s:s+49
    runtrial=runtrial+1;
    colorleft=white;
    colorright=white;
    out=999;
    trial_time_fixated_item = 999;
    trial_time_fixated_left = 999;
    trial_time_fixated_right = 999;
    trial_time_unfixated = 999;
    trial_num_item_fixations = 999;
    trial_num_left_fixations = 999;
    trial_num_right_fixations = 999;
    trial_num_middle_fixations = 999;
    first_fixation_duration = 999;
    first_fixation_area = 'x';

    %-----------------------------------------------------------------
    % display images
    Screen('PutImage',w,items{trial}, Rect);
    CenterText(w,left,white,-200,300);
    CenterText(w,right,white,200,300);
    StimOnset=Screen(w,'Flip', runStart+onsetlist(runtrial));
    KbQueueFlush(subkbid);
    
    if eye==1
        % Eyelink msg
        % - - - - - - -
        onsetmessage=strcat('Trial ',num2str(trial),' Onset= ',num2str(StimOnset-runStart));
        Eyelink('Message',onsetmessage);
        trial_time_fixated_item = 0;
        trial_time_fixated_left = 0;
        trial_time_fixated_right = 0;
        trial_time_unfixated = 0;
        trial_num_item_fixations = 0;
        trial_num_left_fixations = 0;
        trial_num_right_fixations = 0;
        trial_num_middle_fixations = 0;
        
        % current_area determines which area eye is in (left, right, neither)
        % xpos and ypos are used for eyepos_debug
        [current_area, ~, ~] = get_current_fixation_area(dummymode,el,eye_used,Rect,leftRect,rightRect);
        
        % last_area will track what area the eye was in on the previous loop
        % iteration, so we can determine when a change occurs
        % fixation_onset_time stores the time a "fixation" into an area began
        last_area=current_area;
        fixation_onset_time = GetSecs;
        
        % tracking first fixation
        first_fixation_duration = 0;
        first_fixation_area = current_area; % this will report 'n' in output if they never looked at an object
        first_fixation_flag = (first_fixation_area=='i' || first_fixation_area=='l' || first_fixation_area=='r'); % flags 1 once the first fixation has occurred, 2 once the first fixation has been processed
        first_fixation_onset = fixation_onset_time;
    end
    
    %-----------------------------------------------------------------
    % get response
    noresp=1;
    goodresp=0;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(subkbid);
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
        
        if eye==1
            % get eye position
            [current_area, ~, ~] = get_current_fixation_area(dummymode,el,eye_used,Rect,leftRect,rightRect);
            
            % they are looking in a new area
            % Currently has initial fixation problems? (color, count, etc.)
            if current_area~=last_area
                % update timings
                switch last_area
                    case 'n'
                        trial_time_unfixated = trial_time_unfixated + (GetSecs-fixation_onset_time);
                        trial_num_middle_fixations = trial_num_middle_fixations + 1;
                    case 'i'
                        trial_time_fixated_item = trial_time_fixated_item + (GetSecs-fixation_onset_time);
                        trial_num_item_fixations = trial_num_item_fixations + 1;
                    case 'l'
                        trial_time_fixated_left = trial_time_fixated_left + (GetSecs-fixation_onset_time);
                        trial_num_left_fixations = trial_num_left_fixations + 1;
                    case 'r'
                        trial_time_fixated_right = trial_time_fixated_right + (GetSecs-fixation_onset_time);
                        trial_num_right_fixations = trial_num_right_fixations + 1;
                end
                
                fixation_onset_time=GetSecs;
                
                % they have looked away from their first fixation: record its
                % duration and the target (left/right)
                if(first_fixation_flag==1)
                    %outstr=['first fixation lasted ' GetSecs-first_fixation_onset ' seconds'];
                    %Eyelink('Message',outstr);
                    first_fixation_duration = GetSecs-first_fixation_onset;
                    first_fixation_flag = 2;
                end
                
                % this is their first time fixating on an object this trial
                if(first_fixation_flag==0 && (current_area=='i' || current_area=='l' || current_area=='r'))
                    %outstr=['first fixation on ' last_area];
                    %Eyelink('Message',outstr);
                    first_fixation_flag = 1;
                    first_fixation_onset = fixation_onset_time;
                    first_fixation_area = current_area;
                end
            end
            
            last_area = current_area;
            
            % draws a dot where the eye is believed to be, potential debug use
            if eyepos_debug
                Screen('PutImage',w,items{trial}, Rect);
                CenterText(w,right,white,-200,300);
                CenterText(w,left,white,200,300);
                % overshadow eye_oval
                eye_oval = [xpos-10 ypos-10 xpos+10 ypos+10];
                Screen('FrameOval',w,white,eye_oval,penWidth);
                Screen('Flip',w,0);
            end
            
            fixation_duration = GetSecs-fixation_onset_time;
        end
        
        % check for reaching time limit
        if noresp && GetSecs >= StimOnset+maxtime
            noresp=0;
            keyPressed=badresp;
            respTime=maxtime;
        end
    end
    
    if eye==1
        % Eyelink msg
        % - - - - - - -
        rtmsg = strcat('RT = ',num2str(respTime));
        Eyelink('Message',rtmsg);
        switch last_area
            case 'n'
                trial_time_unfixated = trial_time_unfixated + fixation_duration;
                trial_num_middle_fixations = trial_num_middle_fixations + 1;
            case 'i'
                trial_time_fixated_item = trial_time_fixated_item + fixation_duration;
                trial_num_item_fixations = trial_num_item_fixations + 1;
            case 'l'
                trial_time_fixated_left = trial_time_fixated_left + fixation_duration;
                trial_num_left_fixations = trial_num_left_fixations + 1;
            case 'r'
                trial_time_fixated_right = trial_time_fixated_right + fixation_duration;
                trial_num_right_fixations = trial_num_right_fixations + 1;
        end
        
        % time limit reached while fixating on first fixated object
        if(first_fixation_flag==1)
            %outstr=['first fixation lasted ' GetSecs-first_fixation_onset ' seconds'];
            %Eyelink('Message',outstr);
            first_fixation_duration = GetSecs-first_fixation_onset;
            first_fixation_flag = 2;
        end
    end
    
    
    %-----------------------------------------------------------------
    % determine what bid to highlight
    switch keyPressed
        case leftstack
            colorleft=yellow;
            if isold(trial)==1 && leftisold==1
                out=1;
            elseif isold(trial)==0 && leftisold==0
                out=1;
            else
                out=0;
            end
        case rightstack
            colorright=yellow;
            if isold(trial)==0 && leftisold==1
                out=1;
            elseif isold(trial)==1 && leftisold==0
                out=1;
            else
                out=0;
            end
    end
    
    if goodresp==1
        Screen('PutImage',w,items{trial}, Rect);
        CenterText(w,left,colorleft,-200,300);
        CenterText(w,right,colorright,200,300);
        Screen(w,'Flip',StimOnset+respTime);
    else
        CenterText(w,'TOO SLOW!',white,0,0);
        Screen(w,'Flip',StimOnset+respTime);
    end
    
    %-----------------------------------------------------------------
    % show fixation ITI
    CenterText(w,'+', white,0,0);
    fixtime=Screen(w,'Flip',StimOnset+respTime+.5);
    
    if eye==1
        % Eyelink msg
        % - - - - - - -
        fixcrosstime = strcat('fixcrosstime = ',num2str(fixtime-runStart));
        Eyelink('Message',fixcrosstime);
    end
    
    
    if goodresp==0
        respTime=999;
    end
    
    %-----------------------------------------------------------------
    % write to output file

    fprintf(fid1,'%s %d %d %s %s %d %d %s %f %d %d %s %d %.3f %.3f %.3f %.3f %d %d %d %d %s %.3f\n',...
        subjid, scan, eye, test_comp, exp_init, trial, StimOnset-runStart, stim{trial}, ...
        objrating(trial), leftisold, isold(trial), keyPressed, out, respTime, ...
        trial_time_fixated_item, trial_time_fixated_left, trial_time_fixated_right, trial_num_item_fixations,...
        trial_num_left_fixations, trial_num_right_fixations, trial_num_middle_fixations,...
        first_fixation_area, first_fixation_duration);    
    
    KbQueueFlush(subkbid);
end

fclose(fid1);

%==============================================
%% 'BLOCK over, close out and save data'
%==============================================

%---------------------------------------------------------------
%   close out eyetracker
%---------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%
% finishing eye tracking %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 7
% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
if eye==1
    Eyelink('StopRecording');
    WaitSecs(.1);
    Eyelink('CloseFile');
    
    
    % download data file
    % - - - - - - - - - - - -
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end
    
    
    if dummymode==0
        movefile('recdata.edf',strcat('Output/', subjid,'_memory_run_', num2str(run), '_', timestamp,'.edf'));
    end;
end

Screen('TextSize',w, 30);
CenterText(w,'Thank you!', yellow,0,-100);

if scan==1 && run<4
    CenterText(w,'We will continue with another run shortly ...', yellow,0,0);
elseif scan==1 && run==4
    CenterText(w,'Great job! We will come in and take you out.', yellow,0,0);
elseif scan==0 && eye==1    
    CenterText(w,'Please get the experimenter.', yellow,0,0);
elseif scan==0 && eye==0
    CenterText(w,'We will continue with another run shortly ...', yellow,0,0);
else
    CenterText(w,'Please get the experimenter.', yellow,0,0);
end

Screen('Flip', w, StimOnset+4);
WaitSecs(5);

outfile=strcat(outpath, sprintf('%s_memory_run_%d_%s_%02.0f-%02.0f.mat',subjid,run,date,c(4),c(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;

run_info.script_name=mfilename;
clear items;
save(outfile);

ListenChar(0);
ShowCursor;
sca
end

% Cleanup routine:
function cleanup

% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('Stoprecording');
Eyelink('CloseFile');
Eyelink('Shutdown');

% Close window:
Screen('CloseAll');

% Restore keyboard output to Matlab:
%ListenChar(0);
ShowCursor;
end

% returns "f" for item, "l" for buyleft, "r" for buyright, or "n" for none. Also returns x,y
% positions in case eyepos_debug is being used
function [current_area,  xpos, ypos] = get_current_fixation_area(dummymode,el,eye_used,Rect,leftRect,rightRect)
xpos = 0;
ypos = 0;
if ~dummymode
    evt=Eyelink('NewestFloatSample');
    x=evt.gx(eye_used+1);
    y=evt.gy(eye_used+1);
    if(x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0)
        xpos=x;
        ypos=y;
    end
else % in dummy mode use mousecoordinates
    [xpos,ypos] = GetMouse;
end

% check what area the eye is in
if IsInRect(xpos,ypos,Rect)
    current_area='i';
elseif IsInRect(xpos,ypos,leftRect)
    current_area='l';
elseif IsInRect(xpos,ypos,rightRect)
    current_area='r';
else
    current_area='n';
end
return
end




