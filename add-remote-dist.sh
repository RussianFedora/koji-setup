#!/bin/sh

TYPE=foo
if [ "$1" == "rfremix" ]; then
    TYPE=rfr
elif [ "$1" == "el" ]; then
    TYPE=el
elif [ "$1" == "rfr-alpha" ]; then
    TYPE=rfr-alpha
elif [ "$1" == "rfr-beta" ]; then
    TYPE=rfr-beta
fi
VERSION=$2

DIST=dist-${TYPE}${VERSION}
DIST_BUILD=${DIST}-build

koji add-tag ${DIST}
koji add-tag --parent ${DIST} --arches "i686 x86_64" ${DIST_BUILD}

ADD_EXTERNAL_REPO="koji add-external-repo -t ${DIST_BUILD} ${DIST}"

if [ "${TYPE}" == "rfr" ]; then
    ${ADD_EXTERNAL_REPO}-release -p 5 http://knight.yandex.net/fedora/linux/releases/$VERSION/Everything/\$arch/os/
    ${ADD_EXTERNAL_REPO}-updates -p 0 http://knight.yandex.net/fedora/linux/updates/$VERSION/\$arch/
    ${ADD_EXTERNAL_REPO}-rpmfusion-free -p 15 http://knight.yandex.net/fedora/rpmfusion/free/fedora/releases/$VERSION/Everything/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rpmfusion-nonfree -p 16 http://knight.yandex.net/fedora/rpmfusion/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rpmfusion-free-updates -p 10 http://knight.yandex.net/fedora/rpmfusion/free/fedora/updates/$VERSION/\$arch/
    ${ADD_EXTERNAL_REPO}-rpmfusion-nonfree-updates -p 11 http://knight.yandex.net/fedora/rpmfusion/nonfree/fedora/updates/$VERSION/\$arch/
    ${ADD_EXTERNAL_REPO}-rfremix-free -p 25 http://knight.yandex.net/fedora/russianfedora/russianfedora/free/fedora/releases/$VERSION/Everything/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rfremix-nonfree -p 26 http://knight.yandex.net/fedora/russianfedora/russianfedora/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rfremix-fixes -p 27 http://knight.yandex.net/fedora/russianfedora/russianfedora/fixes/fedora/releases/$VERSION/Everything/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rfremix-free-updates -p 20 http://knight.yandex.net/fedora/russianfedora/russianfedora/free/fedora/updates/$VERSION/\$arch/
    ${ADD_EXTERNAL_REPO}-rfremix-nonfree-updates -p 21 http://knight.yandex.net/fedora/russianfedora/russianfedora/nonfree/fedora/updates/$VERSION/\$arch/
    ${ADD_EXTERNAL_REPO}-rfremix-fixes-updates -p 22 http://knight.yandex.net/fedora/russianfedora/russianfedora/fixes/fedora/updates/$VERSION/\$arch/
elif [ "${TYPE}" == "el" ]; then
    ${ADD_EXTERNAL_REPO}-release -p 5 ftp://ftp.scientificlinux.org/linux/scientific/6/\$arch/os/
    ${ADD_EXTERNAL_REPO}-updates-fastbugs -p 1 ftp://ftp.scientificlinux.org/linux/scientific/6/\$arch/updates/fastbugs/
    ${ADD_EXTERNAL_REPO}-updates-security -p 0 ftp://ftp.scientificlinux.org/linux/scientific/6/\$arch/updates/security/
    ${ADD_EXTERNAL_REPO}-epel -p 10 http://mirror.yandex.ru/epel/6/\$arch/
elif [ "${TYPE}" == "rfr-alpha" ]; then
    # Fedora upstream repos
    #${ADD_EXTERNAL_REPO}-release -p 5 http://knight.yandex.net/fedora/linux/releases/test/${VERSION}-Alpha/Fedora/\$arch/os/
    ${ADD_EXTERNAL_REPO}-release -p 5 http://knight.yandex.net/fedora/linux/development/${VERSION}/\$arch/os/
    ${ADD_EXTERNAL_REPO}-updates-testing -p 0 http://knight.yandex.net/fedora/linux/updates/testing/${VERSION}/\$arch/

    # this is RPMFusion fucking development
    ${ADD_EXTERNAL_REPO}-rpmfusion-free -p 15 http://knight.yandex.net/fedora/rpmfusion/free/fedora/development/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rpmfusion-nonfree -p 16 http://knight.yandex.net/fedora/rpmfusion/nonfree/fedora/development/\$arch/os/

    # our repos
    ${ADD_EXTERNAL_REPO}-rfremix-free -p 25 http://knight.yandex.net/fedora/russianfedora/russianfedora/free/fedora/development/${VERSION}/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rfremix-fixes -p 26 http://knight.yandex.net/fedora/russianfedora/russianfedora/fixes/fedora/development/${VERSION}/\$arch/os/
    ${ADD_EXTERNAL_REPO}-rfremix-nonfree -p 27 http://knight.yandex.net/fedora/russianfedora/russianfedora/nonfree/fedora/development/${VERSION}/\$arch/os/

    # our repos updates
    ${ADD_EXTERNAL_REPO}-rfremix-free-updates -p 20 http://knight.yandex.net/fedora/russianfedora/russianfedora/free/fedora/updates/${VERSION}/\$arch/
    ${ADD_EXTERNAL_REPO}-rfremix-fixes-updates -p 21 http://knight.yandex.net/fedora/russianfedora/russianfedora/fixes/fedora/updates/${VERSION}/\$arch/
    ${ADD_EXTERNAL_REPO}-rfremix-nonfree-updates -p 22 http://knight.yandex.net/fedora/russianfedora/russianfedora/nonfree/fedora/updates/${VERSION}/\$arch/

fi

koji add-target ${DIST} ${DIST_BUILD}
koji add-group ${DIST_BUILD} build
koji add-group ${DIST_BUILD} srpm-build
koji add-group-pkg ${DIST_BUILD} build bash bzip2 coreutils cpio glibc diffutils fedora-release findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which system-release
koji add-group-pkg ${DIST_BUILD} srpm-build bash curl cvs system-release gnupg make redhat-rpm-config rpm-build shadow-utils python git subversion bzr
