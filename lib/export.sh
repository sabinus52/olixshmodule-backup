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


###
# Transfert le fichier backup vers un serveur SSH
##
function Backup.export.scp()
{
    debug "Backup.export.scp ()"
    local PARAM

    [[ -n $OLIX_MODULE_BACKUP_EXPORT_PASS ]] && PARAM="$PARAM -i $OLIX_MODULE_BACKUP_EXPORT_PASS"

    debug "scp $PARAM $OLIX_MODULE_BACKUP_INSTANCE_FILE $OLIX_MODULE_BACKUP_EXPORT_USER@$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        scp $PARAM "$OLIX_MODULE_BACKUP_INSTANCE_FILE" $OLIX_MODULE_BACKUP_EXPORT_USER@$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH 2>> ${OLIX_LOGGER_FILE_ERR}
    else
        scp $PARAM "$OLIX_MODULE_BACKUP_INSTANCE_FILE" $OLIX_MODULE_BACKUP_EXPORT_USER@$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
    fi

    return $?
}
