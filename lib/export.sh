###
# Librairies d'export des sauvegardes
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie le mode de transfert
##
function Backup.Export.check()
{
    debug "Backup.Export.check ()"

    [[ -z $OLIX_MODULE_BACKUP_EXPORT_MODE ]] && return 1
    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in
        ftp)
            System.binary.exists lftp
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        ssh)
            System.binary.exists scp
            [[ $? -eq 0 ]] && return 0 || return 202
            ;;
        none|null|false)
            return 1;;
        *)
            return 101;;
    esac
}









