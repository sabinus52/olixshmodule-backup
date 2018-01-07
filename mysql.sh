###
# Sauvegarde d'une base de données d'un serveur MySQL
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

# Si option --allbases définie, on récupère toutes les bases
if [[ $OLIX_MODULE_BACKUP_MYSQL_BASES == '_ALL_' || $OLIX_MODULE_BACKUP_ALLBASES == true ]]; then
    OLIX_MODULE_BACKUP_MYSQL_BASES=$(Mysql.server.databases)
fi
if [[ -z $OLIX_MODULE_BACKUP_MYSQL_BASES ]]; then
    Module.execute.usage "mysql"
    critical "Nom de la base de données manquante"
fi

Backup.check.repository
[[ $? -gt 100 ]] && critical "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'est pas accessible"


###
# Initialisation
##
Backup.initialize "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
[[ $? -ne 0 ]] && critical "Impossible d'initialiser la sauvegarde"

Report.initialize "$OLIX_MODULE_BACKUP_REPORT_FORMAT" \
    "$(Backup.repository.get)" "rapport-dump-mysql" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL" \
    "$OLIX_MODULE_BACKUP_REPORT_EMAIL"

Print.head1 "Sauvegarde des bases MySQL %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
Backup.Mysql.initialize "$OLIX_MODULE_BACKUP_MYSQL_COMPRESS"
for BASE in $OLIX_MODULE_BACKUP_MYSQL_BASES; do
    info "Sauvegarde de la base '$BASE'"
    Backup.Archive.doBackup "$BASE"
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
Backup.terminate $IS_ERROR
