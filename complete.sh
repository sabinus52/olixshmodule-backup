###
# Sauvegarde complète du serveur local
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

Backup.check.repository
[[ $? -gt 100 ]] && critical "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'est pas accessible"


###
# Initialisation
##
Backup.initialize "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
Backup.repository.create
[[ $? -ne 0 ]] && critical "Impossible d'initialiser la sauvegarde"

Report.initialize "$OLIX_MODULE_BACKUP_REPORT_FORMAT" \
    "$(Backup.repository.get)" "rapport-backup" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL" \
    "$OLIX_MODULE_BACKUP_REPORT_EMAIL"

Print.head1 "Sauvegarde complete %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##
for METHOD in $OLIX_MODULE_BACKUP_METHOD; do

    case $METHOD in
        tarball)
            Backup.Tarball.initialize "$OLIX_MODULE_BACKUP_TARBALL_COMPRESS"
            for FOLDER in $OLIX_MODULE_BACKUP_TARBALL_FOLDERS; do
                info "Sauvegarde du dossier '$FOLDER'"
                Backup.Archive.doBackup "$FOLDER" "$OLIX_MODULE_BACKUP_TARBALL_EXCLUDE"
                [[ $? -ne 0 ]] && error && IS_ERROR=true
            done
            ;;
        mysql)
            Backup.Mysql.initialize "$OLIX_MODULE_BACKUP_MYSQL_COMPRESS"
            [[ $OLIX_MODULE_BACKUP_MYSQL_BASES == '_ALL_' ]] && OLIX_MODULE_BACKUP_MYSQL_BASES=$(Mysql.server.databases)
            for BASE in $OLIX_MODULE_BACKUP_MYSQL_BASES; do
                info "Sauvegarde de la base '$BASE'"
                Backup.Archive.doBackup "$BASE"
                [[ $? -ne 0 ]] && error && IS_ERROR=true
            done
            ;;
        postgres)
            Backup.Postgres.initialize "$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS"
            [[ $OLIX_MODULE_BACKUP_POSTGRES_BASES == '_ALL_' ]] && OLIX_MODULE_BACKUP_POSTGRES_BASES=$(Postgres.server.databases)
            for BASE in $OLIX_MODULE_BACKUP_POSTGRES_BASES; do
                info "Sauvegarde de la base '$BASE'"
                Backup.Archive.doBackup "$BASE"
                [[ $? -ne 0 ]] && error && IS_ERROR=true
            done
            ;;
        rsync)
            Backup.Rsync.initialize
            for FOLDER in $OLIX_MODULE_BACKUP_RSYNC_FOLDERS; do
                info "Sauvegarde du dossier '$FOLDER'"
                Backup.Archive.doBackup "$FOLDER" "$OLIX_MODULE_BACKUP_RSYNC_EXCLUDE"
                [[ $? -ne 0 ]] && error && IS_ERROR=true
            done
            ;;
    esac

done

info "Purge des sauvegardes"
Print.head2 "Purge des sauvegardes"
Backup.purge
[[ $? -ne 0 ]] && error && IS_ERROR=true


###
# FIN
##
Backup.terminate $IS_ERROR
