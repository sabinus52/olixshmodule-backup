###
# Classe de la méthode de sauvegarde POSTGRES du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des bases
# @param $1 : Compression
##
function Backup.Postgres.initialize()
{
    debug "Backup.Postgres.initialize ($1)"

    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_USER ]] && OLIX_MODULE_BACKUP_POSTGRES_USER=$OLIX_MODULE_POSTGRES_USER
    [[ -z $OLIX_MODULE_BACKUP_POSTGRES_PASS ]] && OLIX_MODULE_BACKUP_POSTGRES_PASS=$OLIX_MODULE_POSTGRES_PASS
    OLIX_MODULE_POSTGRES_USER=$OLIX_MODULE_BACKUP_POSTGRES_USER
    OLIX_MODULE_POSTGRES_PASS=$OLIX_MODULE_BACKUP_POSTGRES_PASS

    OX_BACKUP_METHOD="Postgres"
    OX_BACKUP_ARCHIVE_COMPRESS=$1
    Backup.repository.create
    return $?
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


###
# Transfert du fichier de backup sur un serveur distant
# @param $1 : Méthode de transfert
# @param $2 : Emplacement sur le serveur distant
##
function Backup.Postgres.export()
{
    debug "Backup.Postgres.export ($1, $2)"

    case $(String.lower $1) in
        ftp)
            Ftp.put "$OX_BACKUP_ARCHIVE" "$2"
            return $?
            ;;
        ssh)
            Scp.put "$OX_BACKUP_ARCHIVE" "$2"
            return $?
            ;;
    esac

    return 0
}
