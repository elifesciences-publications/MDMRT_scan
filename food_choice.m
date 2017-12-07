%=========================================================================
% Probe task code
%=========================================================================

function food_choice(subjid,test_comp,exp_init,eye,scan,run,task_order,subkbid,expkbid,triggerkbid)

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


HideCursor;
KbQueueCreate(expkbid);
KbQueueStart(expkbid);

KbQueueCreate(subkbid);
KbQueueStart(subkbid)

if eye==1
    %==============================================
    %% 'INITIALIZE Eyetracker'
    %==============================================
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initializing eye tracking system %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ListenChar(2);
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
    CenterText(w,'(y)es', white,-50,100);
    CenterText(w,'/', white,0,100);
    CenterText(w,'(n)o', white,50,100);
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
                    CenterText(w,'(y)es', ycol,-50,100);
                    CenterText(w,'/', white,0,100);
                    CenterText(w,'(n)o', ncol,50,100);
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
                    CenterText(w,'(y)es', ycol,-50,100);
                    CenterText(w,'/', white,0,100);
                    CenterText(w,'(n)o', ncol,50,100);
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
        leftstack='3#';      % to choose left they press the blue 3 button on button box
        rightstack='4$';    % to choose right they press the yellow 4 button on button box
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
midRect=[xcenter+80 ycenter-80 xcenter+80 ycenter+80];

penWidth=10; 

%-----------------------------------------------------------------
% determine stimuli to use based on order number
% this is a bunch of counterbalancing things, to make sure the higher value
% "correct item" is not always on the left or always on the right

load([outpath, subjid '_food_choice_setup.mat']);

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

food_items=cell(1,length(names)); %load in food images 
for i=1:length(names)
    food_items{i}=imread(sprintf('stim/%s',names{i}));
end


r=Shuffle(1:10);
load(['onsets/food_choice_onset_' num2str(r(1)) '.mat']); % these are custom timing files that tell screen when to flip after the run starts in secs
%onsetlist=onsetlist.onsetlist;


%ListenChar(2); %suppresses terminal ouput

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------


fid1=fopen(['Output/' subjid '_food_choice_run_' num2str(run) '_' timestamp '.txt'], 'a'); % open output text file, I append output to text file on each trial in case something goes wrong, i still have partial data..

%write the header line
fprintf(fid1,'subjid scanner eye room experimenter task_order run runtrial onsettime ImageLeft ImageRight IsLefthigh Response PairNumber Outcome RT bidIndexLeft bidIndexRight bidLeft bidRight timeFixMid timeFixLeft timeFixRight numMidFix numLeftFix numRightFix firstFix firstFixTime\n'); 

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

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

Screen('Flip', w);

KbQueueWait(subkbid);        % wait for keypress when they read and understood instructions
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
CenterText(w,'+', white,0,0); %draw a fixation cross for 2 sec
runStart=Screen(w,'Flip');
%WaitSecs(2);


%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------

