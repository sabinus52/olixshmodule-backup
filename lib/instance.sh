###
# Librairies pour chaque instance de sauvegarde du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


OLIX_MODULE_BACKUP_INSTANCE_FILE=
OLIX_MODULE_BACKUP_INSTANCE_FILE_PREFIX=

OLIX_MODULE_BACKUP_INSTANCE_PATH="/tmp"
OLIX_MODULE_BACKUP_INSTANCE_COMPRESS="GZ"
OLIX_MODULE_BACKUP_INSTANCE_TTL="5"

OLIX_MODULE_BACKUP_INSTANCE_CHRONO_START=
OLIX_MODULE_BACKUP_INSTANCE_CHRONO_STOP=



###
# Initialisation du backup
# @param $1  : Emplacement du backup.
# @param $2  : Compression
# @param $3  : Rétention pour la purge
##
function Backup.Instance.initialize()
{
    debug "Backup.Instance.initialize ($1, $2, $3)"
    [[ -z $1 ]] && return
    OLIX_MODULE_BACKUP_INSTANCE_PATH=$1
    [[ -z $2 ]] && return
    OLIX_MODULE_BACKUP_INSTANCE_COMPRESS=$2
    [[ -z $3 ]] && return
    OLIX_MODULE_BACKUP_INSTANCE_TTL=$3

    OLIX_MODULE_BACKUP_INSTANCE_CHRONO_START=$SECONDS
    OLIX_MODULE_BACKUP_INSTANCE_CHRONO_STOP=
}


###
# Affecte le fichier de sauvegarde
# @param $1  : Prefixe du fichier
# @param $2  : Extension du fichier
##
function Backup.Instance.setfile()
{
    debug "Backup.Instance.setfile ($1, $2)"
    [[ -z $1 ]] && critical "Préfixe du fichier de sauvegarde non renseigné"
    OLIX_MODULE_BACKUP_INSTANCE_FILE_PREFIX=$1
    OLIX_MODULE_BACKUP_INSTANCE_FILE=$OLIX_MODULE_BACKUP_INSTANCE_PATH/$1$OLIX_SYSTEM_DATE-$(date '+%H%M').$2
}


###
# Retourne le nom complet du fichier de sauvegarde
##
function Backup.Instance.getfile()
{
    echo -e $OLIX_MODULE_BACKUP_INSTANCE_FILE
}


###
# Finalise la sauvegarde
##
function Backup.Instance.terminate()
{
    debug "Backup.Instance.terminate ()"

    Backup.Instance.purge || return 1

    return 0
}


###
# Affiche le résultat de l'action de la sauvegarde
# @param $1  : Si erreur ou pas
##
function Backup.Instance.printresult()
{
    debug "Backup.Instance.printresult ($1)"

    OLIX_MODULE_BACKUP_INSTANCE_CHRONO_STOP=$SECONDS
    Print.result $1 "Sauvegarde" "$(File.size.human $OLIX_MODULE_BACKUP_INSTANCE_FILE)" "$((OLIX_MODULE_BACKUP_INSTANCE_CHRONO_STOP-OLIX_MODULE_BACKUP_INSTANCE_CHRONO_START))"

    return $1
}


###
# Compression d'un fichier de sauvegarde
##
function Backup.Instance.compress()
{
    debug "Backup.Instance.compress ()"
    local RET
    local START=$SECONDS

    case $(String.lower $OLIX_MODULE_BACKUP_INSTANCE_COMPRESS) in
        bz|bz2)
            Compression.bzip.compress $OLIX_MODULE_BACKUP_INSTANCE_FILE
            RET=$?
            OLIX_MODULE_BACKUP_INSTANCE_FILE=$OLIX_FUNCTION_RESULT
            ;;
        gz)
            Compression.gzip.compress $OLIX_MODULE_BACKUP_INSTANCE_FILE
            RET=$?
            OLIX_MODULE_BACKUP_INSTANCE_FILE=$OLIX_FUNCTION_RESULT
            ;;
        null)
            return 0
            ;;
        *)
            warning "Le type de compression \"${OLIX_MODULE_BACKUP_INSTANCE_COMPRESS}\" n'est pas disponible"
            return 0
            ;;
    esac

    Print.result ${RET} "Compression du fichier" "$(File.size.human $OLIX_MODULE_BACKUP_INSTANCE_FILE)" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && error && return 1
    return 0
}


###
# Purge des anciens fichiers
##
function Backup.Instance.purge()
{
    debug "Backup.Instance.purge ()"

    local LIST_FILE_PURGED=$(System.file.temp)
    local RET

    case $OLIX_MODULE_BACKUP_INSTANCE_TTL in
        LOG|log)
            Filesystem.purge.logarithmic "$OLIX_MODULE_BACKUP_INSTANCE_PATH" "$OLIX_MODULE_BACKUP_INSTANCE_FILE_PREFIX" "$LIST_FILE_PURGED"
            RET=$?;;
        *)
            Filesystem.purge.standard "$OLIX_MODULE_BACKUP_INSTANCE_PATH" "$OLIX_MODULE_BACKUP_INSTANCE_FILE_PREFIX" "$OLIX_MODULE_BACKUP_INSTANCE_TTL" "$LIST_FILE_PURGED"
            RET=$?;;
    esac

    Print.value "Purge des anciennes sauvegardes" "$(cat $LIST_FILE_PURGED | wc -l)"
    Print.file $LIST_FILE_PURGED
    [[ ${RET} -ne 0 ]] && warning && return 1

    Print.value "Liste des sauvegardes restantes" "$(find $OLIX_MODULE_BACKUP_INSTANCE_PATH -maxdepth 1 -name "$OLIX_MODULE_BACKUP_INSTANCE_FILE_PREFIX*" | wc -l)"
    find $OLIX_MODULE_BACKUP_INSTANCE_PATH -maxdepth 1 -name "$OLIX_MODULE_BACKUP_INSTANCE_FILE_PREFIX*" -follow -printf "%f\n" |sort > $LIST_FILE_PURGED
    RET=$?
    Print.file $LIST_FILE_PURGED

    [[ $RET -ne 0 ]] && error && return 1
    rm -f $LIST_FILE_PURGED
    return 0
}