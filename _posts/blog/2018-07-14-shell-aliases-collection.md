---
layout:     post
title:      Get Productive with Shell Aliases
summary:    A collection of useful shell aliases, gathered over the years to help increase one's productivity and developer happiness.
tags:       [Blog]
---

Over the years, I have collected a number of shell aliases from various blog posts and websites that have tremendously helped me navigate and automate confusing workflows and remember complicated terminal commands. This post, for what it's worth, is about giving back to the developer community with me sharing aliases I find to be extremely useful in hopes that you, dear reader, also find them useable and productive.

There may be better options for housing such aliases, but for better or worse, all commands are to be put inside `~/.profile`, all of which have been exercised on **macOS**.

## Activate Profile

```bash
alias editp='edit ~/.profile'
alias actp='source ~/.profile'
```

## Change Directory

```bash
alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels
```

## Editors

```bash
alias edit="code" # Visual Studio Code
alias this="edit ."
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl $@"
alias this="edit ."
```

## Variables for Colorful Output

```bash
BOLD=$(tput bold)
BLACK=$(tput setaf 0)
WHITE=$(tput setaf 7)
BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
```

## Mastering the SSH Agent

```bash
export env=$HOME/.ssh/environment

function agent_is_running() {
  if [ "$SSH_AUTH_SOCK" ]; then
    # ssh-add returns:
    #   0 = agent running, has keys
    #   1 = agent running, no keys
    #   2 = agent not running
    ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
  else
    false
  fi
}

function agent_has_keys() {
  ssh-add -l >/dev/null 2>&1
}

function agent_load_env() {
  . "$env" >/dev/null
}

function agent_start() {
  echo "Starting SSH agent..."
  (umask 077; ssh-agent >"$env")
  . "$env" >/dev/null
}

function add_all_keys() {
  echo "Adding SSH keys..."
  ls ~/.ssh | grep ^id_rsa.*$ | sed "s:^:`echo ~`/.ssh/:" | xargs -n 1 ssh-add
}

if ! agent_is_running; then
  agent_load_env
fi

# if your keys are not stored in ~/.ssh/id_rsa.pub or ~/.ssh/id_dsa.pub, you'll need
# to paste the proper path after ssh-add
if ! agent_is_running; then
  agent_start
  add_all_keys
elif ! agent_has_keys; then
  add_all_keys
fi

echo `ssh-add -l | wc -l` SSH keys registered.

unset env
```

## Fancy Git Prompt

```bash
if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Default
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi
```

## Switch JDK Versions

```bash
function setjdk() {
  if [ $# -ne 0 ]; then
   removeFromPath '/System/Library/Frameworks/JavaVM.framework/Home/bin'
   if [ -n "${JAVA_HOME+x}" ]; then
    removeFromPath "$JAVA_HOME/bin"
   fi
   export JAVA_HOME=`/usr/libexec/java_home -v $@`
   export PATH=$JAVA_HOME/bin:$PATH
   echo -e "JAVA_HOME to $@"
  fi
}

function removeFromPath() {
  export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")
}
```

...where you can do:

```bash
setjdk 1.8
```

or:

```bash
setjdk 11
```

## Spawn Databases via Docker

```bash
function mysql() {
    docker run --name mysql -p3306:3306 --env="MYSQL_ROOT_PASSWORD=password" --env="MYSQL_DATABASE=test" -d mysql
}

function sqlserver() {
    docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=p@ssw0rd' -p 1433:1433 microsoft/mssql-server-linux:2017-CU7
}
```

## Gradle

### Dependency Insight

```bash
function gdep() {
  ./gradlew dependencyInsight --configuration "$2" --dependency "$1"
}
```

...where you can do:

```bash
gdep compileClasspath jackson
```

### Properties


```bash
alias gprop="edit ~/.gradle/gradle.properties"
```

## Helpers

```bash
alias openPorts='sudo lsof -i | grep LISTEN'

alias cls="clear"
alias del='rm'
alias path='echo -e ${PATH//:/\\n}'

alias hostfile="sudo atom /etc/hosts" # Requires Atom

function mcd() {
  mkdir -p "$1" && cd "$1";
}

alias dir="ls -a -l"
alias myip="curl ifconfig.co/json"
```

## Docker

### Search & Destroy

```bash
alias dkc="docker stop $(docker ps -aq); docker rm $(docker ps -aq)";
```

### SSH Into Container

```bash
function dockerssh() {
    export CID=$(docker ps -aqf "name=$1"); docker exec -it $CID /bin/bash
}
```

## Git

### Commit Changes

```bash
function gc() {
  echo -e "${GREEN}Commit message:\n${WHITE}\t$1\n${NORMAL}"

  echo "Adding all changes..."
  git add --all
  echo "Committing changes..."
  git commit -S -am "$1"

  echo "Fetching all submodules..."
  modules=($(git submodule | awk '{print $2}'))

  for module in "${modules[@]}"; do
    echo -e "\tSwitching to module ${WHITE}${module}${NORMAL}"
    pushd $module > /dev/null
    echo -e "\tFetching status for module ${WHITE}${module}${NORMAL}"
    modulestatus=$(git status --porcelain | wc -l)
    if [[ $modulestatus -ne 0 ]]; then
      echo -e "\t${GREEN}Updating module: ${WHITE}${module}${NORMAL}"

      echo -e "\tAdding changes for module ${WHITE}${module}${NORMAL}"
      git add --all
      echo -e "\tCommitting changes for module ${WHITE}${module}${NORMAL}"
      git commit -S -am "$1"
      git status --short
    else
      echo -e "\tNo changes found to commit for module ${WHITE}${module}${NORMAL}"
    fi
    popd > /dev/null
  done
  echo -e "${GREEN}Done!\nStatus:${NORMAL}"
  git status
}
```

### Misc

```bash
alias delmerged="git branch --merged | grep -v "\*" | grep -v master | grep -v dev | xargs -n 1 git branch -d"
alias gco="git checkout $1"
alias gbo="git checkout -b $1"
alias gp="git push --set-upstream $1 $2"
alias gl="git pull $1 $2"
alias grs="git reset --hard && git clean -fd"
alias gba="git branch -a"
alias gbr="git branch -r"
alias gs="git status -s -b"
alias gpl="git pull origin master --no-edit --allow-unrelated-histories"
alias gps="git push origin master --recurse-submodules=on-demand "
alias gst="git status"
alias ggc="git gc --aggressive --prune=now"
```

## Processes

```bash
function pidit() {
    ps -ef | grep "$@" | grep -v grep |  awk '{print $2}'
}

function proc() {
    ps -ef | grep "$@" | grep -v grep
}

function kp() {
    ps -ef | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill
}
```


## Search Aliases

```bash
function cm() {
    alias | grep "$@" | head -n 1
}
```

## Contribute to Apereo Blog

Once you have cloned the Apereo Blog repository:

```bash
alias blog="cd /path/to/apereo.github.io"
alias blogthis="blog; this"
```

That's it. I hope you find these useful.

[Misagh Moayyed](https://twitter.com/misagh84)
