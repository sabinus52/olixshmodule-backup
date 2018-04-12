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

###
# Si Fichier de configuration
##
if [[ -n $OLIX_MODULE_BACKUP_CONFYML ]]; then
    Backup.yaml.load $OLIX_MODULE_BACKUP_CONFYML || critical "Impossible de lire le fichier de conf \"$OLIX_MODULE_BACKUP_CONFYML\""
    Backup.yaml.setAll
fi

Backup.check.repository
[[ $? -gt 100 ]] && critical "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'est pas accessible"


###
# Initialisation
##
Backup.initialize "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_TARBALL_COMPRESS" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
[[ $? -ne 0 ]] && critical "Impossible d'initialiser la sauvegarde"

Report.initialize "$OLIX_MODULE_BACKUP_REPORT_FORMAT" \
    "$(Backup.repository.get)" "rapport-backup-rsync" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL" \
    "$OLIX_MODULE_BACKUP_REPORT_EMAIL"

Print.head1 "Sauvegarde des dossiers %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
Backup.Rsync.initialize
for FOLDER in $OLIX_MODULE_BACKUP_RSYNC_FOLDERS; do
    info "Sauvegarde du dossier '$FOLDER'"
    Backup.Archive.doBackup "$FOLDER" "$OLIX_MODULE_BACKUP_RSYNC_EXCLUDE"
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
Backup.terminate $IS_ERROR
