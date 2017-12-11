###
# Librairies de la méthode de sauvegarde TARBALL du module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la méthode de sauvegarde des archives
##
function Backup.Method.Tarball.initialize()
{
    debug "Backup.Method.Tarball.initialize ()"
}


###
# Test l'existence des dossiers
##
function Backup.Method.Tarball.check.folders()
{
    debug "Backup.Method.Tarball.check.folders ()"
    local I

    [[ -z $OLIX_MODULE_BACKUP_TARBALL_FOLDERS ]] && return 1
    for I in $OLIX_MODULE_BACKUP_TARBALL_FOLDERS; do
        if  ! Directory.exists $I; then
            info "Le dossier \"$I\" n'existe pas"
            return 101
        elif ! Directory.readable $I; then
            info "Le dossier \"$I\" ne peut être lu"
            return 102
        fi
    done
    return 0
}
