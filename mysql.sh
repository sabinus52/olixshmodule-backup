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
if [[ $OLIX_MODULE_BACKUP_ALLBASES == true ]]; then
    OLIX_MODULE_BACKUP_BASES=$(Mysql.server.databases)
fi
if [[ -z $OLIX_MODULE_BACKUP_BASES ]]; then
    Module.execute.usage "mysql"
    critical "Nom de la base de données manquante"
fi

Backup.path.check $OLIX_MODULE_BACKUP_PATH



###
# Initialisation
##
Report.initialize "$OLIX_MODULE_BACKUP_REPORT" \
    "$OLIX_MODULE_BACKUP_PATH" "rapport-dump-mysql" "$OLIX_MODULE_BACKUP_TTL" \
    "$OLIX_MODULE_BACKUP_EMAIL"

Print.head1 "Sauvegarde des bases MySQL %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
for BASE in $OLIX_MODULE_BACKUP_BASES; do
    info "Sauvegarde de la base '$BASE'"
    Backup.Instance.initialize "$OLIX_MODULE_BACKUP_PATH" "$OLIX_MODULE_BACKUP_COMPRESS" "$OLIX_MODULE_BACKUP_TTL"
    Backup.mysql.base "$BASE"
    [[ $? -ne 0 ]] && error && IS_ERROR=true && continue
    Backup.Instance.terminate
    [[ $? -ne 0 ]] && error && IS_ERROR=true
done


###
# FIN
##
Backup.terminate $IS_ERROR
