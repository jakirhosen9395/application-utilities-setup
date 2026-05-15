# GitHub Setup and Git Workflow on Linux

This document explains how to install Git on Linux, configure Git, connect GitHub using SSH, clone a remote repository, create a new repository, upload local code to GitHub, work with branches, push code to a remote branch, pull updates, and manage merge conflicts.

GitHub Account: `https://github.com/jakirhosen9395`  
Recommended OS: Ubuntu / Debian-based Linux  
Example GitHub Username: `jakirhosen9395`

---

## Table of Contents

1. [Install Git on Linux](#1-install-git-on-linux)
2. [Configure Git User Information](#2-configure-git-user-information)
3. [Generate SSH Key for GitHub](#3-generate-ssh-key-for-github)
4. [Add SSH Key to GitHub](#4-add-ssh-key-to-github)
5. [Test GitHub SSH Connection](#5-test-github-ssh-connection)
6. [Clone a Remote Repository](#6-clone-a-remote-repository)
7. [Create a New Repository and Upload Local Code](#7-create-a-new-repository-and-upload-local-code)
8. [Basic Git Workflow](#8-basic-git-workflow)
9. [Create and Work on a New Branch](#9-create-and-work-on-a-new-branch)
10. [Push a Branch to Remote GitHub Repository](#10-push-a-branch-to-remote-github-repository)
11. [Merge One Branch into Another Branch](#11-merge-one-branch-into-another-branch)
12. [Pull Latest Code from Remote Repository](#12-pull-latest-code-from-remote-repository)
13. [Manage Merge Conflicts](#13-manage-merge-conflicts)
14. [Useful Git Commands](#14-useful-git-commands)
15. [Troubleshooting](#15-troubleshooting)
16. [Security Notes](#16-security-notes)

---

## 1. Install Git on Linux

For Ubuntu or Debian-based Linux systems, run:

```bash
sudo apt update
sudo apt install -y git openssh-client
```

Verify Git installation:

```bash
git --version
```

Verify SSH installation:

```bash
ssh -V
```

---

## 2. Configure Git User Information

Set your Git username and email address.

```bash
git config --global user.name "Md Jakir Hosen"
git config --global user.email "jakirhosen9395@gmail.com"
git config --global init.defaultBranch main
```

Check your Git configuration:

```bash
git config --global --list
```

Expected output should include:

```text
user.name=Md Jakir Hosen
user.email=jakirhosen9395@gmail.com
init.defaultbranch=main
```

---

## 3. Generate SSH Key for GitHub

SSH key authentication allows you to connect your Linux machine with GitHub securely.

Generate an ED25519 SSH key:

```bash
ssh-keygen -t ed25519 -C "jakirhosen9395@gmail.com"
```

When asked for the file location, press `Enter` to use the default path:

```text
/home/your-user/.ssh/id_ed25519
```

When asked for a passphrase, you can either:

- Press `Enter` to skip it
- Or enter a secure passphrase for better security

This creates two files:

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

Important:

- `id_ed25519` is your private key. Never share it.
- `id_ed25519.pub` is your public key. This is safe to add to GitHub.

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add your SSH private key to the SSH agent:

```bash
ssh-add ~/.ssh/id_ed25519
```

---

## 4. Add SSH Key to GitHub

Print your public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the full output. It will start with something like:

```text
ssh-ed25519 AAAA...
```

Now add it to GitHub:

1. Go to GitHub
2. Click your profile picture
3. Go to **Settings**
4. Go to **SSH and GPG keys**
5. Click **New SSH key**
6. Add a title, for example:

```text
Ubuntu Linux SSH Key
```

7. Paste the copied public key
8. Click **Add SSH key**

---

## 5. Test GitHub SSH Connection

Run:

```bash
ssh -T git@github.com
```

The first time, GitHub may ask:

```text
Are you sure you want to continue connecting?
```

Type:

```text
yes
```

If everything is correct, you should see:

```text
Hi jakirhosen9395! You've successfully authenticated, but GitHub does not provide shell access.
```

This means your Linux machine is successfully connected to GitHub using SSH.

---

## 6. Clone a Remote Repository

To copy an existing GitHub repository into your Linux machine, use:

```bash
git clone git@github.com:USERNAME/REPOSITORY_NAME.git
```

Example:

```bash
git clone git@github.com:jakirhosen9395/my-project.git
```

Go inside the project folder:

```bash
cd my-project
```

Check the remote repository URL:

```bash
git remote -v
```

Expected SSH remote format:

```text
origin  git@github.com:jakirhosen9395/my-project.git (fetch)
origin  git@github.com:jakirhosen9395/my-project.git (push)
```

---

## 7. Create a New Repository and Upload Local Code

Use this process when you already have code on your Linux machine and want to upload it to a new GitHub repository.

### Step 1: Create a New Repository on GitHub

1. Go to GitHub
2. Click **New repository**
3. Enter a repository name, for example:

```text
my-new-project
```

4. Choose Public or Private
5. Do not initialize with README if your local project already has files
6. Click **Create repository**

---

### Step 2: Initialize Git in Your Local Project

Go to your project folder:

```bash
cd /path/to/your/project
```

Initialize Git:

```bash
git init
```

Set the branch name to `main`:

```bash
git branch -M main
```

---

### Step 3: Add Files and Commit

Check current file status:

```bash
git status
```

Add all files:

```bash
git add .
```

Create your first commit:

```bash
git commit -m "Initial commit"
```

---

### Step 4: Connect Local Project with GitHub Remote Repository

Use your repository SSH URL:

```bash
git remote add origin git@github.com:jakirhosen9395/my-new-project.git
```

Verify remote:

```bash
git remote -v
```

---

### Step 5: Push Local Code to GitHub

Push your code to GitHub:

```bash
git push -u origin main
```

After this, your local code will be uploaded to the GitHub repository.

---

## 8. Basic Git Workflow

Use these commands during normal development.

Check file changes:

```bash
git status
```

Add all changed files:

```bash
git add .
```

Commit changes:

```bash
git commit -m "Write a meaningful commit message"
```

Push changes to GitHub:

```bash
git push
```

Example:

```bash
git add .
git commit -m "Update project documentation"
git push
```

---

## 9. Create and Work on a New Branch

Branches are used to develop new features without directly changing the main branch.

Check current branch:

```bash
git branch
```

Create a new branch:

```bash
git branch feature-login
```

Switch to the new branch:

```bash
git checkout feature-login
```

Or create and switch in one command:

```bash
git checkout -b feature-login
```

Now make your code changes.

After making changes:

```bash
git status
git add .
git commit -m "Add login feature"
```

---

## 10. Push a Branch to Remote GitHub Repository

To push your local branch to GitHub:

```bash
git push -u origin feature-login
```

After the first push, you can simply use:

```bash
git push
```

To see all branches:

```bash
git branch
```

To see local and remote branches:

```bash
git branch -a
```

---

## 11. Merge One Branch into Another Branch

Example: You worked on `feature-login` and now want to merge it into `main`.

First, switch to the target branch:

```bash
git checkout main
```

Pull the latest code:

```bash
git pull origin main
```

Merge the feature branch into `main`:

```bash
git merge feature-login
```

Push the updated `main` branch to GitHub:

```bash
git push origin main
```

---

### Example: Send Code from One Branch to Another Branch

If you want to send code from `development` branch to `main` branch:

```bash
git checkout main
git pull origin main
git merge development
git push origin main
```

If you want to send code from `main` branch to `staging` branch:

```bash
git checkout staging
git pull origin staging
git merge main
git push origin staging
```

---

## 12. Pull Latest Code from Remote Repository

Before starting work, always pull the latest code.

Pull latest code from the current branch:

```bash
git pull
```

Pull latest code from a specific remote branch:

```bash
git pull origin main
```

Example:

```bash
git checkout main
git pull origin main
```

This keeps your local branch updated with the remote GitHub repository.

---

## 13. Manage Merge Conflicts

Merge conflicts happen when two branches change the same lines in the same file.

Example conflict workflow:

```bash
git checkout main
git pull origin main
git merge feature-login
```

If there is a conflict, Git will show files with conflicts.

Check conflict status:

```bash
git status
```

Open the conflicted file. You may see something like this:

```text
<<<<<<< HEAD
Code from current branch
=======
Code from incoming branch
>>>>>>> feature-login
```

You must manually edit the file and keep the correct code.

After fixing the conflict, add the fixed file:

```bash
git add conflicted-file-name
```

Then complete the merge commit:

```bash
git commit -m "Resolve merge conflict"
```

Push the resolved code:

```bash
git push origin main
```

---

### Abort a Merge Conflict

If you do not want to continue the merge, run:

```bash
git merge --abort
```

This returns your branch to the state before the merge started.

---

## 14. Useful Git Commands

Check repository status:

```bash
git status
```

Show commit history:

```bash
git log --oneline
```

Show commit history with branch graph:

```bash
git log --oneline --graph --decorate --all
```

Check remote URL:

```bash
git remote -v
```

Change remote URL to SSH:

```bash
git remote set-url origin git@github.com:jakirhosen9395/REPOSITORY_NAME.git
```

Fetch latest remote branch information:

```bash
git fetch origin
```

Delete a local branch:

```bash
git branch -d branch-name
```

Force delete a local branch:

```bash
git branch -D branch-name
```

Delete a remote branch:

```bash
git push origin --delete branch-name
```

Rename current branch:

```bash
git branch -M new-branch-name
```

---

## 15. Troubleshooting

### Problem: Permission denied publickey

Error example:

```text
Permission denied (publickey).
```

Check if SSH key is loaded:

```bash
ssh-add -l
```

If no key is listed, add it again:

```bash
ssh-add ~/.ssh/id_ed25519
```

Test GitHub SSH connection again:

```bash
ssh -T git@github.com
```

---

### Problem: Remote URL Uses HTTPS Instead of SSH

Check remote:

```bash
git remote -v
```

If you see HTTPS like this:

```text
https://github.com/username/repository.git
```

Change it to SSH:

```bash
git remote set-url origin git@github.com:jakirhosen9395/REPOSITORY_NAME.git
```

Verify:

```bash
git remote -v
```

---

### Problem: Nothing to Commit

If Git says:

```text
nothing to commit, working tree clean
```

It means there are no new changes to commit.

Check status:

```bash
git status
```

---

### Problem: Push Rejected

If your push is rejected, your local branch may be behind the remote branch.

Run:

```bash
git pull origin main
```

Fix conflicts if needed, then push again:

```bash
git push origin main
```

---

## 16. Security Notes

- Never share your private SSH key.
- Never upload `~/.ssh/id_ed25519` to GitHub.
- Only upload the public key: `~/.ssh/id_ed25519.pub`.
- Use SSH URLs for easier and secure GitHub authentication.
- Use meaningful commit messages.
- Always pull the latest code before starting new work.
- Avoid force push unless you fully understand the impact.

---

## Complete Example Workflow

This is a common full workflow for a new project:

```bash
cd /path/to/project

git init
git branch -M main

git add .
git commit -m "Initial commit"

git remote add origin git@github.com:jakirhosen9395/my-project.git
git push -u origin main
```

Create a new feature branch:

```bash
git checkout -b feature-update
```

Make changes, then commit:

```bash
git add .
git commit -m "Add feature update"
```

Push branch to GitHub:

```bash
git push -u origin feature-update
```

Merge feature branch into main:

```bash
git checkout main
git pull origin main
git merge feature-update
git push origin main
```

---

## Done

Git is installed, GitHub SSH authentication is configured, and the complete Git workflow is ready for use.