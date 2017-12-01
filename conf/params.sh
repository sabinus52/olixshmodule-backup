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
        case $1 in
            --allbases)
                OLIX_MODULE_BACKUP_ALLBASES=true
                ;;
            --path=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_BACKUP_PATH=${PARAM[1]}
                ;;
            --ttl=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_BACKUP_TTL=${PARAM[1]}
                ;;
            --gz|--bz2)
                OLIX_MODULE_BACKUP_COMPRESS=${1/--/}
                ;;
            --noz)
                OLIX_MODULE_BACKUP_COMPRESS="null"
                ;;
            --html)
                OLIX_MODULE_BACKUP_REPORT="html"
                ;;
            *)
                olixmodule_backup_params_get "$ACTION" "$1"
                ;;
        esac
        shift
    done

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
        mysql|postgres)
            OLIX_MODULE_BACKUP_BASES="$OLIX_MODULE_BACKUP_BASES $2"
            ;;
    esac
}


###
# Mode DEBUG
# @param $1 : Action du module
##
function olixmodule_backup_params_debug ()
{
    case $1 in
        mysql)
            debug "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}"
            debug "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}"
            debug "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}"
            debug "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}"
            debug "OLIX_MODULE_BACKUP_BASES=${OLIX_MODULE_BACKUP_BASES}"
            debug "OLIX_MODULE_BACKUP_ALLBASES=${OLIX_MODULE_BACKUP_ALLBASES}"
            ;;
        postgres)
            debug "OLIX_MODULE_POSTGRES_HOST=${OLIX_MODULE_POSTGRES_HOST}"
            debug "OLIX_MODULE_POSTGRES_PORT=${OLIX_MODULE_POSTGRES_PORT}"
            debug "OLIX_MODULE_POSTGRES_USER=${OLIX_MODULE_POSTGRES_USER}"
            debug "OLIX_MODULE_POSTGRES_PASS=${OLIX_MODULE_POSTGRES_PASS}"
            debug "OLIX_MODULE_BACKUP_BASES=${OLIX_MODULE_BACKUP_BASES}"
            debug "OLIX_MODULE_BACKUP_ALLBASES=${OLIX_MODULE_BACKUP_ALLBASES}"
            ;;
    esac
    debug "OLIX_MODULE_BACKUP_PATH=${OLIX_MODULE_BACKUP_PATH}"
    debug "OLIX_MODULE_BACKUP_TTL=${OLIX_MODULE_BACKUP_TTL}"
    debug "OLIX_MODULE_BACKUP_COMPRESS=${OLIX_MODULE_BACKUP_COMPRESS}"
    debug "OLIX_MODULE_BACKUP_REPORT=${OLIX_MODULE_BACKUP_REPORT}"
}
