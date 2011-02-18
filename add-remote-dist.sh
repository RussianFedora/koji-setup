#!/bin/sh

TYPE=foo
if [ "$1" == "rfremix" ]; then
	TYPE=rfr
elif [ "$1" == "el" ]; then
	TYPE=el
fi
VERSION=$2

DIST=dist-${TYPE}${VERSION}
DIST_BUILD=${DIST}-build

koji add-tag ${DIST}
koji add-tag --parent ${DIST} --arches "i686 x86_64" ${DIST_BUILD}

KOJI_ADD_ER="koji add-external-repo -t ${DIST_BUILD} ${DIST}"
if [ "${TYPE}" == "rfr" ];then
	${KOJI_ADD_ER}-release http://mirror.yandex.ru/fedora/linux/releases/$VERSION/Everything/\$arch/os/
	${KOJI_ADD_ER}-updates http://mirror.yandex.ru/fedora/linux/updates/$VERSION/\$arch/
	${KOJI_ADD_ER}-rpmfusion-free http://mirror.yandex.ru/fedora/rpmfusion/free/fedora/releases/$VERSION/Everything/\$arch/os/
	${KOJI_ADD_ER}-rpmfusion-nonfree http://mirror.yandex.ru/fedora/rpmfusion/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
	${KOJI_ADD_ER}-rpmfusion-free-updates http://mirror.yandex.ru/fedora/rpmfusion/free/fedora/updates/$VERSION/\$arch/
	${KOJI_ADD_ER}-rpmfusion-nonfree-updates http://mirror.yandex.ru/fedora/rpmfusion/nonfree/fedora/updates/$VERSION/\$arch/
	${KOJI_ADD_ER}-rfremix-free http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/releases/$VERSION/Everything/\$arch/os/
	${KOJI_ADD_ER}-rfremix-nonfree http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
	${KOJI_ADD_ER}-rfremix-fixes http://mirror.yandex.ru/fedora/russianfedora/russianfedora/fixes/fedora/releases/$VERSION/Everything/\$arch/os/
	${KOJI_ADD_ER}-rfremix-free-updates http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/updates/$VERSION/\$arch/
	${KOJI_ADD_ER}-rfremix-nonfree-updates http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/updates/$VERSION/\$arch/
	${KOJI_ADD_ER}-rfremix-fixes-updates http://mirror.yandex.ru/fedora/russianfedora/russianfedora/fixes/fedora/updates/$VERSION/\$arch/
elif [ "${TYPE}" == "el" ]; then
	${KOJI_ADD_ER}-release ftp://ftp.scientificlinux.org/linux/scientific/6rolling/\$arch/os/
	${KOJI_ADD_ER}-updates-fastbugs ftp://ftp.scientificlinux.org/linux/scientific/6rolling/\$arch/updates/fastbugs/
	${KOJI_ADD_ER}-updates-security ftp://ftp.scientificlinux.org/linux/scientific/6rolling/\$arch/updates/security/
	#${KOJI_ADD_ER}-build ftp://ftp.scientificlinux.org/linux/scientific/6rolling/build/\$arch/
fi

koji add-target ${DIST} ${DIST_BUILD}
koji add-group ${DIST_BUILD} build
koji add-group ${DIST_BUILD} srpm-build
koji add-group-pkg ${DIST_BUILD} build bash bzip2 coreutils cpio glibc diffutils fedora-release findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which
koji add-group-pkg ${DIST_BUILD} srpm-build bash curl cvs fedora-release gnupg make redhat-rpm-config rpm-build shadow-utils python
