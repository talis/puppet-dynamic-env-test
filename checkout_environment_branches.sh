containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

REPO="git@github.com:talis/puppet-dynamic-env-test.git"
BRANCH_DIR="/etc/puppet/environments"
cd $BRANCH_DIR

git fetch --all --prune
git pull

echo -e "\nUpdating/Creating environment branches\n"
b=`git branch -a | grep "^  remotes" | sed -s 's/remotes\/origin\///g' | sed -s 's/[[:blank:]]//g' | grep -v '^master$'`
BRANCHES=(${b//\\n/})

for BRANCH in "${BRANCHES[@]}"
do
    { cd $BRANCH_DIR/$BRANCH && git pull origin $BRANCH ; } || { mkdir -p $BRANCH_DIR && cd $BRANCH_DIR && git clone $REPO $BRANCH && cd $BRANCH && git checkout -b $BRANCH origin/$BRANCH ; }
done

cd $BRANCH_DIR
echo -e "\nRemoving stale environment branches\n"
for d in *; do
  if [[ -d $d ]]; then
    containsElement "$d" "${BRANCHES[@]}"
    if [[ "$?" == 1 && "$d" != "production" ]]; then
       echo "  Pruning stale branch $d"
       rm -rf $d
    fi
  fi
done

echo -e "\nFinished"