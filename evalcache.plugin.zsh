# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache <command> <generation args...>

# default cache directory
export ZSH_EVALCACHE_DIR=${ZSH_EVALCACHE_DIR:-"$HOME/.zsh-evalcache"}

function _evalcache () {
  local cacheFile="$ZSH_EVALCACHE_DIR/init-$1.sh"

  if [ "$ZSH_EVALCACHE_DISABLE" = "true" ]; then
    eval "$("$@")"
  elif [ -s "$cacheFile" ]; then
    source "$cacheFile"
  else
    if type "$1" > /dev/null; then
      (>&2 echo "$1 initialization not cached, caching output of: $*")
      mkdir -p "$ZSH_EVALCACHE_DIR"
      "$@" > "$cacheFile"
      source "$cacheFile"
    else
      echo "evalcache ERROR: $1 is not installed or in PATH"
    fi
  fi
}

function _evalcache_clear () {
  rm -i "$ZSH_EVALCACHE_DIR"/init-*.sh
}
