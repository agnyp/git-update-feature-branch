git-update-feature-branch
=========================
What's this about
-------------------------

Developing feature-branches with git is something I came to like a lot. 
With "feature-branch" I mean a branch which is being squashed into a single (or maybe more) commits after 
finishing, and rebased back onto master. 
During development I would keep my branch up-to-date with master, also using rebasing. 

You can also develop a feature-branch in collaboration, but this can get quite tricky, if you want to always use 
rebasing and keep up-to-date with the master branch.

This script is supposed to minimize the work with the updating tasks, and automatically and robustly rebase your 
feature-branch.


### What are the advantages of feature branches?
... to be explained.

### How does this work?
... to be explained.


Installation / Use
-------------------------
All you have to do is to place the script into your PATH. 

#### You can use the script either way:

    git-update-feature-branch
or

    git update-feature-branch

#### Show a description:

    git update-feature-branch -h
    git update-feature-branch
or

    git-update-feature-branch
    git-update-feature-branch --help
    git-update-feature-branch -h


#### General use:

    git update-feature-branch <branch> [remote-branch]
    
The [remote-branch] will be using "origin/" as a prefix. Later versions will also let you 
choose the remote-repository's name.

\<branch\> is your local feature-branch, while the [remote-branch] is that of your collaborator resp. 
the "communal"-feature-branch.

-> After you've run the script, you will need to forcefully push your \<branch\> to [remote-branch]. 
__This is something I am working on, since it's obviously not the best solution.__

