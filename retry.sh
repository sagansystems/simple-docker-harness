function retry {
  local retry_max=$1
  shift

  local count=$retry_max
  while [ $count -gt 0 ]; do
    "$@" && break
    echo "Retry failed [$count/$retry_max]: $@" >&2
    count=$(($count - 1))
    sleep 1
  done

  [ $count -eq 0 ] && return 1
  return 0
}
