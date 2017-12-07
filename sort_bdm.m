function sort_bdm(subjid)

path='Output';

file=dir([path '/' subjid '_food_BDM2.txt']);                       %determine BDM output file for subject subjid

fid=fopen([path '/' sprintf(file(length(file)).name)]);     %if multiple BDM files, open the last one
C=textscan(fid, '%s%d%s%f%d' , 'HeaderLines', 1);     %read in BDM output file into C
fclose(fid);

[names_sort,names_sort_ind]=sort(C{3}); %sorting by item name
sorted_bids=C{4}(names_sort_ind); %sorting the bids based on bid

M(:,1)=sorted_bids; %bids of items sorted alphabetically 
M(:,2)=1:60; %index sort by bid so I can sort images later

sortedM=sortrows(M,-1);      %Sort descending indices by bid - sorts also the present_ind_sort (order of presentation index from BDM) and the item index

sortedlist(1:60,1)=cell(1);

for i=1:60
    sortedlist(i,1)=names_sort(sortedM(i,2)); %creates the name list based on the sorted list of bids
end

	
%%% add in the pairs
sortedM(:,3)=[1     2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30];
sortedM(:,4)=[31	32	33	34	35	36	37	38	39	40	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	51	52	53	54	55	56	57	58	59	60];
sortedM(:,5)=[61	62	63	61	62	63	64	65	66	64	65	66	67	68	69	67	68	69	70	71	72	70	71	72	73	74	75	73	74	75	76	77	78	76	77	78	79	80	81	79	80	81	82	83	84	82	83	84	85	86	87	85	86	87	88	89	90	88	89	90];
sortedM(:,6)=[91	91	92	92	93	93	94	94	95	95	96	96	97	97	98	98	99	99	100	100	101	101	102	102	103	103	104	104	105	105	106	106	107	107	108	108	109	109	110	110	111	111	112	112	113	113	114	114	115	115	116	116	117	117	118	118	119	119	120	120];
sortedM(:,7)=[121	122	123	121	122	123	124	125	126	124	125	126	127	128	129	127	128	129	130	131	132	130	131	132	133	134	135	133	134	135	136	137	138	136	137	138	139	140	141	139	140	141	142	143	144	142	143	144	145	146	147	145	146	147	148	149	150	148	149	150];
sortedM(:,8)=[151	152	151	152	153	154	153	154	155	156	155	156	157	158	157	158	159	160	159	160	161	162	161	162	163	164	163	164	165	166	165	166	167	168	167	168	169	170	169	170	171	172	171	172	173	174	173	174	175	176	175	176	177	178	177	178	179	180	179	180];
sortedM(:,9)=[181	181	182	182	183	183	184	184	185	185	186	186	187	187	188	188	189	189	190	190	191	191	192	192	193	193	194	194	195	195	196	196	197	197	198	198	199	199	200	200	201	201	202	202	203	203	204	204	205	205	206	206	207	207	208	208	209	209	210	210];

fid=fopen([path '/' subjid '_List_order.txt'], 'w');    

for i=1:length(M)
             %write out the full list with the bids and also which item will be a stop item
    fprintf(fid, '%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', sortedlist{i,1},sortedM(i,3),sortedM(i,4),sortedM(i,5),sortedM(i,6),sortedM(i,7),sortedM(i,8),sortedM(i,9),i,sortedM(i,2),sortedM(i,1)); %  item names ; S/NS GO/NGO ; item_indeex_bid ; item index name ; bid
end
fprintf(fid, '\n');
fclose(fid);

