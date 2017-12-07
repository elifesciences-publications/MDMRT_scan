%=========================================================================
% Memory test task code
%=========================================================================

function object_memory_test_demo(subjid,test_comp,exp_init,scan,task_order,kbid)

%Screen('Preference', 'SkipSyncTests', 1);
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
    
fid=fopen([outpath subjid '_object_rating_demo.txt']);     %if multiple BDM files, open the last one
vars=textscan(fid, '%s%d%s%f%d' , 'HeaderLines', 1);     %read in BDM output file into C
fclose(fid);

oldobj=vars{3};
oldratings=vars{4};

%-----------------------------------------------------------------
% determine stimuli to use based on order number

isold=zeros(1,8);
objrating=zeros(1,8);
stim=cell(1,1);
num=Shuffle(201:208);
for i=1:8
    stim{i}=sprintf('%.3d%s',num(i),'.bmp');
    if num(i) < 205
        objrating(i)=oldratings(find(strcmp(oldobj,stim{i}),1));
        isold(i)=1;
    else
        objrating(i)=NaN;
        isold(i)=0;
    end
end



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

ListenChar(2);
HideCursor;
KbQueueCreate(kbid);
KbQueueStart(kbid);

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

%penWidth=5;

onsetlist=[2 6.5 11 15.5 20 24.5];


%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

items=cell(1,8);

for i=1:8
    items{i}=imread(sprintf('stim/%s',stim{i}));
end

HideCursor;

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1=fopen(['Output/' subjid '_memory_test_demo_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid scanner room experimenter trial onsettime Image Rating leftOld isold Response Outcome RT\n'); %write the header line

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
Screen(w,'Flip');

KbQueueWait(kbid);
KbQueueFlush(kbid);

Screen('TextSize',w, betsz);
Screen('DrawText', w, '+', xcenter, ycenter, white);
runStart=Screen(w,'Flip');

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------

for trial=1:6
    
    colorleft=white;
    colorright=white;
    out=999;

    %-----------------------------------------------------------------
    % display images
    Screen('PutImage',w,items{trial}, Rect);
    CenterText(w,left,white,-200,300);
    CenterText(w,right,white,200,300);
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
        if noresp && GetSecs >= StimOnset+maxtime
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
    Screen(w,'Flip',StimOnset+respTime+.5);
        
    if goodresp==0
        respTime=999;
    end
    
    %-----------------------------------------------------------------
    % write to output file
    
    fprintf(fid1,'%s %d %s %s %d %d %s %f %d %d %s %d %f\n',...
        subjid, scan, test_comp, exp_init, trial, StimOnset-runStart, stim{trial}, ...
        objrating(trial), leftisold, isold(trial), keyPressed, out, respTime);
    
    KbQueueFlush(kbid);
end

fclose(fid1);

Screen('TextSize',w, 40);
CenterText(w,'Thank you!', yellow,0,-100);
CenterText(w,'We will continue shortly.', yellow,0,0);

Screen('Flip', w, StimOnset+4);
WaitSecs(5);

outfile=strcat(outpath, sprintf('%s_memory_demo_%s_%02.0f-%02.0f.mat',subjid,date,c(4),c(5)));

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
