###
# Usage du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function olixmodule_backup_usage_main()
{
    debug "olixmodule_backup_usage_main ()"
    echo
    echo -e "Gestion des applications web"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} help     ${CVOID}  : Affiche cet écran"
}
