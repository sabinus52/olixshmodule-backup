###
# Librairies d'export SSH des sauvegardes
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Retourne la chaine de connexion SSH
##
function Backup.Export.SSH.getTarget()
{
    debug "Backup.Export.SSH.getTarget ()"
    local PARAM

    [[ -n $OLIX_MODULE_BACKUP_EXPORT_PASS ]] && PARAM="-i $OLIX_MODULE_BACKUP_EXPORT_PASS"
    if [[ -z $OLIX_MODULE_BACKUP_EXPORT_USER ]]; then
        echo -n "$PARAM $OLIX_MODULE_BACKUP_EXPORT_HOST"
    else
        echo -n "$PARAM $OLIX_MODULE_BACKUP_EXPORT_USER@$OLIX_MODULE_BACKUP_EXPORT_HOST"
    fi
}


###
# Vérifie la connexion à un serveur SSH
##
function Backup.Export.SSH.check.connect()
{
    debug "Backup.Export.SSH.check.connect ()"

    if ssh -n -- $(Backup.Export.SSH.getTarget) "test -d /" 2>/dev/null; then
        return 0
    else
        return 101
    fi

}


###
# Vérifie un dossier distant
##
function Backup.Export.SSH.check.directory()
{
    debug "Backup.Export.SSH.check.directory ()"
    local SSH_TARGET=$(Backup.Export.SSH.getTarget)
    local TEST_EXISTS
    local TEST_ISDIR
    local TEST_WRITABLE

    TEST_EXISTS=$(ssh -n -- $SSH_TARGET "[ -e $OLIX_MODULE_BACKUP_EXPORT_PATH ] || echo 'ko'")
    if [[ $? -eq 0 ]]; then
        if [[ -z $TEST_EXISTS ]]; then
            TEST_ISDIR=$(ssh -n -- $SSH_TARGET "[ -d $OLIX_MODULE_BACKUP_EXPORT_PATH ] || echo 'ko'")
            if [[ $? -eq 0 ]]; then
                if [[ -z $TEST_ISDIR ]]; then
                    info "Remote directory '$OLIX_MODULE_BACKUP_EXPORT_PATH' exists"
                    TEST_WRITABLE=$(ssh -n -- $SSH_TARGET "[ -w $OLIX_MODULE_BACKUP_EXPORT_PATH ] || echo 'ko'")
                    if [[ $? -eq 0 ]]; then
                        if [[ -z $TEST_WRITABLE ]]; then
                            return 0 # target directory is writable
                        else
                            return 101 # target directory is NOT writable"
                        fi
                    else
                        return 102 # could not check directory
                    fi
                else
                    return 103 # target exists but is NOT a directory"
                fi
            else
                return 104 # could not check directory
            fi
        else
            return 105 # target directory does NOT exist or is NOT reachable"
        fi
    else
        return 106 # could not check directory
    fi
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
