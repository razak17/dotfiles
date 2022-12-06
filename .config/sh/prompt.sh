#!/bin/bash

# Determine git branch.
parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# PS1 is what actually defines what your command line prompt looks like.
export PS1="\e[0m\e[1;36m\W\e[0m"
gits=" \`parse_git_branch\`\e[0m"
PS1+="\e[1;32m${gits} \e[1;32m» "
# PS1+="\e[1;33m✗\e[0m "
