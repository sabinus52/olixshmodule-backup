###
# Classe de la méthode de sauvegarde RSYNC du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des archives
##
function Backup.Rsync.initialize()
{
    debug "Backup.Rsync.initialize ()"

    Backup.initialize "Rsync" "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "none" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
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

    local PARM LIST_ARCHIVES LAST_ARCHIVE LASTDIR

    # Récupère la liste des archives
    LIST_ARCHIVES=( "$OX_BACKUP_PATH/$OX_BACKUP_ARCHIVE_PREFIX"[0-9]*/ )
    if (( ${#LIST_ARCHIVES[@]} > 0 )); then
        # Dernier de la liste
        LASTDIR=${LIST_ARCHIVES[*]: -1}
        Directory.exists "${LASTDIR%/}" && LAST_ARCHIVE=${LASTDIR%/}
    fi

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARM="$PARM --verbose" || PARM="$PARM --quiet"
    rsync -a $PARM --delete-excluded --link-dest=$LAST_ARCHIVE -- "$OX_BACKUP_ITEM/" "$OX_BACKUP_ARCHIVE/"
    return $?
}
