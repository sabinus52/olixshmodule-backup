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
    local CMDPARAMS

    shift
    while [[ $# -ge 1 ]]; do
        case $1 in
            --conf=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_BACKUP_CONFYML=${PARAM[1]}
                ;;
            --allbases)
                OLIX_MODULE_BACKUP_ALLBASES=true
                ;;
            --path=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_BACKUP_REPOSITORY_ROOT=${PARAM[1]}
                ;;
            --ttl=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_BACKUP_ARCHIVE_TTL=${PARAM[1]}
                ;;
            --gz|--bz2)
                OLIX_MODULE_BACKUP_TARBALL_COMPRESS=${1/--/}
                OLIX_MODULE_BACKUP_MYSQL_COMPRESS=${1/--/}
                OLIX_MODULE_BACKUP_POSTGRES_COMPRESS=${1/--/}
                ;;
            --noz)
                OLIX_MODULE_BACKUP_TARBALL_COMPRESS="none"
                OLIX_MODULE_BACKUP_MYSQL_COMPRESS="none"
                OLIX_MODULE_BACKUP_POSTGRES_COMPRESS="none"
                ;;
            --html)
                OLIX_MODULE_BACKUP_REPORT_FORMAT="html"
                ;;
            --email)
                OLIX_MODULE_BACKUP_REPORT_EMAIL=${1/--/}
                ;;
            *)
                CMDPARAMS="$CMDPARAMS $1"
                ;;
        esac
        shift
    done

    case $ACTION in
        mysql)
            [[ -n $CMDPARAMS ]] && OLIX_MODULE_BACKUP_MYSQL_BASES="$CMDPARAMS"
            ;;
        postgres)
            [[ -n $CMDPARAMS ]] && OLIX_MODULE_BACKUP_POSTGRES_BASES="$CMDPARAMS"
            ;;
        tarball)
            [[ -n $CMDPARAMS ]] && OLIX_MODULE_BACKUP_TARBALL_FOLDERS="$CMDPARAMS"
            ;;
        rsync)
            [[ -n $CMDPARAMS ]] && OLIX_MODULE_BACKUP_RSYNC_FOLDERS="$CMDPARAMS"
            ;;
    esac

    olixmodule_backup_params_debug $ACTION
}



###
# Fonction de récupération des paramètres
# @param $1 : Nom de l'action
# @param $2 : Nom du paramètre
##
function olixmodule_backup_params_get()
{
    case $1 in
        *) ;;
    esac
}


###
# Mode DEBUG
# @param $1 : Action du module
##
function olixmodule_backup_params_debug ()
{
    debug "OLIX_MODULE_BACKUP_CONFYML=${OLIX_MODULE_BACKUP_CONFYML}"
    debug "OLIX_MODULE_BACKUP_REPOSITORY_ROOT=${OLIX_MODULE_BACKUP_REPOSITORY_ROOT}"
    debug "OLIX_MODULE_BACKUP_ARCHIVE_TTL=${OLIX_MODULE_BACKUP_ARCHIVE_TTL}"
    case $1 in
        mysql)
            debug "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}"
            debug "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}"
            debug "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}"
            debug "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}"
            debug "OLIX_MODULE_BACKUP_MYSQL_BASES=${OLIX_MODULE_BACKUP_MYSQL_BASES}"
            debug "OLIX_MODULE_BACKUP_ALLBASES=${OLIX_MODULE_BACKUP_ALLBASES}"
            debug "OLIX_MODULE_BACKUP_MYSQL_COMPRESS=${OLIX_MODULE_BACKUP_MYSQL_COMPRESS}"
            ;;
        postgres)
            debug "OLIX_MODULE_POSTGRES_HOST=${OLIX_MODULE_POSTGRES_HOST}"
            debug "OLIX_MODULE_POSTGRES_PORT=${OLIX_MODULE_POSTGRES_PORT}"
            debug "OLIX_MODULE_POSTGRES_USER=${OLIX_MODULE_POSTGRES_USER}"
            debug "OLIX_MODULE_POSTGRES_PASS=${OLIX_MODULE_POSTGRES_PASS}"
            debug "OLIX_MODULE_BACKUP_POSTGRES_BASES=${OLIX_MODULE_BACKUP_POSTGRES_BASES}"
            debug "OLIX_MODULE_BACKUP_ALLBASES=${OLIX_MODULE_BACKUP_ALLBASES}"
            debug "OLIX_MODULE_BACKUP_POSTGRES_COMPRESS=${OLIX_MODULE_BACKUP_POSTGRES_COMPRESS}"
            ;;
        tarball)
            debug "OLIX_MODULE_BACKUP_TARBALL_FOLDERS=${OLIX_MODULE_BACKUP_TARBALL_FOLDERS}"
            debug "OLIX_MODULE_BACKUP_TARBALL_COMPRESS=${OLIX_MODULE_BACKUP_TARBALL_COMPRESS}"
            ;;
        rsync)
            debug "OLIX_MODULE_BACKUP_RSYNC_FOLDERS=${OLIX_MODULE_BACKUP_RSYNC_FOLDERS}"
            ;;
    esac
    debug "OLIX_MODULE_BACKUP_REPORT_FORMAT=${OLIX_MODULE_BACKUP_REPORT_FORMAT}"
    debug "OLIX_MODULE_BACKUP_REPORT_EMAIL=${OLIX_MODULE_BACKUP_REPORT_EMAIL}"
}
