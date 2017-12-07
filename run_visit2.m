function run_visit2(subjid,test_comp,exp_init,eye,scan,task_order,button_order)

if ~exist(['Output/',subjid,'_food_setup.mat'],'file')
    sort_bdm(subjid);
    food_choice_setup(subjid);
end
subkbid=getKeyboards;
triggerkbid=input('Which device index do you want to use for the trigger?: ');
expkbid=input('Which device index do you want to use for the experimenter?: ');

 if task_order==1
     input('Continue to FoodChoice demo?: ');
     food_choice_demo(subjid,test_comp,exp_init,scan,task_order,subkbid);
     input('Continue to ColorDots demo?: ');
     ColorDots_demo(subjid,test_comp,exp_init,scan,task_order, button_order,subkbid);
     input('Continue to FoodChoice run 1?: ');
     food_choice(subjid,test_comp,exp_init,eye,scan,1,task_order,subkbid,expkbid,triggerkbid);
     input('Continue to ColorDots run 1?: ');
     ColorDots_scan(subjid,test_comp,exp_init,eye,scan,1,task_order,button_order,subkbid,expkbid,triggerkbid);
     input('Continue to FoodChoice run 2?: ');
     food_choice(subjid,test_comp,exp_init,eye,scan,2,task_order,subkbid,expkbid,triggerkbid);
     input('Continue to ColorDots run 2?: ');
     ColorDots_scan(subjid,test_comp,exp_init,eye,scan,2,task_order,button_order,subkbid,expkbid,triggerkbid);
     input('Continue to FoodChoice run 3?: ');
     food_choice(subjid,test_comp,exp_init,eye,scan,3,task_order,subkbid,expkbid,triggerkbid);
     input('Continue to ColorDots run 3?: ');
     ColorDots_scan(subjid,test_comp,exp_init,eye,scan,3,task_order,button_order,subkbid,expkbid,triggerkbid);
 elseif task_order==2
     input('Continue to ColorDots demo?: ');
     ColorDots_demo(subjid,test_comp,exp_init,scan,task_order, button_order,subkbid)
     input('Continue to FoodChoice demo?: ');
     food_choice_demo(subjid,test_comp,exp_init,scan,task_order,subkbid)
     input('Continue to ColorDots run 1?: ');
     ColorDots_scan(subjid,test_comp,exp_init,eye,scan,1,task_order,button_order,subkbid,expkbid,triggerkbid);
     input('Continue to FoodChoice run 1?: ');
     food_choice(subjid,test_comp,exp_init,eye,scan,1,task_order,subkbid,expkbid,triggerkbid);
     input('Continue to ColorDots run 2?: ');
     ColorDots_scan(subjid,test_comp,exp_init,eye,scan,2,task_order,button_order,subkbid,expkbid,triggerkbid);
     input('Continue to FoodChoice run 2?: ');
     food_choice(subjid,test_comp,exp_init,eye,scan,2,task_order,subkbid,expkbid,triggerkbid);
     input('Continue to ColorDots run 3?: ');
     ColorDots_scan(subjid,test_comp,exp_init,eye,scan,3,task_order,button_order,subkbid,expkbid,triggerkbid);
     input('Continue to FoodChoice run 3?: ');
     food_choice(subjid,test_comp,exp_init,eye,scan,3,task_order,subkbid,expkbid,triggerkbid);
 end
input('Continue to MemoryTest demo?: ');
object_memory_test_demo(subjid,test_comp,exp_init,scan,task_order,subkbid);
input('Continue to MemoryTest run 1?: ');
object_memory_test(subjid,test_comp,exp_init,eye,scan,1,task_order,subkbid,expkbid,triggerkbid);
input('Continue to MemoryTest run 2?: ');
object_memory_test(subjid,test_comp,exp_init,eye,scan,2,task_order,subkbid,expkbid,triggerkbid);
input('Continue to MemoryTest run 3?: ');
object_memory_test(subjid,test_comp,exp_init,eye,scan,3,task_order,subkbid,expkbid,triggerkbid);
input('Continue to MemoryTest run 4?: ');
object_memory_test(subjid,test_comp,exp_init,eye,scan,4,task_order,subkbid,expkbid,triggerkbid);
input('Resolve choice?: ');
probe_resolve(subjid);
sca;
quit;