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
    Backup.check.compress $1
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
    Backup.yaml.load $OLIX_MODULE_BACKUP_CONFYML || critical "Impossible de lire le fichier de conf \"$OLIX_MODULE_BACKUP_CONFYML\""
    Backup.yaml.setAll
fi



###
# Traitement
##
Print.head2 "Test de la configuration"


# Paramètre sur le dépôt
Backup.check.repository
Print.check $? "Dossier de stockage ${Ccyan}$OLIX_MODULE_BACKUP_REPOSITORY_ROOT${CVOID}"
case $? in
      1) warning "Création du dossier inexistant \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\"";;
    101) error "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'a pas les droits en écriture";;
    102) error "Impossible de créer le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\"";;
    103) error "Impossible de mettre les droits \"$OLIX_MODULE_BACKUP_REPOSITORY_CHMOD\" sur \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\"";;
esac


# Paramètre sur les archives
Backup.check.ttl
Print.check $? "Durée de rétention des sauvegardes ${Ccyan}$OLIX_MODULE_BACKUP_ARCHIVE_TTL${CVOID}"
case $? in
    101) error "La valeur de la durée n'est pas un entier";;
esac


# Liste des différentes méthodes de sauvegarde
for METHOD in $OLIX_MODULE_BACKUP_METHOD; do
    Backup.check.method.exists $METHOD
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
            [[ -z $OLIX_MODULE_BACKUP_TARBALL_FOLDERS ]] && warning "Aucun dossier à sauvegarder"
            for I in $OLIX_MODULE_BACKUP_TARBALL_FOLDERS; do
                Backup.check.folder $I
                Print.check $? "Sauvegarde du dossier ${Ccyan}$I${CVOID}"
                case $? in
                    101) error "Le dossier \"$I\" n'existe pas";;
                    102) error "Le dossier \"$I\" ne peut être lu";;
                esac
            done
            __check_compress "$OLIX_MODULE_BACKUP_TARBALL_COMPRESS" "Compression des archives de dossiers au format ${Ccyan}$OLIX_MODULE_BACKUP_TARBALL_COMPRESS${CVOID}"
            ;;

        rsync)
            # Check RSYNC
            [[ -z $OLIX_MODULE_BACKUP_RSYNC_FOLDERS ]] && warning "Aucun dossier à sauvegarder"
            for I in $OLIX_MODULE_BACKUP_RSYNC_FOLDERS; do
                Backup.check.folder $I
                Print.check $? "Sauvegarde du dossier ${Ccyan}$I${CVOID}"
                case $? in
                    101) error "Le dossier \"$I\" n'existe pas";;
                    102) error "Le dossier \"$I\" ne peut être lu";;
                esac
            done
            ;;

        mysql)
            # Check MYSQL
            Backup.Mysql.initialize
            Backup.check.sgbd 'Mysql'
            Print.check $? "Test de la connexion au serveur MySQL ${Ccyan}$OLIX_MODULE_MYSQL_USER@$OLIX_MODULE_MYSQL_HOST${CVOID}"
            [[ $OLIX_MODULE_BACKUP_MYSQL_BASES == "_ALL_" ]] && OLIX_MODULE_BACKUP_MYSQL_BASES=$(Mysql.server.databases)

            [[ -z $OLIX_MODULE_BACKUP_MYSQL_BASES ]] && warning "Aucune base MySQL à sauvegarder"
            for I in $OLIX_MODULE_BACKUP_MYSQL_BASES; do
                Backup.check.base 'Mysql' $I
                Print.check $? "Sauvegarde de la base ${Ccyan}$I${CVOID}"
                case $? in
                    101) error "Le base \"$I\" n'existe pas";;
                esac
            done
            __check_compress "$OLIX_MODULE_BACKUP_MYSQL_COMPRESS" "Compression des dump MySQL au format ${Ccyan}$OLIX_MODULE_BACKUP_MYSQL_COMPRESS${CVOID}"
            ;;

        postgres)
            # Check POSTGRESQL
            Backup.Postgres.initialize
            Backup.check.sgbd 'Postgres'
            Print.check $? "Test de la connexion au serveur PostgreSQL ${Ccyan}$OLIX_MODULE_POSTGRES_USER@$OLIX_MODULE_POSTGRES_HOST${CVOID}"
            [[ $OLIX_MODULE_BACKUP_POSTGRES_BASES == "_ALL_" ]] && OLIX_MODULE_BACKUP_POSTGRES_BASES=$(Postgres.server.databases)

            [[ -z $OLIX_MODULE_BACKUP_POSTGRES_BASES ]] && warning "Aucune base PostgreSQL à sauvegarder"
            for I in $OLIX_MODULE_BACKUP_POSTGRES_BASES; do
                Backup.check.base 'Postgres' $I
                Print.check $? "Sauvegarde de la base ${Ccyan}$I${CVOID}"
                case $? in
                    101) error "Le base \"$I\" n'existe pas";;
                esac
            done
            __check_compress "$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS" "Compression des dump PostgreSQL au format ${Ccyan}$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS${CVOID}"
            ;;

    esac
done


# Paramètre de transfert
Backup.check.export
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
            Scp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            Backup.check.export.connect 'Scp'
            Print.check $? "Connexion au serveur ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST${CVOID}"
            case $? in
                101) error "Impossible de se connecter au serveur \"$OLIX_MODULE_BACKUP_EXPORT_HOST\"";;
            esac
            Backup.check.export.directory 'Scp'
            Print.check $? "Dossier de stockage distant ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH${CVOID}"
            case $? in
                101) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'est pas accessible en écriture";;
                102) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'existe pas ou est inaccessible";;
            esac
            ;;

        ftp)
            Ftp.initialize "$OLIX_MODULE_BACKUP_EXPORT_HOST" "$OLIX_MODULE_BACKUP_EXPORT_USER" "$OLIX_MODULE_BACKUP_EXPORT_PASS"
            Backup.check.export.connect 'Ftp'
            Print.check $? "Connexion au serveur ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST${CVOID}"
            case $? in
                101) error "Impossible de se connecter au serveur \"$OLIX_MODULE_BACKUP_EXPORT_HOST\"";;
            esac
            Backup.check.export.directory 'Ftp'
            Print.check $? "Dossier de stockage distant ${Ccyan}$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH${CVOID}"
            case $? in
                101) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'est pas accessible en écriture";;
                102) error "Le dossier distant \"$OLIX_MODULE_BACKUP_EXPORT_HOST:$OLIX_MODULE_BACKUP_EXPORT_PATH\" n'existe pas ou est inaccessible";;
            esac
            ;;
    esac
fi


# Paramètre du rapport
Backup.check.report.format
Print.check $? "Format de sortie du rapport ${Ccyan}$OLIX_MODULE_BACKUP_REPORT_FORMAT${CVOID}"
case $? in
    101) error "Le format de rapport \"${OLIX_MODULE_BACKUP_REPORT_FORMAT}\" est inconnu";;
esac

Backup.check.report.email
Print.check $? "Email d'envoi des rapports ${Ccyan}$OLIX_MODULE_BACKUP_REPORT_EMAIL${CVOID}"
case $? in
    1) warning "Pas d'email renseigné";;
esac
