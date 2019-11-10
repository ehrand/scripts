#! /bin/bash

source "${SCRIPTS_LIB_DIR}/network.sh"

doBackup() {
    for folder in \
        "/mnt/docs" \
        "/mnt/musa" \
        "/mnt/pics" \
    ; do
        doRsync \
            -p "ehrlich" \
            -u "an3" \
            -s "${folder}" \
            -d "an3@nasbox:/home/an3/backup/" \
        || break;
    done
}

isSourced \
    && printf "This script is not allowed to be sourced!" \
    || doBackup
