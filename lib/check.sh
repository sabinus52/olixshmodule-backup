###
# Librairies de vérification pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie le dossier de sauvegarde
##
function Backup.check.repository()
{
    debug "Backup.Repository.check () : $OLIX_MODULE_BACKUP_REPOSITORY_ROOT | $OLIX_MODULE_BACKUP_REPOSITORY_CHMOD"
    local CREATE=false

    # Si dossier existe
    if ! Directory.exists $OLIX_MODULE_BACKUP_REPOSITORY_ROOT; then
        mkdir $OLIX_MODULE_BACKUP_REPOSITORY_ROOT 2> ${OLIX_LOGGER_FILE_ERR} || return 102
        CREATE=true
    fi

    # Changement des droits
    chmod $OLIX_MODULE_BACKUP_REPOSITORY_CHMOD $OLIX_MODULE_BACKUP_REPOSITORY_ROOT 2> ${OLIX_LOGGER_FILE_ERR} || return 103

    # Si ecriture
    Directory.writable $OLIX_MODULE_BACKUP_REPOSITORY_ROOT || return 101

    [[ $CREATE == true ]] && return 1 || return 0
}


###
# Vérifie le valeur du ttl de la purge
##
function Backup.check.ttl()
{
    debug "Backup.check.ttl ()"

    Digit.integer $OLIX_MODULE_BACKUP_ARCHIVE_TTL && return 0 || return 101
}


###
# Vérifie le valeur de compression des archives
# @param $1 : Compression
##
function Backup.check.compress()
{
    debug "Backup.check.compress ($1)"

    [[ -z $1 ]] && return 1
    case $(String.lower $1) in
        gz)
            System.binary.exists gzip
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        bz|bz2)
            System.binary.exists bzip2
            [[ $? -eq 0 ]] && return 0 || return 202
            ;;
        none|null|false)
            return 1;;
        *)
            return 101;;
    esac
}


###
# Test si une méthode de sauvegarde existe
# @param $1 : Méthode
##
function Backup.check.method.exists()
{
    debug "Backup.check.method.exists ($1)"

    case $(String.lower $1) in
        tarball)
            System.binary.exists 'tar'
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        rsync)
            System.binary.exists 'rsync'
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        mysql)
            System.binary.exists 'mysqldump'
            [[ $? -eq 0 ]] && return 0 || return 202
            ;;
        postgres)
            System.binary.exists 'pg_dump'
            [[ $? -eq 0 ]] && return 0 || return 203
            ;;
        *)
            return 101;;
    esac

    return 0
}


###
# Test l'existence d'un dossier
# @param $1 : Dossier
##
function Backup.check.folder()
{
    debug "Backup.check.folder ($1)"

    if  ! Directory.exists $1; then
        return 101
    elif ! Directory.readable $1; then
        return 102
    fi
    return 0
}


###
# Vérifie le serveur de SGBD
# @param $1 : SGBD
##
function Backup.check.sgbd()
{
    debug "Backup.check.sgbd ()"
    $1.server.check && return 0 || return 101
}


###
# Vérifie la base à sauvegarder
# @param $1 : SGBD
# @param $2 : Nom de la base
##
function Backup.check.base()
{
    debug "Backup.check.base ($1, $2)"

    if  ! $1.base.exists $2; then
        warning "La base \"$2\" n'existe pas"
        return 101
    fi
    return 0
}


###
# Vérifie si un mode d'export existe
##
function Backup.check.export()
{
    debug "Backup.check.export ()"

    [[ -z $OLIX_MODULE_BACKUP_EXPORT_MODE ]] && return 1
    case $(String.lower $OLIX_MODULE_BACKUP_EXPORT_MODE) in
        ftp)
            System.binary.exists lftp
            [[ $? -eq 0 ]] && return 0 || return 201
            ;;
        ssh)
            System.binary.exists scp
            [[ $? -eq 0 ]] && return 0 || return 202
            ;;
        none|null|false)
            return 1;;
        *)
            return 101;;
    esac
}


###
# Vérifie la connexion à un serveur distant
# @param $1 : Mode
##
function Backup.check.export.connect()
{
    debug "Backup.check.export.connect ($1)"
    $1.check.connection && return 0 || return 101
}


###
# Vérifie un dossier distant
# @param $1 : Mode
##
function Backup.check.export.directory()
{
    debug "Backup.check.export.directory ($1)"

    if $1.check.directory $OLIX_MODULE_BACKUP_EXPORT_PATH; then
        if $1.check.writable $OLIX_MODULE_BACKUP_EXPORT_PATH; then
            rm -f $OLIX_LOGGER_FILE_ERR
            return 0
        else
            rm -f $OLIX_LOGGER_FILE_ERR
            return 101
        fi
    else
        rm -f $OLIX_LOGGER_FILE_ERR
        return 102
    fi
}


###
# Vérifie le valeur du format du rapport
##
function Backup.check.report.format()
{
    debug "Backup.check.report.format ()"

    Report.check.format $OLIX_MODULE_BACKUP_REPORT_FORMAT && return 0 || return 101
}


###
# Vérifie l'email
##
function Backup.check.report.email()
{
    debug "Backup.check.report.email ()"

    [[ -z $OLIX_MODULE_BACKUP_REPORT_EMAIL ]] && return 1 || return 0
}
