function food_choice_setup(subjid)

outpath='Output/';

file=dir([outpath, subjid '_List_order.txt']); % This txt file is a 8 column file
fid=fopen([outpath, sprintf(file(length(file)).name)]);

%%%% Reading in sorted file
vars=textscan(fid, '%s%d%d%d%d%d%d%d%d%d%f') ;% these contain everything from the sortbdm

fclose(fid);

names=vars{1};      % col 1 contains food names
pair1=vars{2};      % col 2 contains pairs 1 - 30
pair2=vars{3};      % col 3 contains pairs 31 - 60
pair3=vars{4};      % col 4 contains pairs 61 - 90
pair4=vars{5};      % col 5 contains pairs 91 - 120
pair5=vars{6};      % col 6 contains pairs 121 - 150
pair6=vars{7};      % col 7 contains pairs 151 - 180
pair7=vars{8};      % col 8 contains pairs 181 - 210
bidIndex=vars{9};   % col 10 contains rank order number based on ranking from highest value (1) to lowest value (60), col 7, not needed is the alphabetical name index
bid=vars{11};       % col 11 contains the actual values (i.e. what the participant actually bid for the item during the auction

lefthigh=cell(1,1);
leftname=cell(1,1);
rightname=cell(1,1);
pairtype=cell(1,1);
leftbidIndex=cell(1,1);
rightbidIndex=cell(1,1);
leftbid=cell(1,1);
rightbid=cell(1,1);
shufflepairs= Shuffle(1:210);
pairtype{1}=shufflepairs(1:70);
pairtype{2}=shufflepairs(71:140);
pairtype{3}=shufflepairs(141:210);
for block=1:3
    
    lefthigh{block}= Shuffle([linspace(1,1,70) linspace(0,0,70)]); % I want exactly half of my trials have a high value item on the left, randomly assigned across all trials
    
    for i=1:70
        
        stims=names(pair1==pairtype{block}(i) | pair2==pairtype{block}(i) | ...
            pair3==pairtype{block}(i) | pair4==pairtype{block}(i) | ...
            pair5==pairtype{block}(i) | pair6==pairtype{block}(i) | ...
            pair7==pairtype{block}(i));         % find the names that match the pair number
        bidindices=bidIndex(pair1==pairtype{block}(i) | pair2==pairtype{block}(i) | ...
            pair3==pairtype{block}(i) | pair4==pairtype{block}(i) | ...
            pair5==pairtype{block}(i) | pair6==pairtype{block}(i) | ...
            pair7==pairtype{block}(i));  % find the bid indices that match the pair number
        bids=bid(pair1==pairtype{block}(i) | pair2==pairtype{block}(i) | ...
            pair3==pairtype{block}(i) | pair4==pairtype{block}(i) | ...
            pair5==pairtype{block}(i) | pair6==pairtype{block}(i) | ...
            pair7==pairtype{block}(i));            % find the bids for the 2 items in the pair
        
        if lefthigh{block}(i)==1;                   % assign left and right items, indices and bids
            leftname{block}(i)=stims(1);
            rightname{block}(i)=stims(2);
            leftbidIndex{block}(i)=bidindices(1);
            rightbidIndex{block}(i)=bidindices(2);
            leftbid{block}(i)=bids(1);
            rightbid{block}(i)=bids(2);
        else
            leftname{block}(i)=stims(2);
            rightname{block}(i)=stims(1);
            leftbidIndex{block}(i)=bidindices(2);
            rightbidIndex{block}(i)=bidindices(1);
            leftbid{block}(i)=bids(2);
            rightbid{block}(i)=bids(1);
        end
    end
end

save([outpath, subjid '_food_choice_setup.mat'],'names','stims','bidindices','bids', ...
    'lefthigh','leftname','rightname','leftbidIndex','rightbidIndex', ...
    'leftbid','rightbid','pairtype')

