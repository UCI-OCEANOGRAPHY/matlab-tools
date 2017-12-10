# matlab-tools

This repository is a collection of MATLAB utilities for oceanographic data collection, manuipulation, interpolation, and plotting

## How to's (work in progress)

### Create your local and remote repositories

There are 3 repositories you should care about:
   - Your local repo (on which you can create your own code).
   - Your `origin` remote, which you forked (or will fork) from the official repo.
   - The  official repo, [https://github.com/UCI-OCEANOGRAPHY/matlab-tools.git](https://github.com/UCI-OCEANOGRAPHY/matlab-tools.git), which is (or should be) set up as your `upstream` remote.
     This is the repo you can use for your projects.
     (You can either clone it or set it as a submodule or just directly download any files from it.)

Get yourself started in 3 steps:
1. Fork the [official repo](https://github.com/UCI-OCEANOGRAPHY/matlab-tools.git) by clicking on github's "fork" button.
   You now have your own `origin` remote on your github account.

2. Clone your newly created remote onto you local machine by typing
   ```
   git clone https://github.com/<username>/matlab-tools.git
   ```
   where `<username>` is your username.
   This is the repo where you can write your own code.

3. `cd` into your newly created local repo, and assign the upstream remote by typing
   ```
   git remote add upstream https://github.com/UCI-OCEANOGRAPHY/matlab-tools.git
   ```

### Update your repositories


You can now update your local repo by fetching the code from the official repo in 3 steps:

1. Make sure your `upstream` remote is defined as the official repo (step 3 in section above).
   You can type 
   ```
   git remote -v
   ```
   to check you remotes (make sure `upstream` appears in the output).

2. Fetch the `upstream` code by typing
   ```
   git fetch upstream
   ```
   which will create (update? - TBC) a branch called `upstream/master` on your local repo.
   The `upstream/master` is the same as the `master` branch of the official repo.

3. Checkout (i.e., go into) your `master` branch by typing
   ```
   git checkout master
   ```

4. Merge `upstream/master` into your `master` by typing
   ```
   git merge upstream/master
   ```

Your master branch should now be identical to the official repo.

### Contribute to the official repo

(to finish)
Make branches?




