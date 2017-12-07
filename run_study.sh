#!/bin/bash

#USAGE: run_study.sh

#if [ `whoami` != 'LearningLab1new' ]; then rsync -avx /Volumes/LearningLab1new/Desktop/CURRENT_EXP/Akram/Akram_Food_Task/ ~/Desktop/CURRENT_EXP/Akram/Akram_Food_Task/; fi

a=1
while [ $a -gt 0 ]
do
    read -p "Please enter subject ID (in the form MDMRT_000): " subjid
    echo ""
    echo "You entered Subject ID: ${subjid}"
    echo ""
    if [ "$subjid" != '' ]; then
	a=0
    fi

    if [ -e "Output/${subjid}_BDM1.txt" ]; then
	echo ""
	echo "**********************************"
	echo "WARNNG: subject $subjid already run! Please check subject ID and try again."
	echo "**********************************"
	echo ""
	break
    fi
done
echo""

a=1
while [ $a -gt 0 ]
do
    read -p "What computer are you using?: " test_rm
    if [ "$test_rm" != '' ]; then
	a=0
    fi
done
echo""

a=1
while [ $a -gt 0 ]
do
    read -p "Enter experimenter initials: " exp_init
    if [ "$exp_init" != '' ]; then
	a=0
    fi
done
echo""

a=1
while [ $a -gt 0 ]
do
    read -p "Are you using the eyetracker? (0 for NO, 1 for YES): " eye
    echo ""
    echo "You entered eyetracker value ${eye}. Must be 0 for NO or 1 for YES"
    echo ""
    if [ $eye == 0 ]; then
	a=0 
    elif [ $eye == 1 ]; then
	a=0
    else
	echo ""
	echo "******************************"
	echo "WARNING: eyetracker value must be 0 or 1, please try again"
	echo "******************************"
	echo ""
	crash
    fi
done

a=1
while [ $a -gt 0 ]
do
    read -p "Are you scanning? (0 for NO, 1 for YES): " scan
    echo ""
    echo "You entered scan value ${scan}. Must be 0 for NO or 1 for YES"
    echo ""
    if [ $scan == 0 ]; then
	a=0 
    elif [ $scan == 1 ]; then
	a=0
    else
	echo ""
	echo "******************************"
	echo "WARNING: scan value must be 0 or 1, please try again"
	echo "******************************"
	echo ""
	crash
    fi
done

a=1
while [ $a -gt 0 ]
do
    read -p "Enter the task order number (1 or 2): " task_order
    echo ""
    echo "You entered task order value ${task_order}. Must be 1 or 2."
    echo ""
    if [ $task_order == 1 ]; then
	a=0 
    elif [ $task_order == 2 ]; then
	a=0
    else
	echo ""
	echo "******************************"
	echo "WARNING: task order value must be 1 or 2, please try again"
	echo "******************************"
	echo ""
	crash
    fi
done

a=1
while [ $a -gt 0 ]
do
    read -p "Enter the button order number (1 or 2): " button_order
    echo ""
    echo "You entered button order value ${button_order}. Must be 1 or 2."
    echo ""
    if [ $button_order == 1 ]; then
	a=0 
    elif [ $button_order == 2 ]; then
	a=0
    else
	echo ""
	echo "******************************"
	echo "WARNING: button order value must be 1 or 2, please try again"
	echo "******************************"
	echo ""
	crash
    fi
done

a=1
while [ $a -gt 0 ]
do
    read -p "Is this the first (1) or second (2) visit?: " visit
    echo ""
    echo "You entered visit number value ${visit}. Must be 1 or 2."
    echo ""
    if [ $visit == 1 ]; then
	a=0 
    elif [ $visit == 2 ]; then
	a=0
    else
	echo ""
	echo "******************************"
	echo "WARNING: visit number value must be 1 or 2, please try again"
	echo "******************************"
	echo ""
	crash
    fi
done

