###
# Librairies des rapports pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie le valeur du format du rapport
##
function Backup.Report.check.format()
{
    debug "Backup.Report.check.format ()"

    Report.check.format $OLIX_MODULE_BACKUP_REPORT_FORMAT && return 0 || return 101
}


###
# Vérifie l'email
##
function Backup.Report.check.email()
{
    debug "Backup.Report.check.email ()"

    [[ -z $OLIX_MODULE_BACKUP_REPORT_EMAIL ]] && return 1 || return 0
}
