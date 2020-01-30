function _a-change() (
    cd $repodir &&
        echo NOK >$1
)

function a-change-to-existing() {
    _a-change Bob
}
_register a-change-to-existing

function another-change-to-existing() (
    cd $repodir &&
        echo OK >Bob
)
_register another-change-to-existing

function this-change() {
    _a-change $1
}
_register this-change 1

function this-change-added() (
    cd $repodir &&
        git add $1
)
_register this-change-added 1

function this-change-added() (
    cd $repodir &&
        git add $1
)
_register this-change-added 1
