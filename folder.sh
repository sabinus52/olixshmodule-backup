###
# Sauvegarde d'un dossier sur le serveur local
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

if [[ -z $OLIX_MODULE_BACKUP_FOLDERS ]]; then
    Module.execute.usage "folder"
    critical "Chemin complet du dossier à sauvegarder manquant"
fi

Backup.path.check $OLIX_MODULE_BACKUP_PATH



###
# Initialisation
##
Report.initialize "$OLIX_MODULE_BACKUP_REPORT" \
    "$OLIX_MODULE_BACKUP_PATH" "rapport-dump-folder" "$OLIX_MODULE_BACKUP_TTL" \
    "$OLIX_MODULE_BACKUP_EMAIL"

Print.head1 "Sauvegarde des dossiers %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
for FOLDER in $OLIX_MODULE_BACKUP_FOLDERS; do
    info "Sauvegarde du dossier '$FOLDER'"
    Backup.Instance.initialize "$OLIX_MODULE_BACKUP_PATH" "$OLIX_MODULE_BACKUP_COMPRESS" "$OLIX_MODULE_BACKUP_TTL"
    Backup.Instance.folder "$FOLDER"
    [[ $? -ne 0 ]] && error && IS_ERROR=true && continue
    Backup.Instance.terminate
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
Backup.terminate $IS_ERROR
