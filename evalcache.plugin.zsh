# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache <command> <generation args...>

# default cache directory
export ZSH_EVALCACHE_DIR=${ZSH_EVALCACHE_DIR:-"$HOME/.zsh-evalcache"}

function _evalcache () {
  local cmdHash="nohash"

  if builtin command -v md5 > /dev/null; then
    cmdHash=$(echo -n "$*" | md5)
  elif builtin command -v md5sum > /dev/null; then
    cmdHash=$(echo -n "$*" | md5sum | cut -d' ' -f1)
  fi

  local cacheFile="$ZSH_EVALCACHE_DIR/init-${1##*/}-${cmdHash}.sh"

  local name
  for i in {1..$#}; do
    name=${@:$i:1}
    if [[ $name != *'='* ]]; then
      break
    fi
  done

  if [ "$ZSH_EVALCACHE_DISABLE" = "true" ]; then
    eval "$("$@")"
  elif [ -s "$cacheFile" ]; then
    source "$cacheFile"
  else
    if type "$name" > /dev/null; then
      (>&2 echo "$name initialization not cached, caching output of: $*")
      mkdir -p "$ZSH_EVALCACHE_DIR"
      eval "$*" > "$cacheFile"
      source "$cacheFile"
    else
      echo "evalcache ERROR: $name is not installed or in PATH"
    fi
  fi
}

function _evalcache_clear () {
  rm -i "$ZSH_EVALCACHE_DIR"/init-*.sh
}
