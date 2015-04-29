export HOME=$(echo "/$USERPROFILE" | sed -e 's/\\/\//g' -e 's/://')
if [ -e ~/.bashrc ]
then
  source ~/.bashrc
fi
