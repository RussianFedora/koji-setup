#!/bin/sh

TYPE=foo
if [ "$1" == "rfremix" ]; then
	TYPE=rfr
fi
VERSION=$2

DIST=dist-${TYPE}${VERSION}
DIST_BUILD=${DIST}-build

koji add-tag ${DIST}
koji add-tag --parent ${DIST} --arches "i386 x86_64" ${DIST_BUILD}
if [ "${TYPE}" == "rfr" ];then
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-release http://mirror.yandex.ru/fedora/linux/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-updates http://mirror.yandex.ru/fedora/linux/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-free http://mirror.yandex.ru/fedora/rpmfusion/free/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-nonfree http://mirror.yandex.ru/fedora/rpmfusion/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-free-updates http://mirror.yandex.ru/fedora/rpmfusion/free/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-nonfree-updates http://mirror.yandex.ru/fedora/rpmfusion/nonfree/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-free http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-nonfree http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-fixes http://mirror.yandex.ru/fedora/russianfedora/russianfedora/fixes/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-free-updates http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-nonfree-updates http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-fixes-updates http://mirror.yandex.ru/fedora/russianfedora/russianfedora/fixes/fedora/updates/$VERSION/\$arch/
fi

koji add-target ${DIST} ${DIST_BUILD}
koji add-group ${DIST_BUILD} build
koji add-group ${DIST_BUILD} srpm-build
koji add-group-pkg ${DIST_BUILD} build bash bzip2 coreutils cpio glibc diffutils fedora-release findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which
koji add-group-pkg ${DIST_BUILD} srpm-build bash curl cvs fedora-release gnupg make redhat-rpm-config rpm-build shadow-utils python
