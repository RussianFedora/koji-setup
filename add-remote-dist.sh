#!/bin/sh

TYPE=foo
if [ "$1" == "fedora" ]; then
	TYPE=f
elif [ "$1" == "epel" ]; then
	TYPE=el
else
	TYPE=rfr
fi
VERSION=$2

DIST=dist-${TYPE}${VERSION}
DIST_BUILD=${DIST}-build

koji add-tag ${DIST}
koji add-tag --parent ${DIST} --arches "i386 x86_64" ${DIST_BUILD}
if [ "${TYPE}" == "f" ];then
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-release http://mirror.yandex.ru/fedora/linux/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-updates http://mirror.yandex.ru/fedora/linux/updates/$VERSION/\$arch/
#elif [ "${TYPE}" == "el" ];then
#	koji add-external-repo -t ${DIST_BUILD} ${DIST}-release http://mirror.yandex.ru/fedora/linux/releases/$VERSION/Everything/\$arch/os/
#	koji add-external-repo -t ${DIST_BUILD} ${DIST}-updates http://mirror.yandex.ru/fedora/linux/updates/$VERSION/\$arch/
fi

koji add-target ${DIST} ${DIST_BUILD}
koji add-group ${DIST_BUILD} build
koji add-group ${DIST_BUILD} srpm-build
koji add-group-pkg ${DIST_BUILD} build bash bzip2 coreutils cpio glibc diffutils fedora-release findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which
koji add-group-pkg ${DIST_BUILD} srpm-build bash curl cvs fedora-release gnupg make redhat-rpm-config rpm-build shadow-utils python
#koji add-group-pkg ${DIST_BUILD} build 
