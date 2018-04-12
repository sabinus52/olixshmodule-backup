###
# Classe des archives
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



###
# Fait la sauvegarde d'un élément
# @param $1 : Element à sauvegarder
# @param $2 : Exclusion
##
function Backup.Archive.doBackup()
{
    debug "Backup.Archive.doBackup ($1, $2)"
    OX_BACKUP_ITEM=$1
    OX_BACKUP_EXCLUDE=$2

    Print.head2 "$(Backup.$OX_BACKUP_METHOD.getTitle)" "$OX_BACKUP_ITEM"

    Backup.$OX_BACKUP_METHOD.check || return 1

    Backup.Archive.set "$(Backup.$OX_BACKUP_METHOD.getPrefix)" "$(Backup.$OX_BACKUP_METHOD.getExtension)"
    info "Sauvegarde ($OX_BACKUP_ITEM) -> $OX_BACKUP_ARCHIVE"

    Backup.$OX_BACKUP_METHOD.doBackup
    Backup.Archive.printResult $? || return 1

    Backup.Archive.export || return 1

    return 0
}


###
# Affecte le fichier de sauvegarde
# @param $1  : Prefixe du fichier
# @param $2  : Extension du fichier
##
function Backup.Archive.set()
{
    debug "Backup.Archive.set ($1, $2)"
    [[ -z $1 ]] && critical "Préfixe du fichier de sauvegarde non renseigné"
    [[ -z $2 ]] && critical "Extension du fichier de sauvegarde non renseigné"
    OX_BACKUP_ARCHIVE_PREFIX=$1
    OX_BACKUP_ARCHIVE=$OX_BACKUP_PATH/$1$OLIX_SYSTEM_DATE-$(date '+%H%M').$2
}


###
# Affiche le résultat de l'action de la sauvegarde
# @param $1  : Si erreur ou pas
##
function Backup.Archive.printResult()
{
    debug "Backup.Archive.printResult ($1)"

    OX_BACKUP_CHRONO_STOP=$SECONDS
    Print.result $1 "Sauvegarde" "$(File.size.human $OX_BACKUP_ARCHIVE)" "$((OX_BACKUP_CHRONO_STOP-OX_BACKUP_CHRONO_START))"

    return $1
}


###
# Transfert du fichier de backup sur un serveur distant
##
function Backup.Archive.export()
{
    debug "Backup.Archive.export ()"
    local RET BASEPATH
    OX_BACKUP_CHRONO_START=$SECONDS
    BASEPATH=$(basename $OX_BACKUP_PATH)

    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in
        ftp)
            Ftp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            ! Ftp.check.directory "$OLIX_MODULE_BACKUP_EXPORT_PATH/$BASEPATH" && Ftp.mkdir "$BASEPATH" "$OLIX_MODULE_BACKUP_EXPORT_PATH"
            ;;
        ssh)
            Scp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            ! Scp.check.directory "$OLIX_MODULE_BACKUP_EXPORT_PATH/$BASEPATH" && Scp.mkdir "$BASEPATH" "$OLIX_MODULE_BACKUP_EXPORT_PATH"
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

    Backup.$OX_BACKUP_METHOD.export $OLIX_MODULE_BACKUP_EXPORT_MODE "$OLIX_MODULE_BACKUP_EXPORT_PATH/$BASEPATH"
    RET=$?
    [[ $RET -eq 100 ]] && return 0

    Print.result $RET "Transfert vers le serveur de backup" "" "$((SECONDS-OX_BACKUP_CHRONO_START))"
    [[ $? -ne 0 ]] && error && return 1
    return 0
}


###
# Retourne la liste des archives courantes
# @param $1 : Masque de recherche
##
function Backup.Archive.list()
{
    find $OX_BACKUP_ROOT -mindepth 1 -maxdepth 2 -name "$1" -follow -print | sort
}
