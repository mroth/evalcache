# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache [NAME=VALUE]... COMMAND [ARG]...

# default cache directory
export ZSH_EVALCACHE_DIR=${ZSH_EVALCACHE_DIR:-"$HOME/.zsh-evalcache"}

function _evalcache () {
  local cmdHash=5381 data="$*" name c

  # use the first non-variable argument as the name
  for name in $@; do
    if [ "${name}" = "${name#[A-Za-z_][A-Za-z0-9_]*=}" ]; then
      break
    fi
  done

  # if command is a function, include its definition in data
  if typeset -f "${name}" > /dev/null; then
    data=${data}$(typeset -f "${name}")
  fi

  for c in ${(s::)data}; do
    (( cmdHash = (cmdHash * 33 + #c) & 0xffffffff ))
  done

  local cacheFile="$ZSH_EVALCACHE_DIR/init-${name##*/}-${cmdHash}.sh"

  if [ "$ZSH_EVALCACHE_DISABLE" = "true" ]; then
    eval ${(q)@}
  elif [ -s "$cacheFile" ]; then
    source "$cacheFile"
  else
    if type "${name}" > /dev/null; then
      echo "evalcache: ${name} initialization not cached, caching output of: $*" >&2
      mkdir -p "$ZSH_EVALCACHE_DIR"
      eval ${(q)@} > "$cacheFile"
      zcompile "$cacheFile"
      source "$cacheFile"
    else
      echo "evalcache: ERROR: ${name} is not installed or in PATH" >&2
    fi
  fi
}

function _evalcache_clear () {
  rm -i "$ZSH_EVALCACHE_DIR"/init-*.{sh,zwc}
}
