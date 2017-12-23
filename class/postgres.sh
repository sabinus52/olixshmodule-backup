###
# Classe de la méthode de sauvegarde POSTGRES du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des bases
##
function Backup.Postgres.initialize()
{
    debug "Backup.Postgres.initialize ()"

    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_USER ]] && OLIX_MODULE_BACKUP_POSTGRES_USER=$OLIX_MODULE_POSTGRES_USER
    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_PASS ]] && OLIX_MODULE_BACKUP_POSTGRES_PASS=$OLIX_MODULE_POSTGRES_PASS
    OLIX_MODULE_POSTGRES_USER=$OLIX_MODULE_BACKUP_POSTGRES_USER
    OLIX_MODULE_POSTGRES_PASS=$OLIX_MODULE_BACKUP_POSTGRES_PASS

    Backup.initialize "Postgres" "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_POSTGRES_COMPRESS" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
}


###
# Retourne le titre du rapport
##
function Backup.Postgres.getTitle()
{
    echo -n "Sauvegarde de la base %s"
}


###
# Vérifie la base à sauvegarder
##
function Backup.Postgres.check()
{
    debug "Backup.Postgres.check ()"
    if  ! Postgres.base.exists $OX_BACKUP_ITEM; then
        warning "La base \"$OX_BACKUP_ITEM\" n'existe pas"
        return 1
    fi
    return 0
}


###
# Retourne le préfixe de l'archive
##
function Backup.Postgres.getPrefix()
{
    echo -n "dump-$OX_BACKUP_ITEM-"
}


###
# Retourne l'extension de l'archive
##
function Backup.Postgres.getExtension()
{
    local EXT=$(Compression.extension $OX_BACKUP_ARCHIVE_COMPRESS)
    [[ -n $EXT ]] && echo -n $(Postgres.base.dump.ext 'c') || echo -n $(Postgres.base.dump.ext 't')
}


###
# Fait la sauvegarde
##
function Backup.Postgres.doBackup()
{
    debug "Backup.Postgres.doBackup()"

    local EXT=$(Compression.extension $OX_BACKUP_ARCHIVE_COMPRESS)
    local FORMAT='t'
    [[ -n $EXT ]] && FORMAT='c'

    Postgres.base.backup "$OX_BACKUP_ITEM" "$OX_BACKUP_ARCHIVE" $FORMAT "$OX_BACKUP_ARCHIVE_COMPRESS"
    return $?
}
