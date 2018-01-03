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
    echo -n "Sauvegarde du dossier %s"
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
    echo -n "backup-$(basename $OX_BACKUP_ITEM)-"
}


###
# Retourne l'extension de l'archive
##
function Backup.Tarball.getExtension()
{
    echo -n $(Compression.tar.extension $OX_BACKUP_ARCHIVE_COMPRESS)
}


###
# Fait la sauvegarde
##
function Backup.Tarball.doBackup()
{
    debug "Backup.Tarball.doBackup()"
    local PWDTMP PARAM RET I

    PWDTMP=$(pwd)
    cd $OX_BACKUP_ITEM 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && cd $PWDTMP && return 1

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="--verbose"
    PARAM="$PARAM $(Compression.tar.mode $OX_BACKUP_ARCHIVE_COMPRESS)"
    for I in $OX_BACKUP_EXCLUDE; do
        PARAM="$PARAM --exclude=$I"
    done

    debug "tar --create --ignore-failed-read $PARAM --file $OX_BACKUP_ARCHIVE ."
    tar --create --ignore-failed-read $PARAM --file $OX_BACKUP_ARCHIVE . 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?

    cd $PWDTMP
    return $?
}
