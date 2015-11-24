#!/bin/sh

LANG=C

if [ ! -d /tmp/regen/ ]; then
    mkdir -p /tmp/regen/
fi

TAGS=($(koji list-tags --unlock | grep "build"))
SIZE=$((${#TAGS[@]}-1))

for i in $(seq 0 $SIZE); do
    if [ "${TAGS[$i]}" == "dist-rfr-rawhide-build" ]; then
        REPO_NAME="dist-rfr-rawhide-release"
    elif [ "${TAGS[$i]}" == "dist-el6-build" ]; then
        REPO_NAME="dist-el6-updates-security"
    else
        REPO_NAME="$(echo ${TAGS[$i]} | sed 's@-build@@')-updates"
    fi

    URLS[$i]="$(koji list-external-repos --quiet --tag=${TAGS[$i]} --name $REPO_NAME | awk '{ print $NF }' | sed 's@^ftp@http@' | sed 's@\$arch@x86_64@g')repodata/repomd.xml"
done

for i in $(seq 0 $SIZE); do
    if [ "$(curl -LR -z /tmp/regen/${TAGS[$i]} -o /tmp/regen/${TAGS[$i]} ${URLS[$i]} 2>&1 | tail -n1 | awk '{ print $NF }')" != "0" ]; then
        koji -q --skip-main regen-repo --nowait ${TAGS[$i]}
    fi
done

##tags=`koji list-tags --unlocked | grep build`
##
##for tag in $tags; do
##	koji -q --skip-main regen-repo $tag > /var/log/regen-repo.log 2>&1
##done
