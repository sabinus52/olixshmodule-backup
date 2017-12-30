###
# Classe des archives
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



###
# Affecte le fichier de sauvegarde
# @param $1  : Prefixe du fichier
# @param $2  : Extension du fichier
##
function Backup.Archive.set()
{
    debug "Backup.setArchiveName ($1, $2)"
    [[ -z $1 ]] && critical "Préfixe du fichier de sauvegarde non renseigné"
    [[ -z $2 ]] && critical "Extension du fichier de sauvegarde non renseigné"
    OX_BACKUP_ARCHIVE_PREFIX=$1
    OX_BACKUP_ARCHIVE=$OX_BACKUP_PATH/$1$OLIX_SYSTEM_DATE-$(date '+%H%M').$2
}


###
# Retourne le nom complet du fichier de sauvegarde
##
function Backup.Archive.get()
{
    echo -e $OX_BACKUP_ARCHIVE
}


###
# Retourne la liste des archives courantes
##
function Backup.Archive.list()
{
    find $OX_BACKUP_PATH -mindepth 1 -maxdepth 1 -name "$OX_BACKUP_ARCHIVE_PREFIX*" -follow -printf "%f\n" | sort
}


###
# Retourne la liste des archives qui peuvent être purgées
##
function Backup.Archive.purged.list()
{
    find $OX_BACKUP_PATH -mindepth 1 -maxdepth 1 -name "$OX_BACKUP_ARCHIVE_PREFIX*" -follow -mmin +$OX_BACKUP_ARCHIVE_TTL -printf "%f\n" | sort
}


###
# Purge les fichiers
##
function Backup.Archive.purge()
{
    debug "Backup.Archive.purge ()"

    debug "find $OX_BACKUP_PATH -mindepth 1 -maxdepth 1 -name '$OX_BACKUP_ARCHIVE_PREFIX*' -follow -mmin +$OX_BACKUP_ARCHIVE_TTL"
    find $OX_BACKUP_PATH -mindepth 1 -maxdepth 1 -name "$OX_BACKUP_ARCHIVE_PREFIX*" -follow -mmin +$OX_BACKUP_ARCHIVE_TTL -exec rm -rf {} \; 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}
