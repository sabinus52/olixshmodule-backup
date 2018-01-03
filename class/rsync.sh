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

    local PARAM I LAST_ARCHIVE

    LAST_ARCHIVE=$(Backup.Archive.last)

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="$PARAM --verbose" || PARAM="$PARAM --quiet"
    for I in $OX_BACKUP_EXCLUDE; do
        PARAM="$PARAM --exclude=$I"
    done

    #echo "rsync -a $PARAM --delete-excluded --link-dest=$LAST_ARCHIVE -- "$OX_BACKUP_ITEM/" "$OX_BACKUP_ARCHIVE/""
    rsync -a $PARAM --delete-excluded --link-dest=$LAST_ARCHIVE -- "$OX_BACKUP_ITEM/" "$OX_BACKUP_ARCHIVE/"

    return $?
}
