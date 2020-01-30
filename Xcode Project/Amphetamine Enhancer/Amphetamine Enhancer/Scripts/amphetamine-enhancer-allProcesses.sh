#!/usr/bin/env bash

 {
 
    amphProcess="Amphetamine"

    # IF AMPHETAMINE IS RUNNING
    if pgrep -x $amphProcess; then
    
        # GET ALL PROCESSES RUNNING ON THIS MAC
        process_list=$(ps ax -c | awk -v p='COMMAND' 'NR==1 {n=index($0, p); next} {print substr($0, n)}');
	
        # IF THE DESTINATION FOLDER WHERE THE OUTPUT FILE SHOULD BE WRITTEN DOES NOT EXIST, CREATE IT
        if [ ! -d ~/Library/Containers/com.if.Amphetamine/Data/Library/Application\ Support/Amphetamine/Processes ]; then
        
            mkdir -p ~/Library/Containers/com.if.Amphetamine/Data/Library/Application\ Support/Amphetamine/Processes;
            
        fi

        # WRITE OUTPUT OF GET ALL PROCESSES COMMAND TO FILE
        echo -e "$process_list" > ~/Library/Containers/com.if.Amphetamine/Data/Library/Application\ Support/Amphetamine/Processes/ProcessList.txt;
 
        # CREATE OR REMOVE A SECONDARY FILE THAT WILL TRIGGER AMPHETAMINE TO PICK UP CHANGES TO THE PROCESSLIST.TXT FILE
        # AMPHETAMINE DOES NOT ALWAYS PICK UP FILE CONTENT CHANGES, BUT DOES PICK UP ON FILE CREATE/DELETE RELIABLY
        # THIS IS WHY IT IS NECESSARY TO CREATE OR DELETE THE SECONDARY FILE
        if [ -f ~/Library/Containers/com.if.Amphetamine/Data/Library/Application\ Support/Amphetamine/Processes/Processes.amphetamine ]; then
        
            rm ~/Library/Containers/com.if.Amphetamine/Data/Library/Application\ Support/Amphetamine/Processes/Processes.amphetamine;
        else
        
            touch ~/Library/Containers/com.if.Amphetamine/Data/Library/Application\ Support/Amphetamine/Processes/Processes.amphetamine;
            
        fi
    
    fi

 } &> /dev/null
