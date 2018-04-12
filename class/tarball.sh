###
# Classe de la méthode de sauvegarde TARBALL du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des archives
# @param $1 : Compression
##
function Backup.Tarball.initialize()
{
    debug "Backup.Tarball.initialize ($1)"

    OX_BACKUP_METHOD="Tarball"
    OX_BACKUP_ARCHIVE_COMPRESS=$1
    Backup.repository.create
    return $?
}


###
# Retourne le titre du rapport
##
function Backup.Tarball.getTitle()
{
    echo -n "Sauvegarde du dossier %s"
}


###
# Vérifie le dossier à sauvegarder
##
function Backup.Tarball.check()
{
    debug "Backup.Tarball.check ()"
    if  ! Directory.exists $OX_BACKUP_ITEM; then
        warning "Le dossier \"$OX_BACKUP_ITEM\" n'existe pas"
        return 1
    elif ! Directory.readable $OX_BACKUP_ITEM; then
        warning "Le dossier \"$OX_BACKUP_ITEM\" ne peut être lu"
        return 1
    fi
    return 0
}


###
# Retourne le préfixe de l'archive
##
function Backup.Tarball.getPrefix()
{
    echo -n "backup-$(basename $OX_BACKUP_ITEM)-"
}


###
# Retourne l'extension de l'archive
##
function Backup.Tarball.getExtension()
{
    echo -n $(Compression.tar.extension $OX_BACKUP_ARCHIVE_COMPRESS)
}


###
# Fait la sauvegarde
##
function Backup.Tarball.doBackup()
{
    debug "Backup.Tarball.doBackup ()"
    local PWDTMP PARAM RET I

    [[ $OLIX_OPTION_VERBOSE == true ]] && PARAM="--verbose"
    PARAM="$PARAM $(Compression.tar.mode $OX_BACKUP_ARCHIVE_COMPRESS)"
    for I in $OX_BACKUP_EXCLUDE; do
        PARAM="$PARAM --exclude=$I"
    done

    PWDTMP=$(pwd)
    cd $OX_BACKUP_ITEM 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && cd $PWDTMP && return 1

    debug "tar --create --ignore-failed-read $PARAM --file $OX_BACKUP_ARCHIVE ."
    tar --create --ignore-failed-read $PARAM --file $OX_BACKUP_ARCHIVE . 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?

    cd $PWDTMP
    return $?
}


###
# Transfert du fichier de backup sur un serveur distant
# @param $1 : Méthode de transfert
# @param $2 : Emplacement sur le serveur distant
##
function Backup.Tarball.export()
{
    debug "Backup.Tarball.export ($1, $2)"

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
