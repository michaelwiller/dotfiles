cd $HOME

MAX_DAYS=10
DATE_FILE=/tmp/bash-rc-brew.val
LAST_RUN="NOTRUN"
NOW=$(date +%Y-%m-%d)
days=10000

[ -f $DATE_FILE ] && LAST_RUN=$(cat $DATE_FILE)

[ ! "$LAST_RUN" == "NOTRUN" ] && days=$(((`date -jf %Y-%m-%d "$NOW" +%s` - `date -jf %Y-%m-%d "$LAST_RUN" +%s`)/86400))

if [ "$1" == "-f" -o $days -gt $MAX_DAYS ]; then
  echo "Running brew update"
  brew bundle check || brew bundle install && echo "$NOW" > $DATE_FILE
fi
