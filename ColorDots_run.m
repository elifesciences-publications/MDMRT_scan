function ColorDots_run(subjid,test_comp,exp_init,scan,run, task_order, button_order)
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

    if scan==1
        if button_order==1
            blue='b';
            yellow='y';
        else
            blue='b';
            yellow='y';
        end
    else
        if button_order==1
            blue='u';
            yellow='i';
        else
            blue='u';
            yellow='i';
        end
    end
    
    % You may want to change the following three parameters
    % with the ones measured from the experimental setup.        
    Dots = ColorDots( ...
        'scr', scr, ... 
        'win', win, ...
        'dist_cm', 55, ...
        'monitor_width_cm', 30);

    n_trial = 50;
    info = cell(1, n_trial);
    
    % I recommend the pool of color coherences in the code.
    % You might omit one of the zeros (i.e., leave only one zero)
    % - that would slightly reduce the power for reverse correlation
    % later.
    % You might also omit the -2 and 2, but that might reduce the
    % range of RTs.
    color_coh_pool = [-2, -1, -0.5, -0.25, -0.125, 0, 0, 0.125, 0.25, 0.5, 1, 2];
    n_fr = 150;
    
    KbQueueCreate;
    KbQueueStart;
    
    %INTRUCTIONS
    Screen('TextSize',win,40);
    CenterText(win,['Press `' blue '` for blue and `' yellow '` for yellow'],white,0,-100);
    CenterText(win,'Press any button to continue...',white,0,100);
    Screen('Flip',win);
    KbQueueWait;
    
    CenterText(win,'+',white,0,0);
    runStart=Screen('Flip',win);
    WaitSecs(1);
    
    fid1=fopen(['Output/' subjid '_dots_run_' num2str(run) '_' timestamp '.txt'], 'a');
    
    %write the header line
    fprintf(fid1,'subjid scanner test_comp experimenter run runtrial onsettime color_coh prop response outcome disptime RT task_order button_order\n');
        
    % Iterating trials
    for trial = 1:n_trial
        
        fprintf('-----\n');
        fprintf('Trial %d:\n', trial);
        
        t_fr = zeros(1, n_fr + 1);

        color_coh = randsample(color_coh_pool, 1);
        prop = invLogit(color_coh);

        % Dots.init_trial must be called before Dots.draw.
        Dots.init_trial(prop);
        KbQueueFlush;
        
        for fr = 1:n_fr
            % Since the dots should update every frame,
            % draw other components (e.g., fixation point)
            % before each flip, around Dots.draw.
            
            % Draw components here to have dots draw over them.
            
            Dots.draw;
            
            % Draw components here to draw over the dots.
            
            t_fr(fr) = Screen('Flip', win);
            [keyIsDown, firstPress] = KbQueueCheck;
            keyPressed=KbName(firstPress);
            if keyIsDown && ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed=char(keyPressed);
                keyPressed=keyPressed(1);
            end
            if keyIsDown && (keyPressed == blue || keyPressed == yellow)
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
        info{trial}.rt=firstPress(KbName(keyPressed))-t_fr(1);
        info{trial}.disptime=t_fr(end) - t_fr(1);
        
        if color_coh > 0 && keyPressed == blue
            outcome = 1;
        elseif color_coh < 0 && keyPressed == yellow
            outcome = 1;
        elseif color_coh == 0
            outcome = 0.5;
        else
            outcome = 0;
        end
        
        info{trial}.outcome=outcome;
        
        fprintf(fid1,'%s %d %s %s %d %d %f %f %f %s %d %f %f %d %d\n', subjid, scan, test_comp, exp_init, run, trial, t_fr(1)-runStart, color_coh, prop, keyPressed, outcome, info{trial}.disptime, info{trial}.rt, task_order, button_order);
        
        if outcome==0.5
            outcome=randsample([1 0],1);            
        end
        if outcome==1
            CenterText(win,'CORRECT!',green,0,0) 
        else
            CenterText(win,'INCORRECT',red,0,0)
        end
        
        Screen('Flip', win)
        WaitSecs(.5);
        
        CenterText(win,'+',white,0,0)
        Screen('Flip', win)
        
        intertrial_interval = 1;
        WaitSecs(intertrial_interval);
                
        disp(info{trial});
        fprintf('\n\n');
    end
    
    save(['Output/' subjid '_dots_run_' num2str(run) '_' timestamp '.mat'],'Dots','info')

    fclose(fid1);
    
    Screen('TextSize',w, betsz);
    CenterText(win,'Thank you!', green,0,-100);
    CenterText(win,'Take a short break before continuing...', white,0,0);
    Screen('Flip', w);
    WaitSecs(5);
    
    % Finishing up
    Screen('Close', win);
end