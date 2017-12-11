###
# Test de la configuration du module backup
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##

###
# Vérifie la compression
# @param $1 : Type de compression
# @param $2 : Texte de retour
##
__check_compress()
{
    Backup.Archive.check.compress $1
    Print.check $? "$2"
    case $? in
          1) warning "Il est conseillé d'utiliser un moyen de compression";;
        101) error "Le type de compression \"$1\" n'est pas disponible";;
        201) error "La commande \"gzip\" n'est pas installée";;
        202) error "La commande \"bzip2\" n'est pas installée";;
    esac
}



###
# Si Fichier de configuration
##
if [[ -n $OLIX_MODULE_BACKUP_CONFYML ]]; then
    Backup.ConfigYML.load $OLIX_MODULE_BACKUP_CONFYML || critical "Impossible de lire le fichier de conf \"$OLIX_MODULE_BACKUP_CONFYML\""
    Backup.ConfigYML.setAll
fi



###
# Traitement
##
Print.head2 "Test de la configuration"


# Paramètre sur le dépôt
Backup.Repository.check
Print.check $? "Dossier de stockage ${Ccyan}$OLIX_MODULE_BACKUP_REPOSITORY_ROOT${CVOID}"
case $? in
      1) warning "Création du dossier inexistant \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\"";;
    101) error "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'a pas les droits en écriture";;
    102) error "Impossible de créer le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\"";;
    103) error "Impossible de mettre les droits \"$OLIX_MODULE_BACKUP_REPOSITORY_CHMOD\" sur \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\"";;
esac


# Paramètre sur les archives
Backup.Archive.check.purge
Print.check $? "Durée de rétention des sauvegardes ${Ccyan}$OLIX_MODULE_BACKUP_ARCHIVE_TTL${CVOID}"
case $? in
    101) error "La valeur de la durée n'est pas un entier";;
esac


# Liste des différentes méthodes de sauvegarde
for METHOD in $OLIX_MODULE_BACKUP_METHOD; do
    Backup.Method.check.exists $METHOD
    Print.check $? "Méthode de sauvegarde ${Ccyan}$METHOD${CVOID}"
    case $? in
        101) error "La methode \"$METHOD\" n'est pas disponible";;
        201) error "La commande \"tar\" n'est pas installée";;
        202) error "La commande \"mysqldump\" n'est pas installée";;
        203) error "La commande \"pg_dump\" n'est pas installée";;
    esac

    case $METHOD in

        tarball)
            # Check TARBALL
            Backup.Method.Tarball.initialize
            Backup.Method.Tarball.check.folders
            Print.check $? "Sauvegarde des dossiers ${Ccyan}$OLIX_MODULE_BACKUP_TARBALL_FOLDERS${CVOID}"
            case $? in
                  1) warning "Aucun dossier à sauvegarder";;
                101) error "Un des dossier n'existe pas";;
                102) error "Un des dossier ne peut être lu";;
            esac
            __check_compress "$OLIX_MODULE_BACKUP_TARBALL_COMPRESS" "Compression des archives de dossiers au format ${Ccyan}$OLIX_MODULE_BACKUP_TARBALL_COMPRESS${CVOID}"
            ;;

        mysql)
            # Check MYSQL
            Backup.Method.Mysql.initialize
            Backup.Method.Mysql.check.server
            Print.check $? "Test de la connexion au serveur MySQL ${Ccyan}$OLIX_MODULE_MYSQL_USER@$OLIX_MODULE_MYSQL_HOST${CVOID}"
            if [[ $OLIX_MODULE_BACKUP_MYSQL_BASES == "__ALL__" ]]; then
                OLIX_MODULE_BACKUP_MYSQL_BASES=$(Mysql.server.databases)
            fi
            Backup.Method.Mysql.check.bases
            Print.check $? "Sauvegarde des bases MySQL ${Ccyan}$OLIX_MODULE_BACKUP_MYSQL_BASES${CVOID}"
            case $? in
                  1) warning "Aucune base MySQL à sauvegarder";;
                101) error "Une des bases MySQL n'existe pas";;
            esac
            __check_compress "$OLIX_MODULE_BACKUP_MYSQL_COMPRESS" "Compression des dump MySQL au format ${Ccyan}$OLIX_MODULE_BACKUP_MYSQL_COMPRESS${CVOID}"
            ;;

        postgres)
            # Check POSTGRESQL
            Backup.Method.Postgres.initialize
            Backup.Method.Postgres.check.server
            Print.check $? "Test de la connexion au serveur PostgreSQL ${Ccyan}$OLIX_MODULE_POSTGRES_USER@$OLIX_MODULE_POSTGRES_HOST${CVOID}"

            if [[ $OLIX_MODULE_BACKUP_POSTGRES_BASES == "__ALL__" ]]; then
                OLIX_MODULE_BACKUP_POSTGRES_BASES=$(Postgres.server.databases)
            fi
            Backup.Method.Postgres.check.bases
            Print.check $? "Sauvegarde des bases PostgreSQL ${Ccyan}$OLIX_MODULE_BACKUP_POSTGRES_BASES${CVOID}"
            case $? in
                  1) warning "Aucune base PostgreSQL à sauvegarder";;
                101) error "Une des bases PostgreSQL n'existe pas";;
            esac
            __check_compress "$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS" "Compression des dump PostgreSQL au format ${Ccyan}$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS${CVOID}"
            ;;

    esac
