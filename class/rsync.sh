###
# Classe de la méthode de sauvegarde RSYNC du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des archives
# @param $1 : Compression
##
function Backup.Rsync.initialize()
{
    debug "Backup.Rsync.initialize ($1)"

    OX_BACKUP_METHOD="Rsync"
    OX_BACKUP_ARCHIVE_COMPRESS="none"
    Backup.repository.create
    return $?
}


###
# Retourne le titre du rapport
##
function Backup.Rsync.getTitle()
{
    echo -n "Sauvegarde du dossier %s"
}


###
# Vérifie le dossier à sauvegarder
##
function Backup.Rsync.check()
{
    debug "Backup.Rsync.check ()"
    if  ! Directory.exists $OX_BACKUP_ITEM; then
        warning "Le dossier \"$OX_BACKUP_ITEM\" n'existe pas"
        return 1
    elif ! Directory.readable $OX_BACKUP_ITEM; then
        warning "Le dossier \"$OX_BACKUP_ITEM\" ne peut être lu"
        return 1
    fi
    return 0
}


###
# Retourne le préfixe de l'archive
##
function Backup.Rsync.getPrefix()
{
    echo -n "backup-$(basename $OX_BACKUP_ITEM)-"
}


###
# Retourne l'extension de l'archive
##
function Backup.Rsync.getExtension()
{
    echo -n 'sync'
}


###
# Fait la sauvegarde
##
function Backup.Rsync.doBackup()
{
    debug "Backup.Rsync.doBackup()"

    local PARAM I LAST_ARCHIVE

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="$PARAM --verbose" || PARAM="$PARAM --quiet"
    for I in $OX_BACKUP_EXCLUDE; do
        PARAM="$PARAM --exclude=$I"
    done

    LAST_ARCHIVE=$(Backup.Rsync.archive.last)
    [[ -n $LAST_ARCHIVE ]] && PARAM="$PARAM --link-dest=$LAST_ARCHIVE"

    debug "rsync -a --delete-excluded $PARAM  -- "$OX_BACKUP_ITEM/" "$OX_BACKUP_ARCHIVE/""
    rsync -a --delete-excluded  $PARAM -- "$OX_BACKUP_ITEM/" "$OX_BACKUP_ARCHIVE/"

    return $?
}


###
# Transfert du fichier de backup sur un serveur distant
# @param $1 : Méthode de transfert
# @param $2 : Emplacement sur le serveur distant
##
function Backup.Rsync.export()
{
    debug "Backup.Rsync.export ($1, $2)"
    local TARGET PARAM LASTDIR LIST_ARCHIVES

    case $(String.lower $1) in
        ftp)
            warning 'Pas de transfert FTP en mode rsync'
            return 100
            ;;
        ssh)
            # Dernière archive sur le serveur distant
            LIST_ARCHIVES=( $(ssh -n -- "$(Scp.getConnection)" "find "$OLIX_MODULE_BACKUP_EXPORT_PATH" -mindepth 1 -maxdepth 2 -name '$OX_BACKUP_ARCHIVE_PREFIX*.$(Backup.Rsync.getExtension)' -type d -print | sort") )
            if (( $(Array.count 'LIST_ARCHIVES') > 0 )); then
                LASTDIR=$(Array.last 'LIST_ARCHIVES')
                ! Scp.check.directory "$LASTDIR" && LASTDIR=""
            fi

            # Paramètre du serveur distant
            TARGET="$(Scp.getConnection):$OLIX_MODULE_BACKUP_EXPORT_PATH/$BASEPATH/$(basename $OX_BACKUP_ARCHIVE)/"
            PARAM=$(Scp.getParam)
            [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="$PARAM --verbose" || PARAM="$PARAM --quiet"
            for I in $OX_BACKUP_EXCLUDE; do
                PARAM="$PARAM --exclude=$I"
            done
            [[ -n $LASTDIR ]] && PARAM="$PARAM --link-dest=$LASTDIR"

            debug "rsync -e "ssh -o Compression=no" -za --delete-excluded $PARAM -- "$OX_BACKUP_ITEM/" "$TARGET""
            rsync -e "ssh -o Compression=no" -za --delete-excluded $PARAM -- "$OX_BACKUP_ITEM/" "$TARGET"
            return $?
            ;;
    esac

    return 0
}


###
# Retourne la dernière archive sauvegardé
##
function Backup.Rsync.archive.last()
{
    local LIST_ARCHIVES LASTDIR
    LIST_ARCHIVES=( $(Backup.Archive.list "$OX_BACKUP_ARCHIVE_PREFIX*.$(Backup.Rsync.getExtension)") )
    if (( $(Array.count 'LIST_ARCHIVES') > 0 )); then
        LASTDIR=$(Array.last 'LIST_ARCHIVES')
        Directory.exists "${LASTDIR%/}" && echo ${LASTDIR%/}
    fi
    echo ''
}
