###
# Librairies de la méthode de sauvegarde MYSQL du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des bases MySQL
##
function Backup.Method.Mysql.initialize()
{
    debug "Backup.Method.Mysql.initialize ()"

    [[ -z $OLIX_MODULE_BACKUP_MYSQL_USER ]] && OLIX_MODULE_BACKUP_MYSQL_USER=$OLIX_MODULE_MYSQL_USER
    [[ -z $OLIX_MODULE_BACKUP_MYSQL_PASS ]] && OLIX_MODULE_BACKUP_MYSQL_PASS=$OLIX_MODULE_MYSQL_PASS
    OLIX_MODULE_MYSQL_USER=$OLIX_MODULE_BACKUP_MYSQL_USER
    OLIX_MODULE_MYSQL_PASS=$OLIX_MODULE_BACKUP_MYSQL_PASS
}


###
# Vérifie le serveur MySQL
##
function Backup.Method.Mysql.check.server()
{
    debug "Backup.Method.Mysql.check.server ()"
    Mysql.server.check && return 0 || return 101
}


###
# Test l'existence des bases MySQL
##
function Backup.Method.Mysql.check.bases()
{
    debug "Backup.Method.Mysql.check.bases ()"
    local I

    [[ -z $OLIX_MODULE_BACKUP_MYSQL_BASES ]] && return 1
    for I in $OLIX_MODULE_BACKUP_MYSQL_BASES; do
        if  ! Mysql.base.exists $I; then
            info "La base MySQL \"$I\" n'existe pas"
            return 101
        fi
    done
    return 0
}