done


# Paramètre de transfert
Backup.Export.check
__EXPORT=$?
Print.check $__EXPORT "Mode de transfert des sauvegardes ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_MODE${CVOID}"
case $? in
      1) warning "Il est conseillé d'utiliser un mode de transfert";;
    101) error "Le mode de transfert \"${OLIX_MODULE_BACKUP_EXPORT_MODE}\" n'est pas disponible";;
    201) error "La commande \"lftp\" n'est pas installée";;
    202) error "La commande \"scp\" n'est pas installée";;
esac

if [[ $__EXPORT -eq 0 ]]; then
    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in

        ssh)
            Backup.Export.SSH.check.connect
            Print.check $? "Connexion au serveur ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST${CVOID}"
            case $? in
                101) error "Impossible de se connecter au serveur \"$OLIX_MODULE_BACKUP_EXPORT_HOST\"";;
            esac
            Backup.Export.SSH.check.directory
            Print.check $? "Dossier de stockage distant ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH${CVOID}"
            case $? in
                101) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'est pas accessible en écriture";;
                102) error "Impossible de tester le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\"";;
                103) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'est pas un répertoire";;
                104) error "Impossible de tester le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\"";;
                105) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'existe pas ou est inaccessible";;
                106) error "Impossible de tester le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\"";;
            esac
            ;;

        ftp)
            Ftp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            Backup.Export.FTP.check.connect
            Print.check $? "Connexion au serveur ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST${CVOID}"
            case $? in
                101) error "Impossible de se connecter au serveur \"$OLIX_MODULE_BACKUP_EXPORT_HOST\"";;
            esac
            Backup.Export.FTP.check.directory
            Print.check $? "Dossier de stockage distant ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH${CVOID}"
            case $? in
                101) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'est pas accessible en écriture";;
                105) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'existe pas ou est inaccessible";;
            esac
            ;;
    esac
fi


# Paramètre du rapport
Backup.Report.check.format
Print.check $? "Format de sortie du rapport ${Ccyan}$OLIX_MODULE_BACKUP_REPORT_FORMAT${CVOID}"
case $? in
    101) error "Le format de rapport \"${OLIX_MODULE_BACKUP_REPORT_FORMAT}\" est inconnu";;
esac

Backup.Report.check.email
Print.check $? "Email d'envoi des rapports ${Ccyan}$OLIX_MODULE_BACKUP_REPORT_EMAIL${CVOID}"
case $? in
    1) warning "Pas d'email renseigné";;
esac
