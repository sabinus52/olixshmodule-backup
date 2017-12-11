###
# Librairies d'export FTP des sauvegardes
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie la connexion à un serveur FTP
##
function Backup.Export.FTP.check.connect()
{
    debug "Backup.Export.FTP.check.connect ()"
    Ftp.check.connection && return 0 || return 101
}


###
# Vérifie un dossier distant
##
function Backup.Export.FTP.check.directory()
{
    debug "Backup.Export.FTP.check.directory ()"
    local TEST_EXISTS
    local TEST_ISDIR
    local TEST_WRITABLE

    if Ftp.check.directory $OLIX_MODULE_BACKUP_EXPORT_PATH; then
        if Ftp.check.writable $OLIX_MODULE_BACKUP_EXPORT_PATH; then
            rm -f $OLIX_LOGGER_FILE_ERR
            return 0
        else
            rm -f $OLIX_LOGGER_FILE_ERR
            return 101
        fi
    else
        rm -f $OLIX_LOGGER_FILE_ERR
        return 105
    fi
}



###
# Transfert le fichier backup vers un serveur FTP
##
function Backup.export.ftp()
{
    debug "Backup.export.ftp ()"

    Ftp.lftp.put "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS" \
            "$OLIX_MODULE_BACKUP_EXPORT_PATH" "$OLIX_MODULE_BACKUP_INSTANCE_FILE"

    return $?
}



Backup.export.ftp.getTarget()
{
    debug "Backup.export.ftp.getTarget ()"

    Ftp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
    echo -n $(Ftp.getConnection)
}
