function greet-greenly() {
  $print "${pgreen}I am green.${preset}"
}

function _greet-greenly-help() {
  cat <<EOH
It's good to be green.
EOH
}
