###
# Classe principale pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


# Méthode de sauvegarde
OX_BACKUP_METHOD=
# Dossier racine de sauvegarde
OX_BACKUP_ROOT="/tmp"
# Dossier de sauvegarde
OX_BACKUP_PATH="/tmp"
# Chemin complet de l'archive
OX_BACKUP_ARCHIVE=
# Préfixe du nom de l'archive
OX_BACKUP_ARCHIVE_PREFIX=
# Compression de l'archive
OX_BACKUP_ARCHIVE_COMPRESS="gz"
# TTL des archives
OX_BACKUP_ARCHIVE_TTL="5"
# Début de chrono
OX_BACKUP_CHRONO_START=
# Fin du chrono
OX_BACKUP_CHRONO_STOP=
# Element à sauvegarder
OX_BACKUP_ITEM=
# Element à exclure
OX_BACKUP_EXCLUDE=


###
# Initialisation de l'objet BACKUP
# @param $1 : Emplacement du backup
# @param $2 : Rétention pour la purge
##
function Backup.initialize()
{
    debug "Backup.initialize ($1, $2)"

    OX_BACKUP_CHRONO_START=$SECONDS
    OX_BACKUP_CHRONO_STOP=

    [[ -z $1 ]] && critical "Paramètre manquant dans Backup.initialize"
    OX_BACKUP_ROOT=$1
    [[ -z $2 ]] && critical "Paramètre manquant dans Backup.initialize"
    OX_BACKUP_ARCHIVE_TTL=$2

    OX_BACKUP_PATH="$OX_BACKUP_ROOT/$OLIX_SYSTEM_DATE.$(date '+%H%M%S')"
}


###
# Crée le dossier de sauvegarde du jour contenant les fichiers sauvegardés
##
function Backup.repository.create()
{
    debug "Backup.repository.create ()"

    # Si dossier existe
    if ! Directory.exists $OX_BACKUP_PATH; then
        mkdir $OX_BACKUP_PATH 2> ${OLIX_LOGGER_FILE_ERR} || return 1
    fi

    # Si ecriture
    Directory.writable $OX_BACKUP_PATH || return 1

    return 0
}


###
# Retourne le nom complet du dossier de sauvegarde
##
function Backup.repository.get()
{
    echo -e $OX_BACKUP_PATH
}


###
# Retourne la liste des backups
##
function Backup.list.current()
{
    local PARAM
    [[ -n $1 ]] && PARAM="-printf %f\n" || PARAM="-print"
    find $OX_BACKUP_ROOT -mindepth 1 -maxdepth 1 -type d -name "20*" -follow $PARAM | sort
}


###
# Retourne la liste des archives qui peuvent être purgées
##
function Backup.list.purged()
{
    local PARAM
    [[ -n $1 ]] && PARAM="-printf %f\n" || PARAM="-print"
    #echo "find $OX_BACKUP_ROOT -mindepth 1 -maxdepth 1 -type d -name 20* -follow -mtime +$OX_BACKUP_ARCHIVE_TTL $PARAM | sort"
    find $OX_BACKUP_ROOT -mindepth 1 -maxdepth 1 -type d -name "20*" -follow -mtime +$OX_BACKUP_ARCHIVE_TTL $PARAM | sort
}


###
# Purge des anciens fichiers
##
function Backup.purge()
{
    debug "Backup.purge ()"
    local ARCHIVES I
    local ISERROR=false

    ARCHIVES=( $(Backup.list.purged short) )
    Print.value "Purge des anciennes sauvegardes" "$(Array.count 'ARCHIVES')"
    Print.list "$(Array.all 'ARCHIVES')"

    # Purge des fichiers distants
    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in
        ftp)
            Ftp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            for I in $(Array.all 'ARCHIVES'); do
                Ftp.rmdir "$OLIX_MODULE_BACKUP_EXPORT_PATH/$I"
                [[ $? -ne 0 ]] && error && ISERROR=true
            done
            ;;
        ssh)
            Scp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            for I in $(Array.all 'ARCHIVES'); do
                Scp.rmdir "$OLIX_MODULE_BACKUP_EXPORT_PATH/$I"
                [[ $? -ne 0 ]] && error && ISERROR=true
            done
            ;;
    esac

    # Purge locale
    debug "find $OX_BACKUP_ROOT -mindepth 1 -maxdepth 1 -type d -name '20*' -follow -mtime +$OX_BACKUP_ARCHIVE_TTL"
    find $OX_BACKUP_ROOT -mindepth 1 -maxdepth 1 -type d -name "20*" -follow -mtime +$OX_BACKUP_ARCHIVE_TTL -exec rm -rf {} \; 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && ISERROR=true

    ARCHIVES=( $(Backup.list.current short) )
    Print.value "Liste des sauvegardes restantes" "$(Array.count 'ARCHIVES')"
    Print.list "$(Array.all 'ARCHIVES')"

    [[ $ISERROR == true ]] && error && return 1
    return 0
}


###
# Termine la sauvegarde
# @param $1 : Si erreur
##
function Backup.terminate()
{
    debug "Backup.terminate ($1)"
    Print.echo; Print.line;

    if [[ $1 == true ]]; then
        Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec des erreurs" "${Crouge}"
        Report.terminate "ERREUR - Rapport de backup du serveur $HOSTNAME"
        OLIX_CODE_RETURN=1
    else
        Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec succès" "${Cvert}"
        Report.terminate "Rapport de backup du serveur $HOSTNAME"
        OLIX_CODE_RETURN=0
    fi
}