if [ $visit == 1 ]; then

    a=1
    while [ $a -gt 0 ]; do
	read -p "Do you want to run the Dots task? (0 for NO, 1 for YES): " dots
	echo ""
	echo "You entered Dots task value ${dots}. Must be 0 for NO or 1 for YES"
	echo ""
	if [ $dots == 0 ]; then
	    a=0 
	elif [ $dots == 1 ]; then
	    a=0
	else
	    echo ""
	    echo "******************************"
	    echo "WARNING: dots task value must be 0 or 1, please try again"
	    echo "******************************"
	    echo ""
	fi
    done
    if [ $dots == 1 ]; then
	echo "******************************"
	echo run_visit1\(\'$subjid\',\'$test_rm\',\'$exp_init\',$eye,$scan,$task_order,$button_order\)
	echo "******************************"
	matlab -nodesktop -r "run_visit1('$subjid','$test_rm','$exp_init',$eye,$scan,$task_order,$button_order); quit"
	python2 object_rating_demo.py $subjid
	python2 object_rating.py $subjid
    else
	python2 object_rating_demo.py $subjid
	python2 object_rating.py $subjid
    fi
elif [ $visit == 2 ]; then
    a=1
    while [ $a -gt 0 ]; do
	read -p "Do you want to run the Auction? (0 for NO, 1 for YES): " bdm
	echo ""
	echo "You entered Auction task value ${bdm}. Must be 0 for NO or 1 for YES"
	echo ""
	if [ $bdm == 0 ]; then
	    a=0 
	elif [ $bdm == 1 ]; then
	    a=0
	else
	    echo ""
	    echo "******************************"
	    echo "WARNING: continue to choice tasks value must be 0 or 1, please try again"
	    echo "******************************"
	    echo ""
	fi
    done
    if [ $bdm == 1 ]; then
	python2 BDM_demo.py $subjid
	python2 BDM_food.py $subjid
	a=1
	while [ $a -gt 0 ]; do
	    read -p "Continue to choice tasks? (0 for NO, 1 for YES): " cont
	    echo ""
	    echo "You entered continue to task value ${cont}. Must be 0 for NO or 1 for YES"
	    echo ""
	    if [ $cont == 0 ]; then
		a=0 
	    elif [ $cont == 1 ]; then
		a=0
	    else
		echo ""
		echo "******************************"
		echo "WARNING: Continue to choice task value must be 0 or 1, please try again"
		echo "******************************"
		echo ""
	    fi
	done
	if [ $cont == 1 ]; then
	   echo "******************************"
	   echo run_visit2\(\'$subjid\',\'$test_rm\',\'$exp_init\',$eye,$scan,$task_order,$button_order\)
	   echo "******************************"
	 #  matlab -nodesktop -r "run_visit2('$subjid','$test_rm','$exp_init',$eye,$scan,$task_order,$button_order)"
	fi
    elif [ $bdm == 0 ]; then
	echo "******************************"
	echo run_visit2\(\'$subjid\',\'$test_rm\',\'$exp_init\',$eye,$scan,$task_order,$button_order\)
	echo "******************************"
	#matlab -nodesktop -r "run_visit2('$subjid','$test_rm','$exp_init',$eye,$scan,$task_order,$button_order)"
    fi
    a=1
    while [ $a -gt 0 ]; do
	read -p "Reveal Food Auction outcome? (0 for NO, 1 for YES): " cont
	if [ $cont == 0 ]; then
	    a=0 
	elif [ $cont == 1 ]; then
	    a=0
	else
	    echo ""
	    echo "******************************"
	    echo "WARNING: Auction outcome must be 0 or 1, please try again"
	    echo "******************************"
	    echo ""
	fi
    done
    if [ $cont == 1 ]; then
	echo ""
	echo "******************************"
	echo ""
	more Output/${subjid}_BDM_resolve.txt
	echo ""
	echo "******************************"
	echo ""
    fi

    a=1
    while [ $a -gt 0 ]; do
	read -p "Reveal Food Choice outcome? (0 for NO, 1 for YES): " cont
	if [ $cont == 0 ]; then
	    a=0 
	elif [ $cont == 1 ]; then
	    a=0
	else
	    echo ""
	    echo "******************************"
	    echo "WARNING:Food choice outcome must be 0 or 1, please try again"
	    echo "******************************"
	    echo ""
	fi
    done
    if [ $cont == 1 ]; then
	echo ""
	echo "******************************"
	echo ""
	more Output/${subjid}_food_choice_resolve.txt
	echo ""
	echo "******************************"
	echo ""
    fi    
    
fi

read -p "Enter your hypatia user: " hypatia_user
`ssh ${hypatia_user}@hypatia.psych.columbia.edu "if ! [ -d /data/akram/MDMRT_scan/${subjid}/behav ]; then mkdir -p /data/akram/MDMRT_scan/${subjid}/behav; fi"`
rsync Output/${subjid}* ${hypatia_user}@hypatia.psych.columbia.edu:/data/akram/MDMRT_scan/${subjid}/behav

