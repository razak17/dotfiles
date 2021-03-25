# Determine git branch.
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# PS1 is what actually defines what your command line prompt looks like.
# export PS1="\e[1;33m\u\e[0m@\h:\e[1;34m[\W]\e[0m"
# export PS1='┌──[\u@\h]─[\w]\n└──╼ \$ '
# export PS1="\e[1;33m\u\e[0m \e[0;31m►\e[0m \e[1;34m\W\e[0m
# export PS1="\e[1;33mr@m\e[0m \e[1;34m\W\e[0m
export PS1="\e[1;32m➜  \e[0m\e[1;36m\W\e[0m "
# PS1+="\e[1;34m git:\e[0m"
git="\e[1;32mgit:\e[0m"
cross="\e[1;32m✗\e[0m"
gits="${git}\`parse_git_branch\`\e[0m ${cross} "
PS1+="\e[1;31m${gits}"
# PS1+="\e[1;33m ✗\e[0m "

