if [ -z "$HOME" ]
then
	HOME="$USERPROFILE"
fi

export HOME=$(echo "/$HOME" | sed -e 's/\\/\//g' -e 's/://')
if [ -e ~/.bashrc ]
then
  source ~/.bashrc
fi
