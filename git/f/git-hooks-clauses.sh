# WHEN
function hooks-list {
    local hook=$1
    list_output="$(cd $repodir \
        && $git_hooks list $1)"
}
_register hooks-list 1

function hooks-init() (
    cd $repodir \
        && $git_hooks init
)
_register hooks-init 1

function add-hook {
    local hook=$1
    local script=$2
    case $script in
    good ) ln -s /usr/bin/true $repodir/.git/hooks/$hook.d/$script ;;
    bad ) ln -s /usr/bin/false $repodir/.git/hooks/$hook.d/$script ;;
    esac
}
_register add-hook 2

# THEN
function output-is() [[ "$1" == "$list_output" ]]
_register output-is 1

function hooks-installed {
    (cd $repodir/.git/hooks \
        && [[ -f hooks ]] \
        && [[ -r hooks ]] \
        && [[ -x hooks ]] \
        && for h in *.sample
        do
            [[ -d ${h%.sample}.d ]]
            [[ -h ${h%.sample} ]]
        done)
}
_register hooks-installed
