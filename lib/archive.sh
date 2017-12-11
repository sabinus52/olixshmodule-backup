###
# Librairies des archives pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie le valeur du ttl de la purge
##
function Backup.Archive.check.purge()
{
    debug "Backup.Archive.check.purge ()"

    Digit.integer $OLIX_MODULE_BACKUP_ARCHIVE_TTL && return 0 || return 101
}


###
# Vérifie le valeur de compression des archives
# @param $1 : Compression
##
function Backup.Archive.check.compress()
{
    debug "Backup.Archive.check.compress ($1)"

    [[ -z $1 ]] && return 1
    case $(String.lower $1) in
        gz)
            System.binary.exists gzip
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        bz|bz2)
            System.binary.exists bzip2
            [[ $? -eq 0 ]] && return 0 || return 202
            ;;
        none|null|false)
            return 1;;
        *)
            return 101;;
    esac
}
