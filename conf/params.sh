###
# Parse les paramètres de la commande en fonction des options
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



###
# Parsing des paramètres
##
function olixmodule_backup_params_parse()
{
    debug "olixmodule_backup_params_parse ($@)"
    local ACTION=$1
    local PARAM

    shift
    while [[ $# -ge 1 ]]; do
        shift
    done

    olixmodule_backup_params_debug $ACTION
}


###
# Mode DEBUG
# @param $1 : Action du module
##
function olixmodule_backup_params_debug ()
{
}
