## The plugin, which runs at every source or login.

runall () {
## Pull in our pregame functions
source "${ZSH_PLUGINS}/induction/functions"
## Based on foundation settings, continue
[ $SSH_FOUNDATION ] && ssh_foundation
[ $GPG_FOUNDATION ] && gpg_foundation
## Do the main stuffs!
induction_run
}


ssh_foundation () {

  # The SSH Auth Section. Have fun!
  ## Some fun ssh auth socket stuff, pay attention noobcake

  ## First, we check if the agent is running. This covers a case where someone is in a gui like gnome where gnome[cinnamon]-keyring is already started and being used.
  # Obviously, we are assuming the user is utilizing this. If not, they must take it upon themselves to kill it and make sure it isn't used.
  # Note that the first time, you will get the gui prompt asking you to type the passphrase for the key. And you might have to hit the checkbox for it to save it.
if [ $using_agent ];
then
      # If our ssh_auth_sock is a dead link or doesn't exist, we need to make the symlink. This is similar to the .ssh/rc file...except that doesn't run on local terminals and if it did, only the _rem file would be made since it would    see ssh-agent running and assume we already registered ourselves etc.. Keep in mind that on systems where we handled the ssh-agent registration, this if statement will hit but the following won't because ssh_auth_sock should be pointing  to the correct socket already.
    if [[ ! -e $SSH_AUTH_SOCK_ROOT ]] ; then
        ln -sf $SSH_AUTH_SOCK $SSH_AUTH_SOCK_ROOT
        sock_problem="yes" ## indicating there might be a problem if you arent using a gui keyring interface...we warn the user later based on this
    fi
      ## using_agent="yes" ## just setting this for future stuffs
      ## Another note. The person logging into this "gui box" will also be using the gnome-keyring based session. keep that in mind. so if that password for the key hasn't been saved, that user will have problems getting into other boxes.  
fi
  #setting our actual variable to pnt to symlink which is what we maintain depending on socket we are using
  export SSH_AUTH_SOCK=$SSH_AUTH_SOCK_ROOT

}

gpg_foundation () {
    # Set our env variable
    export GPG_AGENT_INFO=$GPG_AGENT_INFO_ROOT
    # Check if we even have an agent running, and if not, we can remove the symlink since its dead anyway!
    if [ ! $using_gpg_agent ]; then
        rm -f $GPG_AGENT_INFO_ROOT
    fi
}


induction_run () {

# Introduction

  echo -en "\n ${txtyellow}*${reset} "; echo -en "${txtpurple}induction ${VER}${reset} ~ ${undliteblue}https://github.com/inanimate/induction${reset}"

  [ $GPG_FOUNDATION ] && gpg_check || echo -en "\n ${txtyellow}*${reset} ${bldred}GPG${reset} support is currently disabled!"
  ## Since we can still query SSH agent info without needing variables in their config, we continue with this but warn them in the function.
  ssh_check

}
#----
# GPG
gpg_check () {

echo -en "\n ${txtyellow}*${reset} "

if [ -z $GPG_AGENT_BINARY_EXIST ]; then
    echo -en "No ${bldred}gpg-agent${reset} binary found!"
else
    if [ $using_gpg_agent ];
    then
        echo -en "Found existing ${bldgreen}gpg-agent${reset}: ${txtcyan}${using_gpg_agent}${reset}"
    else
        echo -en "No running ${txtliteyellow}gpg-agent${reset}!"
        ## Since no agent is running, we can remove the GPG_KEY_LOADED_FILE since it obv doesnt apply to anything with no agent running
        rm -rf $GPG_KEY_LOADED_FILE
        ## Fun fact, we can also remove the pointer symlink!
        rm -rf $GPG_AGENT_INFO_ROOT
    fi
fi

if [ -e $GPG_KEY_LOADED_FILE ]; then
#      $(gpg --list-secret-keys 2>/dev/null | cut -d/ -f2 | cut -d' ' -f1 | xargs | awk -F " " '{print $3}')
  echo -en "\n   ${txtyellow}*${reset} Loaded gpg key: ${txtcyan}$(cat $GPG_KEY_LOADED_FILE)${reset}"
fi
}
#----
# SSH
ssh_check () {
[ $SSH_FOUNDATION ] || echo -en "\n ${txtyellow}*${reset} ${bldred}SSH${reset} support is currently disabled!"
echo -en "\n ${txtyellow}*${reset} "

if [ -z $SSH_AGENT_BINARY_EXIST ] ; then
    echo -en "No ${bldred}ssh-agent${reset} binary found!"
else

    if [ $using_agent ];
    then
        echo -en "Found existing ${bldgreen}ssh-agent${reset}: ${txtcyan}${using_agent}${reset}" 
    else
        echo -en "No running ${txtliteyellow}ssh-agent${reset}!"
    fi

    KEYLISTARRAY=("${(@f)$(ssh-add -L 2>&- | awk -F " " '{print $3}')}")
    if [ $? -eq 0 ]; then
        if [ ${KEYLISTARRAY[1]} ]; then
            # array is populated, keys are in fact loaded
            if [ $using_agent ];
            then
                ## If they utilize our ssh hax, we can use the symlinks to check if they are actually using the agent or not!
                # So we've covered the case where the agent is started but doesnt have any keys actually loaded into it, but we've got one forwarded
                if [ $SSH_FOUNDATION ];
                then
                    [ "$SSH_AUTH_SOCK_ROOT" -ef "$SSH_AUTH_SOCK_REM_ROOT" ] && echo -en "\n   ${txtyellow}*${reset} ${txtlitegrey}Forwarded${reset} ssh key(s):\n" || echo -en "\n   ${txtyellow}*${reset} Loaded ssh key(s):\n"
                else
                    ##just assume they are loaded and not forwarded
                    echo -en "\n   ${txtyellow}*${reset} Loaded ssh key(s):\n" 
                fi
            else
                echo -en "\n   ${txtyellow}*${reset} ${txtlitegray}Forwarded${reset} ssh key(s):\n"
            fi
            for ssh_key in ${KEYLISTARRAY[@]}; do
                  echo -en "     ${txtyellow}*${reset} ${txtcyan}$ssh_key${reset}\n"
            done
        fi
    fi
fi
}



if [ -e $HOME/.induction ]; then
    source $HOME/.induction
    [ $ALIASPLZ ] && alias $ALIASPLZ='$ZSH_PLUGINS/induction/induction'
    runall
    # Squeaky clean:)
    echo -en "\n"
else
    print -P "\e[1;31mNo config file available!! Please fix this or disable induction!\e[0m"
fi
