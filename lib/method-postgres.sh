###
# Librairies de la méthode de sauvegarde POSTGRES du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des bases PostgreSQL
##
function Backup.Method.Postgres.initialize()
{
    debug "Backup.Method.Postgres.initialize ()"

    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_USER ]] && OLIX_MODULE_BACKUP_POSTGRES_USER=$OLIX_MODULE_POSTGRES_USER
    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_PASS ]] && OLIX_MODULE_BACKUP_POSTGRES_PASS=$OLIX_MODULE_POSTGRES_PASS
    OLIX_MODULE_POSTGRES_USER=$OLIX_MODULE_BACKUP_POSTGRES_USER
    OLIX_MODULE_POSTGRES_PASS=$OLIX_MODULE_BACKUP_POSTGRES_PASS
}


###
# Vérifie le serveur PostgreSQL
##
function Backup.Method.Postgres.check.server()
{
    debug "Backup.Method.Postgres.check.server ()"
    Postgres.server.check && return 0 || return 101
}


###
# Test l'existence des bases PostgreSQL
##
function Backup.Method.Postgres.check.bases()
{
    debug "Backup.Method.Postgres.check.bases ()"
    local I

    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_BASES ]] && return 1
    for I in $OLIX_MODULE_BACKUP_POSTGRES_BASES; do
        if  ! Postgres.base.exists $I; then
            info "La base MySQL \"$I\" n'existe pas"
            return 101
        fi
    done
    return 0
}
