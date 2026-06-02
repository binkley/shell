# Starter Directory Architectural Review

This document contains the findings from an architectural review of the `starter/` directory.

## 1. Unimplemented Logic
* **`-check-savefile()`**: This function in `bash-it-up.sh` currently declares `local savedir="$1"` and then does nothing. If this is meant to ensure directory creation (`mkdir -p`), it's currently a no-op.

## 2. Architectural Smells & Scaling Risks
* **Global Namespace Pollution for Task Discovery**: 
  ```bash
  mapfile -t tasks < <(declare -F | cut -d' ' -f3 | grep -v '^-' | sort)
  ```
  Assuming *any* function that doesn't start with a hyphen `-` is a CLI task is highly fragile. If a developer later sources a standard library, or if the user's environment imports functions (like `nvm` or system bash-completion helpers), they will all suddenly appear as CLI subcommands.
  * **Recommendation**: Use a whitelist namespace pattern. Prefix tasks with something explicit like `cmd::` or `task_` (e.g., `task_greet-greenly`), and strip the prefix when populating the `tasks` array.

* **Brittle File Sourcing**:
  ```bash
  for f in "${0%/*}/functions"/*.sh; do source "$f"; done
  ```
  Because `shopt -s nullglob` is not enabled, if the `functions/` directory is ever empty of `.sh` files, the glob will literally resolve to the string `".../functions/*.sh"`, which will crash the script when `source` tries to read it.
  * **Recommendation**: Add `shopt -s nullglob` before the loop and `shopt -u nullglob` after (or rely on a subshell/setup function).

## 3. Make Integration Edge Cases
* **IFS word-splitting & Make output**:
  ```bash
  commands=($(make -f functions/Runfile "$@"))
  ```
  Because the script changes `IFS=$'\t\n'`, it strictly relies on `make` echoing targets separated by newlines. Since the `Runfile` rules currently use `@echo`, this works. However, if a developer ever forgets the `@` symbol in the `Runfile`, Make will print the raw execution command (e.g., `echo greet-greenly`), which will be parsed as unexpected array elements due to the strict `IFS`.

---
*Note: The "Broken Terminal State" typo (`{$preset}` -> `${preset}`) was fixed previously.*

*Note: The "Inconsistent Argument Parsing" dangling option (`-S` vs `-s` vs `--save`) was fixed previously.*
