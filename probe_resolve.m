function probe_resolve(subjid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BDM Resolve

tmp=dir(['Output/' subjid '_food_BDM2.txt']);
fid=fopen(['Output/' tmp(length(tmp)).name]); %tmp(length(tmp)).name
probe=textscan(fid, '%s %d %s %f %d', 'Headerlines',1);
fclose(fid);
subset=ismember(probe{3},{'Cheezits.bmp','CheesyDoritos.bmp','Fritos.bmp','Ruffles.bmp','Oreos.bmp','PeanutMMs.bmp','Chocolate_mm.bmp','Twix.bmp','Snickers.bmp','FamousAmos_small.bmp','PopTartsStrawberry.bmp','FigNewton_small.bmp'});
pics=probe{3}(subset);
price=probe{4}(subset);
trial_choice=ceil(rand()*length(pics));
pic=pics(trial_choice);
bid=price(trial_choice);

counterbid=Shuffle([0.0 .25 .5 .75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3]);
counterbid=counterbid(1);

if bid>counterbid
    text1=strcat('You bid $', num2str(bid), ' on item ''', char(pic), '''. The computer counterbid $', num2str(counterbid), ', so you won the auction!');
    text2=strcat('You get to buy item ''', char(pic), ''' at the lower price of $', num2str(counterbid));
else
    text1=strcat('You bid $', num2str(bid), ' on item ''', char(pic), '''. The computer counterbid $', num2str(counterbid), ', so you lost the auction :(');
    text2=strcat('You cannot buy item ''', char(pic), ''' but you get to keep your full $3!');
end

fid=fopen(['Output/' subjid '_BDM_resolve.txt'],'a');
fprintf(fid,'%s \n \n %s \n \n', char(text1), char(text2));
fclose(fid);

clear text1;
clear text2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Food Choice Resolve

tmp=Shuffle(1:3);
run=tmp(1);

file=dir(['Output/' subjid '_food_choice_run_' num2str(run) '_*m.txt']);
fid=fopen(['Output/' file(length(file)).name]); %tmp(length(tmp)).name
probe=textscan(fid, '%s %d %d %s %s %d %d %d %d %s %s %d %s %d %d %f %d %d %f %f %f %f %f %d %d %d %c %f', 'Headerlines',1);
fclose(fid);

subset=ismember(probe{10},{'Cheezits.bmp','CheesyDoritos.bmp','Fritos.bmp','Ruffles.bmp','Oreos.bmp','PeanutMMs.bmp','Chocolate_mm.bmp','Twix.bmp','Snickers.bmp','FamousAmos_small.bmp','PopTartsStrawberry.bmp','FigNewton_small.bmp'})...
    & ismember(probe{11},{'Cheezits.bmp','CheesyDoritos.bmp','Fritos.bmp','Ruffles.bmp','Oreos.bmp','PeanutMMs.bmp','Chocolate_mm.bmp','Twix.bmp','Snickers.bmp','FamousAmos_small.bmp','PopTartsStrawberry.bmp','FigNewton_small.bmp'});
leftpics=probe{10}(subset);
rightpics=probe{11}(subset);
responses=probe{13}(subset);
validresponse=~strcmp(responses,'x');
leftpics=leftpics(validresponse);
rightpics=rightpics(validresponse);

trial_choice=ceil(rand()*length(leftpics));

leftpic=leftpics(trial_choice);
rightpic=rightpics(trial_choice);

response=responses(trial_choice);

text1=strcat('In the choice between item ''', leftpic, ''' and item ''', rightpic);
switch char(response)
    case 'u'
        text2=strcat('You chose item ''', leftpic, '''. You receive this item.');
    case '3#'
        text2=strcat('You chose item ''', leftpic, '''. You receive this item.');
    case 'i' 
        text2=strcat('You chose item ''', rightpic, '''. You receive this item.');
    case '4$'
        text2=strcat('You chose item ''', rightpic, '''. You receive this item.');
end

fid=fopen(['Output/' subjid '_food_choice_resolve.txt'],'a');
fprintf(fid,'%s \n \n %s \n \n', char(text1), char(text2));
fclose(fid);
end



