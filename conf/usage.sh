###
# Usage du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function olixmodule_backup_usage_main()
{
    debug "olixmodule_backup_usage_main ()"
    echo
    echo -e "Gestion des applications web"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} mysql     ${CVOID}  : Réalisation d'une sauvegarde des bases MySQL du serveur local"
    echo -e "${Cjaune} postgres  ${CVOID}  : Réalisation d'une sauvegarde des bases PostgeSQL du serveur local"
    echo -e "${Cjaune} folder    ${CVOID}  : Réalisation d'une sauvegarde de dossiers du serveur local"
    echo -e "${Cjaune} help      ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action MYSQL
##
function olixmodule_backup_usage_mysql()
{
    debug "olixmodule_backup_usage_mysql ()"
    echo
    echo -e "Réalisation d'une sauvegarde des bases MySQL du serveur local"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}backup ${CJAUNE}mysql${CVOID} ${CBLANC}[base1..baseN] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=$OLIX_MODULE_MYSQL_HOST ${CVOID}"; String.pad "--host=$OLIX_MODULE_MYSQL_HOST" 30 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=$OLIX_MODULE_MYSQL_PORT ${CVOID}"; String.pad "--port=$OLIX_MODULE_MYSQL_PORT" 30 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=$OLIX_MODULE_MYSQL_USER ${CVOID}"; String.pad "--user=$OLIX_MODULE_MYSQL_USER" 30 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; String.pad "--pass=" 30 " "; echo " : Password du serveur MYSQL"
    olixmodule_backup_usage_param
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(Mysql.server.databases); do
        Print.usage.item "$I" "Base de de données $I" 15
    done
}


###
# Usage de l'action POSTGRESQL
##
function olixmodule_backup_usage_postgres()
{
    debug "olixmodule_backup_usage_postgres ()"
    echo
    echo -e "Réalisation d'une sauvegarde des bases PostgreSQL du serveur local"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}backup ${CJAUNE}postgres${CVOID} ${CBLANC}[base1..baseN] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=$OLIX_MODULE_POSTGRES_HOST ${CVOID}"; String.pad "--host=$OLIX_MODULE_POSTGRES_HOST" 30 " "; echo " : Host du serveur PostgreSQL"
    echo -en "${CBLANC} --port=$OLIX_MODULE_POSTGRES_PORT ${CVOID}"; String.pad "--port=$OLIX_MODULE_POSTGRES_PORT" 30 " "; echo " : Port du serveur PostgreSQL"
    echo -en "${CBLANC} --user=$OLIX_MODULE_POSTGRES_USER ${CVOID}"; String.pad "--user=$OLIX_MODULE_POSTGRES_USER" 30 " "; echo " : User du serveur PostgreSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; String.pad "--pass=" 30 " "; echo " : Password du serveur PostgreSQL"
    olixmodule_backup_usage_param
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(Postgres.server.databases); do
        Print.usage.item "$I" "Base de de données $I" 15
    done
}


###
# Usage de l'action FOLDER
##
function olixmodule_backup_usage_folder()
{
    debug "olixmodule_backup_usage_folder ()"
    echo
    echo -e "Réalisation d'une sauvegarde de dossiers du serveur local"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}backup ${CJAUNE}folder${CVOID} ${CBLANC}[folder1..folderN] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_backup_usage_param
}


###
# Affiche les options des paramètres
##
function olixmodule_backup_usage_param()
{
    echo -en "${CBLANC} --path=$OLIX_MODULE_BACKUP_PATH ${CVOID}"; String.pad "--path=$OLIX_MODULE_BACKUP_PATH" 30 " "; echo " : Chemin de stockage des backups"
    echo -en "${CBLANC} --ttl=$OLIX_MODULE_BACKUP_TTL ${CVOID}"; String.pad "--ttl=$OLIX_MODULE_BACKUP_TTL" 30 " "; echo " : Nombre de jours avant la purge des anciens backups"
    echo -en "${CBLANC} --gz|--bz2|--noz ${CVOID}"; String.pad "--gz|--bz2|--noz" 30 " "; echo " : Compression du dump au format gzip ou bzip2 ou pas de compression"
    echo -en "${CBLANC} --html ${CVOID}"; String.pad "--html" 30 " "; echo " : Rapport au format HTML sinon au format TEXT par défaut"
}

