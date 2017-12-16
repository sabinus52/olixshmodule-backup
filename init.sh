###
# Initialisation des paramètres de la configuration du module backup
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Traitement
##


# Si Fichier de configuration
if [[ -n $OLIX_MODULE_BACKUP_CONFYML ]]; then

    echo -e "${CBLANC}Il est préférable de vérifier les paramètres du fichier ${Ccyan}$OLIX_MODULE_BACKUP_CONFYML${CVOID}"
    Read.confirm "Confirmer la vérification" true
    if [[ $OLIX_FUNCTION_RETURN == true ]]; then
        Module.execute.action 'check' $@
        Read.confirm "Confirmer l'initialisation avec ces paramètres" true
        [[ $OLIX_FUNCTION_RETURN == false ]] && return
    fi

    # Récupère les paramètres du YML
    Backup.ConfigYML.load $OLIX_MODULE_BACKUP_CONFYML || critical "Impossible de lire le fichier de conf \"$OLIX_MODULE_BACKUP_CONFYML\""

    # Pour chaque paramètre, on affecte la valeur contenue dans le YML
    for I in $(Config.parameters 'backup'); do
        VALUE=$(Backup.ConfigYML.getParam $I)
        Config.param.set 'backup' $I "$VALUE"
    done

else

    load 'utils/fileconfig.sh'

    # Demande à l'utilisateur les valeurs de chaque paramètres
    for I in $(Config.parameters 'backup'); do
        Fileconfig.param.set 'backup' $I
    done

fi


###
# FIN
##
echo -e "${CVERT}Initialisation des paramètres effectués${CVOID}"
echo -e "${Cjaune}Il est fortement recommandé de lancer la commande ${CCYAN}$(basename $OLIX_ROOT_SCRIPT) backup check${CVOID}"
