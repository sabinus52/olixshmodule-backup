###
# Librairies des méthodes de sauvegardes du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si une méthode de sauvegarde existe
# @param $1 : Méthode
##
function Backup.Method.check.exists()
{
    debug "Backup.check.Method.exists ($1)"

    case $(String.lower $1) in
        tarball)
            System.binary.exists 'tar'
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        mysql)
            System.binary.exists 'mysqldump'
            [[ $? -eq 0 ]] && return 0 || return 202
            ;;
        mysql)
            System.binary.exists 'pg_dump'
            [[ $? -eq 0 ]] && return 0 || return 203
            ;;
        *)
            return 101;;
    esac

    return 0
}
