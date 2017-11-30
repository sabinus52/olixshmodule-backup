###
# Librairies pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##


###
# Vérifie le dossier de sauvegarde
# @param $1 : Dossier à vérifier
##
function Backup.path.check()
{
    debug "Backup.path.check ($1)"
    if [[ ! -d $1 ]]; then
        warning "Création du dossier inexistant \"$1\""
        mkdir $1 || critical "Impossible de créer le dossier \"$1\""
    elif [[ ! -w $1 ]]; then
        critical "Le dossier '$1' n'a pas les droits en écriture"
    fi
}


###
# Fait une sauvegarde d'une base MySQL
# @param $1 : Nom de la base
# @return bool
##
function Backup.mysql.base()
{
    debug "Backup.mysql.base ($1)"
    local BASE=$1

    Print.head2 "Dump de la base MySQL %s" "$BASE"

    if ! Mysql.base.exists $BASE; then
        warning "La base '${BASE}' n'existe pas"
        return 1
    fi

    Backup.Instance.setfile "dump-$BASE-" "$(Mysql.base.dump.ext)"
    info "Sauvegarde base MySQL (${BASE}) -> $(Backup.Instance.getfile)"

    Mysql.base.dump "$BASE" "$(Backup.Instance.getfile)"
    Backup.Instance.printresult $? || return 1
    Backup.Instance.compress || return 1

    return 0
}


###
# Termine la sauvegarde
# @param $1 : Si erreur
##
function Backup.terminate()
{
    debug "Backup.terminate ($1)"
    Print.echo; Print.line;

    if [[ $1 == true ]]; then
        Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec des erreurs" "${Crouge}"
        Report.terminate "ERREUR - Rapport de backup des bases du serveur $HOSTNAME"
        OLIX_CODE_RETURN=1
    else
        Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec succès" "${Cvert}"
        Report.terminate "Rapport de backup des bases du serveur $HOSTNAME"
        OLIX_CODE_RETURN=0
    fi
}
