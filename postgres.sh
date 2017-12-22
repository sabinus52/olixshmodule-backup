###
# Sauvegarde d'une base de données d'un serveur PostgreSQL
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
if [[ $OLIX_MODULE_BACKUP_POSTGRES_BASES == '_ALL_' || $OLIX_MODULE_BACKUP_ALLBASES == true ]]; then
    OLIX_MODULE_BACKUP_POSTGRES_BASES=$(Postgres.server.databases)
fi
if [[ -z $OLIX_MODULE_BACKUP_POSTGRES_BASES ]]; then
    Module.execute.usage "postgres"
    critical "Nom de la base de données manquante"
fi

Backup.check.repository
[[ $? -gt 100 ]] && critical "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'est pas accessible"


###
# Initialisation
##
Report.initialize "$OLIX_MODULE_BACKUP_REPORT_FORMAT" \
    "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "rapport-dump-postgres" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL" \
    "$OLIX_MODULE_BACKUP_REPORT_EMAIL"

Print.head1 "Sauvegarde des bases PostgreSQL %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
for BASE in $OLIX_MODULE_BACKUP_POSTGRES_BASES; do
    info "Sauvegarde de la base '$BASE'"
    Backup.Postgres.initialize
    Backup.doBackup "$BASE"
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
Backup.terminate $IS_ERROR
