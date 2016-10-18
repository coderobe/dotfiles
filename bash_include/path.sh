function addToPath () {
  export PATH=$PATH:$1
}

if [ -z "$(whereis ruby | cut -d':' -f2-)" ];then
  false
else
  addToPath $(ruby -rubygems -e "puts Gem.user_dir")/bin
fi
