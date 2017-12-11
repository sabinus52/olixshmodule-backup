###
# Librairies du dépôt pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie le dossier de sauvegarde
##
function Backup.Repository.check()
{
    debug "Backup.Repository.check ()"
    local CREATE=false

    # Si dossier existe
    if ! Directory.exists $OLIX_MODULE_BACKUP_REPOSITORY_ROOT; then
        mkdir $OLIX_MODULE_BACKUP_REPOSITORY_ROOT 2> ${OLIX_LOGGER_FILE_ERR} || return 102
        CREATE=true
    fi

    # Changement des droits
    chmod $OLIX_MODULE_BACKUP_REPOSITORY_CHMOD $OLIX_MODULE_BACKUP_REPOSITORY_ROOT 2> ${OLIX_LOGGER_FILE_ERR} || return 103

    # Si ecriture
    Directory.writable $OLIX_MODULE_BACKUP_REPOSITORY_ROOT || return 101

    [[ $CREATE == true ]] && return 1 || return 0
}
