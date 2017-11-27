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



###
# Chargement des librairies requis
##
olixmodule_backup_require_libraries()
{
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
