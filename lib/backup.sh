###
# Librairies pour le module BACKUP
# ==============================================================================
# @package olixsh
# @module backup
# @author Olivier <sabinus52@gmail.com>
##



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
# Fait une sauvegarde d'une base PostgreSQL
# @param $1 : Nom de la base
# @return bool
##
function Backup.postgres.base()
{
    debug "Backup.postgres.base ($1)"
    local BASE=$1

    Print.head2 "Dump de la base PostgreSQL %s" "$BASE"

    if ! Postgres.base.exists $BASE; then
        warning "La base '${BASE}' n'existe pas"
        return 1
    fi

    Backup.Instance.setfile "dump-$BASE-" "$(Postgres.base.dump.ext c)"
    info "Sauvegarde base PostgreSQL (${BASE}) -> $(Backup.Instance.getfile)"

    Postgres.base.dump "$BASE" "$(Backup.Instance.getfile)" "c"
    Backup.Instance.printresult $? || return 1

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
