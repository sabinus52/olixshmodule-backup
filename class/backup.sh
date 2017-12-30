###
# Classe principale pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


# Méthode de sauvegarde
OX_BACKUP_METHOD=
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


###
# Initialisation de l'objet BACKUP
# @param $1 : Méthode de sauvegarde
# @param $2 : Emplacement du backup
# @param $3 : Compression
# @param $4 : Rétention pour la purge
##
function Backup.initialize()
{
    debug "Backup.initialize ($1, $2, $3, $4)"

    OX_BACKUP_CHRONO_START=$SECONDS
    OX_BACKUP_CHRONO_STOP=

    [[ -z $1 ]] && critical "Paramètre manquant dans Backup.initialize"
    OX_BACKUP_METHOD=$1
    [[ -z $2 ]] && critical "Paramètre manquant dans Backup.initialize"
    OX_BACKUP_PATH=$2
    [[ -z $3 ]] && critical "Paramètre manquant dans Backup.initialize"
    OX_BACKUP_ARCHIVE_COMPRESS=$3
    [[ -z $4 ]] && critical "Paramètre manquant dans Backup.initialize"
    OX_BACKUP_ARCHIVE_TTL=$4
}


###
# Fait la sauvegarde d'un élément
# @param $1 : Element à sauvegarder
##
function Backup.doBackup()
{
    debug "Backup.doBackup ($1)"
    OX_BACKUP_ITEM=$1

    Print.head2 "$(Backup.$OX_BACKUP_METHOD.getTitle)" "$OX_BACKUP_ITEM"

    Backup.$OX_BACKUP_METHOD.check || return 1

    Backup.Archive.set "$(Backup.$OX_BACKUP_METHOD.getPrefix)" "$(Backup.$OX_BACKUP_METHOD.getExtension)"
    info "Sauvegarde ($OX_BACKUP_ITEM) -> $(Backup.Archive.get)"

    Backup.${OX_BACKUP_METHOD}.doBackup
    Backup.printResult $? || return 1

    Backup.export || return 1

    Backup.purge || return 1

    return 0
}


###
# Affiche le résultat de l'action de la sauvegarde
# @param $1  : Si erreur ou pas
##
function Backup.printResult()
{
    debug "Backup.printResult ($1)"

    OX_BACKUP_CHRONO_STOP=$SECONDS
    Print.result $1 "Sauvegarde" "$(File.size.human $OX_BACKUP_ARCHIVE)" "$((OX_BACKUP_CHRONO_STOP-OX_BACKUP_CHRONO_START))"

    return $1
}


###
# Transfert du fichier de backup sur un serveur distant
##
function Backup.export()
{
    debug "Backup.export ()"
    local RET
    OX_BACKUP_CHRONO_START=$SECONDS

    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in
        ftp)
            Ftp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            Ftp.put "$OX_BACKUP_ARCHIVE" "$OLIX_MODULE_BACKUP_EXPORT_PATH"
            RET=$?
            ;;
        ssh)
            Scp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            Scp.put "$OX_BACKUP_ARCHIVE" "$OLIX_MODULE_BACKUP_EXPORT_PATH"
            RET=$?
            ;;
        none|false|null)
            warning "Pas de transfert vers un autre serveur configuré"
            return 0
            ;;
        *)
            error "Methode '$OLIX_MODULE_BACKUP_EXPORT_MODE' d'export de la sauvegarde inconnue"
            return 1
            ;;
    esac

    Print.result $RET "Transfert vers le serveur de backup" "" "$((SECONDS-OX_BACKUP_CHRONO_START))"
    [[ $? -ne 0 ]] && error && return 1
    return 0
}


###
# Purge des anciens fichiers
##
function Backup.purge()
{
    debug "Backup.purge ()"
    local ARCHIVES RET I

    ARCHIVES=( $(Backup.Archive.purged.list) )
    Print.value "Purge des anciennes sauvegardes" "$(Array.count 'ARCHIVES')"
    Print.list "$(Array.all 'ARCHIVES')"

    # Purge des fichiers distants
    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in
        ftp)
            for I in $(Array.all 'ARCHIVES'); do
                Ftp.remove "$OLIX_MODULE_BACKUP_EXPORT_PATH/$I"
            done
            ;;
        ssh)
            for I in $(Array.all 'ARCHIVES'); do
                Scp.remove "$OLIX_MODULE_BACKUP_EXPORT_PATH/$I"
            done
            ;;
    esac

    # Purge locale
    Backup.Archive.purge
    RET=$?

    ARCHIVES=( $(Backup.Archive.list) )
    Print.value "Liste des sauvegardes restantes" "$(Array.count 'ARCHIVES')"
    Print.list "$(Array.all 'ARCHIVES')"

    [[ $RET -ne 0 ]] && error && return 1
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
        Report.terminate "ERREUR - Rapport de backup des bases du serveur $HOSTNAME"
        OLIX_CODE_RETURN=1
    else
        Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec succès" "${Cvert}"
        Report.terminate "Rapport de backup des bases du serveur $HOSTNAME"
        OLIX_CODE_RETURN=0
    fi
}
