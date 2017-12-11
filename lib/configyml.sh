###
# Librairies du fichier conf au format YML des sauvegardes
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



###
# Charge le fichier de config YML
# @param $1 : Chemin complet du fichier YML
##
function Backup.ConfigYML.load()
{
    debug "Backup.ConfigYML.load ($1)"

    [[ -z $1 ]] && return 1
    ! File.readable $1 && warning "$1 absent" && return 1

    info "Chargement du fichier YML '$1'"
    Yaml.parse $1 "$OLIX_MODULE_BACKUP_CONFYML_PREFIX"

    return $?
}


###
# Affecte dynamiquement les valeurs du fichier YML dans les variables OLX_MODULE_BACKUP_*
##
function Backup.ConfigYML.setAll()
{
    debug "Backup.ConfigYML.setAll ()"
    local I VALUE

    for I in $(Config.parameters 'backup'); do
        VALUE=$(Backup.ConfigYML.getParam $I)
        Config.dynamic.set 'backup' $I "$VALUE"
        debug "Set in var from yml -> $(String.upcase "OLIX_MODULE_BACKUP_$I")=$(Config.dynamic.get 'backup' $I)"
    done
}


###
# Récupère la valeur du fichier YML et si pas rempli la valeur du fichier de conf par défaut
# @param $1 : Nom du paramètre
##
function Backup.ConfigYML.getParam()
{
    local VALUE DEFAULT

    VALUE=$(Yaml.get ${1//_/.})
    DEFAULT=$(Config.param.get 'backup' $1)

    if [[ -z $VALUE ]]; then
        [[ -z $DEFAULT ]] && echo -n "" && return
        warning "La configuration YAML:${1//_/.} n'est pas renseignée, utilisation de la valeur \"$DEFAULT\" par défaut."
        echo -n "$DEFAULT"
    else
        echo -n "$VALUE"
    fi
}
