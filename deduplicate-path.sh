function deduplicate-path() {
    local -a paths
    mapfile -t paths < <(echo "$PATH" | tr : '\n')
    local -a unique=()
    for p in "${paths[@]}"; do
        for u in "${unique[@]}"; do
            [[ "$p" == "$u" ]] && continue 2 # JMP back to paths loop
        done
        unique+=("$p")
    done

    # More complex than liked, but ensures no trailing colon vs printf
    (
        IFS=:
        echo "${unique[*]}"
    )
}
