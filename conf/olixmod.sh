###
# Module de la sauvegarde des bases de données et répertoires
# ==============================================================================
# @package olixsh
# @module backup
# @label Sauvegarde des base de données et répertoires
# @author Olivier <sabinus52@gmail.com>
##



###
# Paramètres du modules
##
OLIX_MODULE_BACKUP_CONFYML=""
OLIX_MODULE_BACKUP_CONFYML_PREFIX="OLIX_MODULE_BACKUP_CONFYML_"
OLIX_MODULE_BACKUP_ALLBASES=false



###
# Chargement des librairies requis
##
olixmodule_backup_require_libraries()
{
    load "utils/compression.sh"
    load "utils/filesystem.sh"
    load "utils/ftp.sh"
    load "utils/scp.sh"
    load "utils/report.sh"
    load "utils/mail.sh"
    load "utils/yaml.sh"

    Module.installed 'mysql' && load "modules/mysql/lib/*" && Config.load 'mysql'
    Module.installed 'postgres' && load "modules/postgres/lib/*" && Config.load 'postgres'

    load "modules/backup/class/*"
    load "modules/backup/lib/*"
}


###
# Retourne la liste des modules requis
##
olixmodule_backup_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmodule_backup_require_binary()
{
    echo -e ""
}


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_backup_include_begin()
# {
# }


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_backup_include_end()
# {
#    echo "FIN"
# }


###
# Sortie de liste pour la completion
##
# olixmodule_backup_list()
# {
# }
