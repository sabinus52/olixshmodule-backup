###
# Purge des anciennes sauvegardes
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##



###
# Vérification des paramètres
##
Backup.check.repository
[[ $? -gt 100 ]] && critical "Le dossier \"$OLIX_MODULE_BACKUP_REPOSITORY_ROOT\" n'est pas accessible"


###
# Initialisation
##
Backup.initialize "$OLIX_MODULE_BACKUP_REPOSITORY_ROOT" "$OLIX_MODULE_BACKUP_ARCHIVE_TTL"
[[ $? -ne 0 ]] && critical "Impossible d'initialiser la sauvegarde"


###
# Traitement
##
info "Purge des sauvegardes"
Backup.purge
[[ $? -ne 0 ]] && error


###
# FIN
##
