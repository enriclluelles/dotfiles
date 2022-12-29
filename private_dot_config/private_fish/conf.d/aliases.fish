# git
alias glr='git pull --rebase'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gdc='git diff --cached'
alias gde='gd | matew'
alias gdce='gdc | matew'
alias gc='git commit -v'
alias gca='git commit -va'
alias gb='git branch -v'
alias gs='git status'
alias gss='git status -sb'
alias gls='git log --format=shortd'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"

#webshare
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"'

#docker
alias docker_killall='docker rm -f $(docker ps -a -q)'

