#### Enter induction...

> I am not much of a coder so please offer up enhancements and I will happily test and pull them in:)

![Induction gives your current state at every login or source of your .zshrc](img/img1.png?raw=true)


##### The Problem

Induction is a ssh and gpg-agent socket manager for registering ssh keys on a host and gpg keys for secure messaging.
This project is extremely similar to [keychain](http://www.github.com/funtoo/keychain), an excellent long-term project.
However, induction is meant to be an extensive zsh plugin that encourages simplicity and reliability of login sessions across servers.


##### What is solved

1. Unified socket pointers so virtual sessions never have issues
2. Ability to "register" keys on a host as needed
3. Less worry about stale agents or rouge configuration files
4. Vibrant interface for easy assessment of current state
5. A "set it and forget it" format utilizing a single config file


Overall, induction solves the problem of making sure you can get into your hosts by streamlining the entire login process for you.

**You will never have to:**

* Run ssh-agent or ssh-add manually, write another script to start them, or worry about 9001 agents lingering
* Deal with gpg directly to load your key or load your password in gpg-agent
* Worry about auth sock variables not being set on various shells (i.e. old tmux panes)
* Experience the pain of managing keys yourself, especially on older, uncontrolled systems

##### How it works

>__Here's the premise:__ We utilize a symlink as our main socket that all shells know about all the time.
>We then modify this symlink depending on the socket we want to use. For remote servers, we end up
>utilizing ssh-agent and loading our key there and then setting our shells to use it. If we end
>the ssh-agent process, we want the symlink to point to our current socket that was/is created 
>at our/every ssh login.

This is awesome because it enables us to leave scripts running that utilize authentication whilst not logged into the server! We also don't have to worry about those old panes we leave in our year old tmux session:P

For GPG specifically, we provide the interface for you to load your key, launch the agent, and enter your password so you can encrypt/decypt messages automatically.

From login to logout, you shouldn't have to worry about typing a password or being in the dark about whether a script will continue to run after you leave work.
Induction ensures that your experience is as hands off as possible whilst giving you the freedom to utilize a familiar realm across hosts you may not have administrative privileges on.


##### What you need

1. A linux box with zsh installed. Oh-my-zsh is almost necessary, but not exactly (more on this later)
2. A home directory with obvious write perms.
3. For ssh, `ssh-agent` provided by `ssh` on most distros, for gpg, `gpg-agent` provided by `gnupg-agent` on ubuntu/debian

##### Installation and Usage

1. Clone into your `oh-my-zsh` plugins directory
2. Copy `sshrc` to `~/.ssh/rc`
3. Move config.example to `~/.induction` and take a gander at the options, explained below
4. Enable the plugin in your `.zshrc` file
4. Make an alias to call induction if you'd like i.e. `alias register='$ZSH/plugins/induction/induction'`

**Usage**

To get an assessment, just source your .zshrc and you'll see the Plugin component list out the current state of your agents.
To register a key via an interactive menu, launch induction via an alias you set or calling it directly: `induction [kill | ?/-h/help]`

##### The Pieces

**Plugin**

The plugin runs at every sourcing of your .zshrc file. This checks the current state of the system in regards to loaded keys for both ssh and gpg-agent's. 
It gives you a pretty listing including:

* PID's for each agent
* Loaded keys
* Forwarded keys
* Missing binaries (gpg/ssh-agent binaries non-existent)

The Plugin does nothing in terms of loading a keyfile or changing a configuration. It does ensure any symlinks are updated and all necessary auth sock variables are set correctly.
It also does some checking to ensure the environment is stable.

![](img/img2.png?raw=true)
![No binary found](img/img3.png?raw=true)
![User has disabled gpg support in .induction config file](img/img4.png?raw=true)

**Induction**

Induction is the script itself, which does the grunt work of interactively allowing the user to load keys into the necessary agent.
You invoke induction, choose the agent you want to work with, pick the keyfile to load, and enter your password. Thats it! Induction takes care of the rest:)


**RC**

The `.ssh/rc` file is run at every login via a ssh connection. Its main purpose it to update symlink pointers with the latest agent path created at login.

##### Differences from funtoo/keychain

Although very similar to keychain, induction aims for more of a straight through approach whilst trying to give the user flexibility in a "ready when you are" fashion.

Some of the core *differences* from keychain:

1. A single configuration file, instead of command line options
2. ZSH written and compatible with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
3. Modular and easy to understand, encouraging hackers
4. Doesn't install like a software package, but can merely live in your dotfiles :)

Other than the above, induction does a lot of things similar to keychain. 

##### Restrictions

Most of these exist because I haven't included support for them yet. As I get to them, the list will become smaller.

1. Only one SSH or GPG secret key can be loaded at a time
2. There are no options for length of key store time
3. There is no logging of any kind, although this is not too important
4. Only on ZSH, would like to make bash compatible as well (it probably mostly is, just needs some tuning)

##### Roadmap

*1.0*
* better coloring and interactive prompts for core induction
* optional alias setup to call induction
* detection of GPG v1 or v2 and different behavior depending (deal with symlink issues)
* better detection of multiple gpg/ssh-agent processes 
* more documentation

*1.5*
* ability to load multiple keys in both ssh and gpg-agent
* define the length of time to hold your private key in said agent
* possibly add a logfile
* Make bash compatible
* testing and instructions on how to use without oh-my-zsh

##### More on this

*Blog post soon to come..*
