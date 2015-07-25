host-pwd() {
  CONTAINER_DIR=`pwd`
  SUBDIR=$(echo $CONTAINER_DIR | sed "s/\\/var\\/shared\(.\+\)/\1/")
  if [[ -z $SUBDIR ]]; then
    exit 1
  fi
  echo "/Users/nick/src$SUBDIR"
}
