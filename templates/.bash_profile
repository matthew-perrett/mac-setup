
. ~/.profile

SOURCE=~/Source
alias Source="cd $SOURCE"

########    TMUX    ########
alias mux=tmuxinator
alias mux.cost.dev='mux cost-dev'
alias mux.env.deploy='mux env-deploy'
alias mux.env.logs='mux env-logs'

########    GENERAL    ########
alias ls='ls -alst'
alias reload='$SOURCE/mac-setup/install-templates && . ~/.bash_profile'
alias ssh='sshrc'

########    JAVA    ########
export JAVA8_HOME=`/usr/libexec/java_home -v 1.8`
export JAVA8_OPTS="-Xmx3G -Xms3G -Duser.timezone=GMT"
alias java8="export JAVA_HOME=\"${JAVA8_HOME}\"; export MAVEN_OPTS=\"${JAVA8_OPTS}\"; echo '*** Java 1.8 enabled ***'"

export JAVA11_HOME=`/usr/libexec/java_home -v 11`
export JAVA11_OPTS="-Xmx3G -Xms3G -Duser.timezone=GMT"
alias java11="export JAVA_HOME=\"${JAVA11_HOME}\"; export MAVEN_OPTS=\"${JAVA11_OPTS}\"; echo '*** Java 11 enabled ***'"

########    DOCKER    ########
alias docker.remove.dangling='docker rmi $(docker images -qa -f "dangling=true")'

########    GIT    ########
alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias stash='git stash'
alias pop='git stash pop'
alias spp='stash && git pull && pop'

alias git.branch.name='git branch | grep \* | cut -d " " -f2'
alias git.push='git push -u origin `git.branch.name`'
alias git.master='git checkout master && git pull'
alias git.merge.master='git fetch && git merge origin/master && git.push'

alias git.commit.test='git.commit "Update Tests"'
alias git.commit.pr='git.commit "PR Feedback"'
alias git.commit.wip='git.commit "WIP"'
alias git.commit.cleanup='git.commit "Clean up"'
alias git.commit.bug='git.commit "Bugfix"'
alias git.commit.empty='git commit --allow-empty -m "Trigger Build" && git.push'

git.commit() {
    git add . && git commit -m "$1" && git.push
}

git.branch.delete() {
    BRANCH_NAME=`git.branch.name`
    git.master
    git branch -d $BRANCH_NAME
}

git.release() {
    RELEASE=`git branch -a | egrep "remotes/origin/release/\d{2}" | tail -1 | sed -e 's/remotes\/origin\///g'`
    git checkout $RELEASE
    git pull
}

git.branch.create() {
    if [ "$1" = "b" ]; then
        TYPE=bug
    elif [ "$1" = "f" ]; then
        TYPE=feature
    else
        TYPE=maintenance
    fi

    MESSAGE=$3
    BRANCH=`echo $MESSAGE | sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/ | sed "s/ /-/g"`

    git checkout -b $TYPE/$2_$BRANCH
    git.commit "$MESSAGE"
}

alias git.merge.release.1='git.release && git checkout -b merge-release && git merge origin/master'
alias git.merge.release.2='git.commit "Merge remote-tracking branch 'origin/master' into merge-release"'

#######    OTHER    #######
# alias cost.psql.rollback='workman import -d cost -f /Users/mperrett/Aconex/pg_dump/appdb-qa110.sql cost'
alias cost.psql.resetTestDatabase='dropdb unittest_cost; dropdb e2e_cost; createdb unittest_cost; createdb e2e_cost'
alias cost.psql.backup='dropdb --if-exists cost_backup && createdb cost_backup -T cost'
alias cost.psql.rollback='dropdb --if-exists cost && createdb cost -T cost_backup'

# Setup tmuxifier for babylon on call
export PATH="$HOME/.tmuxifier/bin:$PATH"
eval "$(tmuxifier init -)"

# history size
export HISTFILESIZE=1000000
export HISTSIZE=1000000

# Bash compleate SSHRC
_complete_sshrc_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_sshrc_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_sshrc_hosts}" -- $cur))
        return 0
}
complete -F _complete_sshrc_hosts sshrc

# Bash compleate SSH
_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
complete -F _complete_ssh_hosts ssh


export CLICOLOR=1

ssh-add ~/.ssh/id_rsa

# http://code-worrier.com/blog/autocomplete-git/
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Git branch in prompt
#parse_git_branch() {
#  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
#}
#export PS1="\u@\h:\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  GIT_PROMPT_ONLY_IN_REPO=1
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi




