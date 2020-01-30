#!/usr/bin/env bash

{

    # AMPHETAMINE WRITES THIS VALUE AS YES IF CDM IS ENABLED
    # IF AMPHETAMINE EXITED WITHOUT DISABLING CDM, THE VALUE WILL
    # REMAIN YES.
    cdmEnabled=$(defaults read com.if.Amphetamine cdmEnabled);
    
    if [ "$cdmEnabled" = 1 ]; then
        
        # ASSIGN VALUES
        amphProcess="Amphetamine"
        allowSleep=false;
        clamshellClosed=false;
        
        # IF AMPHETAMINE IS NOT RUNNING
        # THEN SLEEP SHOULD BE ALLOWED
        if ! pgrep -x $amphProcess; then
        
            allowSleep=true;
        
        fi

        # IF AMPHETAMINE IS RUNNING, ALLOWSLEEP WILL STILL BE FALSE
        # NOW WE NEED TO CHECK IF THERE ARE ACTIVE ASSERTIONS
        if [ "$allowSleep" = false ]; then
        
            # IF THERE ARE POWER ASSERTIONS APPLIED BY AMPHETAMINE
            # THEN WE SHOULD NOT DO ANYTHING AS THE USER CAN DISABLE
            # CLOSED-DISPLAY MODE VIA AMPHETAMINE
         
            # IF NO POWER ASSERTIONS ARE FOUND, HOWEVER, SLEEP SHOULD BE ALLOWED
            if ! pmset -g assertions | grep "Amphetamine" ; then
                    
                allowSleep=true;
                
            fi
            
        fi
    
        # IF SLEEP SHOULD BE ALLOWED
        if [ "$allowSleep" = true ] ; then
            
            # LAUNCH APP THAT DISABLES CLOSED-DISPLAY MODE OVERRIDE
            open /Applications/Amphetamine\ Enhancer.app/Contents/Resources/CDMManager/CDMManager.app
            
            # WRITE FALSE TO AMPHETAMINE'S PLIST SO THIS SCRIPT WILL NOT RUN
            # UNTIL AMPHETAMINE STARTS BLOCKING CLOSED-DISPLAY SLEEP AGAIN
            defaults write com.if.Amphetamine cdmEnabled -bool false;
            
        fi
        
    fi
    
} &> /dev/null
