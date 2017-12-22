###
# Classe de la méthode de sauvegarde TARBALL du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des archives
##
function Backup.Tarball.initialize()
{
    debug "Backup.Tarball.initialize ()"

    Backup.initialize "Tarball" "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_TARBALL_COMPRESS" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
}


###
# Retourne le titre du rapport
##
function Backup.Tarball.getTitle()
{
    echo -e "Sauvegarde du dossier %s"
}


###
# Vérifie le dossier à sauvegarder
##
function Backup.Tarball.check()
{
    debug "Backup.Tarball.check ()"
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
function Backup.Tarball.getPrefix()
{
    echo -e "backup-$(basename $OX_BACKUP_ITEM)-"
}


###
# Retourne l'extension de l'archive
##
function Backup.Tarball.getExtension()
{
    echo -e $(Compression.tar.extension $OX_BACKUP_ARCHIVE_COMPRESS)
}


###
# Fait la sauvegarde
##
function Backup.Tarball.doBackup()
{
    debug "Backup.Tarball.doBackup()"

    Compression.tar.create "$OX_BACKUP_ITEM" "$OX_BACKUP_ARCHIVE" "" "$(Compression.tar.mode $OX_BACKUP_ARCHIVE_COMPRESS)"
    return $?
}
