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
Backup.initialize "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
[[ $? -ne 0 ]] && critical "Impossible d'initialiser la sauvegarde"

Report.initialize "$OLIX_MODULE_BACKUP_REPORT_FORMAT" \
    "$(Backup.repository.get)" "rapport-dump-postgres" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL" \
    "$OLIX_MODULE_BACKUP_REPORT_EMAIL"

Print.head1 "Sauvegarde des bases PostgreSQL %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
Backup.Postgres.initialize "$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS"
for BASE in $OLIX_MODULE_BACKUP_POSTGRES_BASES; do
    info "Sauvegarde de la base '$BASE'"
    Backup.Archive.doBackup "$BASE"
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
Backup.terminate $IS_ERROR
