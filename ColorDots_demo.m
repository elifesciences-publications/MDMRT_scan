function ColorDots_demo(subjid,test_comp,exp_init,scan,task_order, button_order,kbid)
% This demo shows color dots three times and returns their information.
%
% info{trial} has the following fields:
% - color_coh
% : corresponds to the difficulty and the answer.
%   Negative means yellow, positive blue.
%   The larger absolute value, the easier it is.
%
% - prop
% : the probability of a dot being blue.
%   Note that color_coh == logit(prop).
%
% - xy_pix{fr}(xy, dot) has the dot position on that frame in pixel.
%     The first row is x, the second y.
%
% - col2{fr}(dot) = 1 means that the dot on that frame was blue.
%
% Dots contains more information, but perhaps they wouldn't matter
% in most cases.

% 2016 YK wrote the initial version. hk2699 at columbia dot edu.
% Feb 2016 modified by AB. ab4096 at columbia dot edu.

Screen('Preference', 'VisualDebugLevel', 0);
%Screen('Preference', 'SkipSyncTests', 1);

c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];

ColorDots_init_path;

% Initialization
scr = 0;
background_color = 0;
win = Screen('OpenWindow', scr, background_color);

green=[0 255 0];
red=[255 0 0];
white=[255 255 255];


KbQueueCreate(kbid);
KbQueueStart(kbid);
HideCursor;

switch scan
    case 1
        switch button_order
            case 1
                blue='3#';
                bluebutton='1';
                yellow='4$';
                yellowbutton='2';
            case 2
                blue='4$';
                bluebutton='2';
                yellow='3#';
                yellowbutton='1';
        end
    case 0
        switch button_order
            case 1
                blue='u';
                bluebutton='u';
                yellow='i';
                yellowbutton='i';
            case 2
                blue='i';
                bluebutton='i';
                yellow='u';
                yellowbutton='u';
        end
end

% You may want to change the following three parameters
% with the ones measured from the experimental setup.
Dots = ColorDots( ...
    'scr', scr, ...
    'win', win, ...
    'dist_cm', 55, ...
    'monitor_width_cm', 30);

n_trial = 10;
info = cell(1, n_trial);
outcomes=zeros(1,n_trial);

% I recommend the pool of color coherences in the code.
% You might omit one of the zeros (i.e., leave only one zero)
% - that would slightly reduce the power for reverse correlation
% later.
% You might also omit the -2 and 2, but that might reduce the
% range of RTs.
color_coh_pool = [-2, -1, -0.5, -0.25, -0.125, 0, 0, 0.125, 0.25, 0.5, 1, 2];

n_fr = 150;


ListenChar(2);
KbQueueFlush(kbid);

%INTRUCTIONS
Screen('TextSize',win,40);
CenterText(win,'You will see a cloud of flickering dots that are either yellow or blue.',white,0,-300);
CenterText(win,['If you think the cloud contains more yellow dots than blue on average, press key `' yellowbutton '`.'],white,0,-250);
CenterText(win,['If you think the cloud contains more blue dots, press key `' bluebutton '`.'],white,0,-200);
CenterText(win,'Do not try to count the exact number of dots in each color,',white,0,-150);
CenterText(win,'because the number fluctuates rapidly over time,',white,0,-100);
CenterText(win,'and because each dot appears only briefly.',white,0,-50);
CenterText(win,'Rather, try to estimate the rough average.',white,0,0);
CenterText(win,'Please respond as soon as you have an answer.',white,0,50);
CenterText(win,'Press any button to continue...',white,0,200);
Screen('Flip',win);
KbQueueWait(kbid);

KbQueueFlush(kbid);

CenterText(win,'+',white,0,0);
runStart=Screen('Flip',win);
WaitSecs(1);

fid1=fopen(['Output/' subjid '_dots_demo_' timestamp '.txt'], 'a');

%write the header line
fprintf(fid1,'subjid scanner test_comp experimenter runtrial onsettime color_coh prop response outcome disptime RT task_order button_order\n');

% Iterating trials

for trial=1:n_trial
    
    fprintf('-----\n');
    fprintf('Trial %d:\n', trial);
    
    t_fr = zeros(1, n_fr + 1);
    
    color_coh = randsample(color_coh_pool, 1);
    prop = invLogit(color_coh);
    
    % Dots.init_trial must be called before Dots.draw.
    Dots.init_trial(prop);
    KbQueueFlush(kbid);
    
    for fr = 1:n_fr
        % Since the dots should update every frame,
        % draw other components (e.g., fixation point)
        % before each flip, around Dots.draw.
        
        % Draw components here to have dots draw over them.
        
        Dots.draw;
        
        % Draw components here to draw over the dots.
        
        t_fr(fr) = Screen('Flip', win);
        
        
        [keyIsDown, firstPress] = KbQueueCheck(kbid);
        keyPressed=KbName(firstPress);
        if keyIsDown && ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
            keyPressed=char(keyPressed);
            keyPressed=keyPressed(1);
        end
        if keyIsDown && (strcmp(keyPressed,blue) || strcmp(keyPressed,yellow))
            break;
        end
    end
    
    % One more flip is necessary to erase the dots,
    % e.g., after the button press.
    t_fr(n_fr + 1) = Screen('Flip', win);
    disp(t_fr(end) - t_fr(1)); % Should be ~2.5s on a 60Hz monitor.
    
    info{trial} = Dots.finish_trial;
    info{trial}.t_fr = t_fr;
    
    if isempty(keyPressed)
        keyPressed='x';
    end
    
    info{trial}.keypressed = keyPressed;
    if keyPressed ~= 'x'
        info{trial}.rt=firstPress(KbName(keyPressed))-t_fr(1);
    else
        info{trial}.rt=NaN;
    end
    info{trial}.disptime=t_fr(end) - t_fr(1);
    
    if color_coh > 0 && strcmp(keyPressed,blue)
        outcome = 1;
    elseif color_coh < 0 && strcmp(keyPressed,yellow)
        outcome = 1;
    elseif color_coh == 0
        outcome = 0.5;
    else
        outcome = 0;
    end
    
    info{trial}.outcome=outcome;
    outcomes(trial)=outcome;
    
    fprintf(fid1,'%s %d %s %s %d %f %f %f %s %d %f %f %d %d\n', subjid, scan, test_comp, exp_init, trial, t_fr(1)-runStart, color_coh, prop, keyPressed, outcome, info{trial}.disptime, info{trial}.rt, task_order, button_order);
    
    if keyPressed=='x'
        CenterText(win,'TOO SLOW!',white,0,0);
    else
        if outcome==0.5
            outcome=randsample([1 0],1);
        end
        if outcome==1
            CenterText(win,'CORRECT!',green,0,0);
        else
            CenterText(win,'INCORRECT',red,0,0);
        end
    end
    
    Screen('Flip', win);
    WaitSecs(.5);
    
    CenterText(win,'+',white,0,0);
    Screen('Flip', win);
    
    
    intertrial_interval = 1;
    WaitSecs(intertrial_interval);
    
    disp(info{trial});
    fprintf('\n\n');
    
end


save(['Output/' subjid '_dots_demo_' timestamp '.mat'],'Dots','info')

fclose(fid1);

CenterText(win,'Thank you! Great job!', white,0,-100);
%CenterText(win,'Please get the experimenter.', white,0,0);
Screen('Flip', win);
WaitSecs(5);

% Finishing up
ListenChar(0);
ShowCursor;
Screen('Close', win);
end