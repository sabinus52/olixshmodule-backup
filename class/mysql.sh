###
# Classe de la méthode de sauvegarde MYSQL du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des bases
# @param $1 : Compression
##
function Backup.Mysql.initialize()
{
    debug "Backup.Mysql.initialize ($1)"

    [[ -z $OLIX_MODULE_BACKUP_MYSQL_USER ]] && OLIX_MODULE_BACKUP_MYSQL_USER=$OLIX_MODULE_MYSQL_USER
    [[ -z $OLIX_MODULE_BACKUP_MYSQL_PASS ]] && OLIX_MODULE_BACKUP_MYSQL_PASS=$OLIX_MODULE_MYSQL_PASS
    OLIX_MODULE_MYSQL_USER=$OLIX_MODULE_BACKUP_MYSQL_USER
    OLIX_MODULE_MYSQL_PASS=$OLIX_MODULE_BACKUP_MYSQL_PASS

    OX_BACKUP_METHOD="Mysql"
    OX_BACKUP_ARCHIVE_COMPRESS=$1
    Backup.repository.create
    return $?
}


###
# Retourne le titre du rapport
##
function Backup.Mysql.getTitle()
{
    echo -n "Sauvegarde de la base %s"
}


###
# Vérifie la base à sauvegarder
##
function Backup.Mysql.check()
{
    debug "Backup.Mysql.check ()"
    if  ! Mysql.base.exists $OX_BACKUP_ITEM; then
        warning "La base \"$OX_BACKUP_ITEM\" n'existe pas"
        return 1
    fi
    return 0
}


###
# Retourne le préfixe de l'archive
##
function Backup.Mysql.getPrefix()
{
    echo -n "dump-$OX_BACKUP_ITEM-"
}


###
# Retourne l'extension de l'archive
##
function Backup.Mysql.getExtension()
{
    local EXT=$(Compression.extension $OX_BACKUP_ARCHIVE_COMPRESS)
    echo -n $(Mysql.base.dump.ext)
    [[ -n $EXT ]] && echo -n ".$EXT"
}


###
# Fait la sauvegarde
##
function Backup.Mysql.doBackup()
{
    debug "Backup.Mysql.doBackup ()"

    Mysql.base.backup "$OX_BACKUP_ITEM" "$OX_BACKUP_ARCHIVE" "$OX_BACKUP_ARCHIVE_COMPRESS"
    return $?
}

###
# Transfert du fichier de backup sur un serveur distant
# @param $1 : Méthode de transfert
# @param $2 : Emplacement sur le serveur distant
##
function Backup.Mysql.export()
{
    debug "Backup.Mysql.export ($1, $2)"

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