for block=run
    for trial=1:length(leftname{block})

        colorleft=black;
        colorright=black;
        out=999;
        trial_time_fixated_left = 999;
        trial_time_fixated_right = 999;
        trial_time_fixated_mid = 999;
        trial_num_left_fixations = 999;
        trial_num_right_fixations = 999;
        trial_num_mid_fixations = 999;
        first_fixation_duration = 999;
        first_fixation_area = 'x';
        %-----------------------------------------------------------------
        % display images
        %place right and left item on screen
        Screen('PutImage',w,food_items{leftbidIndex{block}(trial)}, leftRect);      
        Screen('PutImage',w,food_items{rightbidIndex{block}(trial)}, rightRect);
        CenterText(w,'+', white,0,0);
        StimOnset=Screen(w,'Flip', runStart+onsetlist(trial));
        KbQueueFlush(subkbid);

        if eye==1
            % Eyelink msg
            % - - - - - - -
            onsetmessage=strcat('Trial ',num2str(trial),' Onset = ',num2str(StimOnset-runStart));
            Eyelink('Message',onsetmessage);
            trial_time_fixated_left = 0;
            trial_time_fixated_right = 0;
            trial_time_fixated_mid = 0;
            trial_num_left_fixations = 0;
            trial_num_right_fixations = 0;
            trial_num_mid_fixations = 0;
            
            % current_area determines which area eye is in (left, right, neither)
            % xpos and ypos are used for eyepos_debug
            [current_area, ~, ~] = get_current_fixation_area(dummymode,el,eye_used,midRect,leftRect,rightRect);
            
            % last_area will track what area the eye was in on the previous loop
            % iteration, so we can determine when a change occurs
            % fixation_onset_time stores the time a "fixation" into an area began
            last_area=current_area;
            fixation_onset_time = GetSecs;
            
            % tracking first fixation
            first_fixation_duration = 0;
            first_fixation_area = current_area; % this will report 'n' in output if they never looked at an object
            first_fixation_flag = (first_fixation_area=='m' || first_fixation_area=='l' || first_fixation_area=='r'); % flags 1 once the first fixation has occurred, 2 once the first fixation has been processed
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
                [current_area, ~, ~] = get_current_fixation_area(dummymode,el,eye_used,midRect,leftRect,rightRect);
                
                % they are looking in a new area
                % Currently has initial fixation problems? (color, count, etc.)
                if current_area~=last_area
                    % update timings
                    switch last_area
                        case 'm'
                            trial_time_fixated_mid = trial_time_fixated_mid + (GetSecs-fixation_onset_time);
                            trial_num_mid_fixations = trial_num_mid_fixations + 1;
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
                    if(first_fixation_flag==0 && (current_area=='m' || current_area=='l' || current_area=='r'))
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
                    Screen('PutImage',w,food_items{leftbidIndex{block}(trial)}, leftRect);
                    Screen('PutImage',w,food_items{rightbidIndex{block}(trial)}, rightRect);
                    CenterText(w,'+', white,0,0);
                    % overshadow eye_oval
                    eye_oval = [xpos-10 ypos-10 xpos+10 ypos+10];
                    Screen('FrameOval',w,white,eye_oval,penWidth);
                    Screen('Flip',w,0);
                end
                
                fixation_duration = GetSecs-fixation_onset_time;
            end
            
            % check for reaching time limit
            if noresp && GetSecs-runStart >= onsetlist(trial)+maxtime
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
                case 'm'
                    trial_time_fixated_mid = trial_time_fixated_mid + fixation_duration;
                    trial_num_mid_fixations = trial_num_mid_fixations + 1;
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
                if lefthigh{block}(trial)==1
                    out=1;
                else
                    out=0;
                end
            case rightstack
                colorright=yellow;
                if lefthigh{block}(trial)==0
                    out=1;
                else
                    out=0;
                end
        end

        if goodresp==1

            Screen('PutImage',w,food_items{leftbidIndex{block}(trial)}, leftRect);
            Screen('PutImage',w,food_items{rightbidIndex{block}(trial)}, rightRect);

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
        fixtime=Screen(w,'Flip',runStart+onsetlist(trial)+respTime+.5);

        if eye==1
            % Eyelink msg
            % - - - - - - -
            fixcrosstime = strcat('fixcrosstime = ',num2str(fixtime-runStart));
            Eyelink('Message',fixcrosstime);
        end
        
        if goodresp ~= 1
            respTime=999;
        end

        %-----------------------------------------------------------------
        % write to output file                                              
        fprintf(fid1,'%s %d %d %s %s %d %d %d %d %s %s %d %s %d %d %f %d %d %f %f %f %f %f %d %d %d %c %f\n',...
            subjid, scan, eye, test_comp, exp_init, task_order, block, trial, StimOnset-runStart, ...
            char(leftname{block}(trial)), char(rightname{block}(trial)), lefthigh{block}(trial), ...
            keyPressed, pairtype{block}(trial), out, respTime, leftbidIndex{block}(trial), ...
            rightbidIndex{block}(trial),leftbid{block}(trial), rightbid{block}(trial), ...
            trial_time_fixated_mid, trial_time_fixated_left, trial_time_fixated_right, ...
            trial_num_mid_fixations, trial_num_left_fixations, trial_num_right_fixations,...
            first_fixation_area, first_fixation_duration);
      
        KbQueueFlush(subkbid);
    end
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
        movefile('recdata.edf',strcat('Output/', subjid,'_food_choice_run_', num2str(run), '_', timestamp,'.edf'));
    end;
end

CenterText(w,'Great job!', white,0,-100);
if scan==1
    CenterText(w,'We will continue to the next run shortly.', white,0,0);
elseif scan==0 && eye==0 && ((task_order==2 && run<3) || (task_order==1))
    CenterText(w,'We will continue to the next task shortly.', white,0,0);
else
    CenterText(w,'Please get the experimenter.', white,0,0);
end
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
outfile=strcat(outpath, sprintf('%s_food_choice_run_%d_%s_%02.0f-%02.0f.mat',subjid,run,date,c(4),c(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;

run_info.script_name=mfilename;
clear food_items ;
save(outfile);


%ListenChar(0);
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
ListenChar(0);
ShowCursor;
end

% returns "f" for item, "l" for buyleft, "r" for buyright, or "n" for none. Also returns x,y
% positions in case eyepos_debug is being used
function [current_area,  xpos, ypos] = get_current_fixation_area(dummymode,el,eye_used,midRect,leftRect,rightRect)
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
if IsInRect(xpos,ypos,midRect)
    current_area='m';
elseif IsInRect(xpos,ypos,leftRect)
    current_area='l';
elseif IsInRect(xpos,ypos,rightRect)
    current_area='r';
else
    current_area='n';
end
return
end



