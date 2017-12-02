###
# Librairies d'export des sauvegardes
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


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
