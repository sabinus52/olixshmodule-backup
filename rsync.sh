###
# Sauvegarde d'un dossier sur le serveur local en mode rsync
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##



###
# Vérification des paramètres
##
IS_ERROR=false

if [[ -z $OLIX_MODULE_BACKUP_RSYNC_FOLDERS ]]; then
    Module.execute.usage "rsync"
    critical "Chemin complet du dossier à sauvegarder manquant"
fi

Backup.check.repository
[[ $? -gt 100 ]] && critical "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'est pas accessible"


###
# Initialisation
##
Report.initialize "$OLIX_MODULE_BACKUP_REPORT_FORMAT" \
    "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "rapport-backup-rsync" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL" \
    "$OLIX_MODULE_BACKUP_REPORT_EMAIL"

Print.head1 "Sauvegarde des dossiers %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
for FOLDER in $OLIX_MODULE_BACKUP_RSYNC_FOLDERS; do
    info "Sauvegarde du dossier '$FOLDER'"
    Backup.Rsync.initialize
    Backup.doBackup "$FOLDER"
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
#Backup.terminate $IS_ERROR
