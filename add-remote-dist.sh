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

if [ "${TYPE}" == "rfr" ];then
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-release -p 5 http://knight.yandex.net/fedora/linux/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-updates -p 0 http://knight.yandex.net/fedora/linux/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-free -p 15 http://knight.yandex.net/fedora/rpmfusion/free/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-nonfree -p 16 http://knight.yandex.net/fedora/rpmfusion/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-free-updates -p 10 http://knight.yandex.net/fedora/rpmfusion/free/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rpmfusion-nonfree-updates -p 11 http://knight.yandex.net/fedora/rpmfusion/nonfree/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-free -p 25 http://knight.yandex.net/fedora/russianfedora/russianfedora/free/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-nonfree -p 26 http://knight.yandex.net/fedora/russianfedora/russianfedora/nonfree/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-fixes -p 27 http://knight.yandex.net/fedora/russianfedora/russianfedora/fixes/fedora/releases/$VERSION/Everything/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-free-updates -p 20 http://knight.yandex.net/fedora/russianfedora/russianfedora/free/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-nonfree-updates -p 21 http://knight.yandex.net/fedora/russianfedora/russianfedora/nonfree/fedora/updates/$VERSION/\$arch/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-rfremix-fixes-updates -p 22 http://knight.yandex.net/fedora/russianfedora/russianfedora/fixes/fedora/updates/$VERSION/\$arch/
elif [ "${TYPE}" == "el" ]; then
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-release -p 5 ftp://ftp.scientificlinux.org/linux/scientific/6/\$arch/os/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-updates-fastbugs -p 1 ftp://ftp.scientificlinux.org/linux/scientific/6/\$arch/updates/fastbugs/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-updates-security -p 0 ftp://ftp.scientificlinux.org/linux/scientific/6/\$arch/updates/security/
	koji add-external-repo -t ${DIST_BUILD} ${DIST}-epel -p 10 http://mirror.yandex.ru/epel/6/\$arch/
fi

koji add-target ${DIST} ${DIST_BUILD}
koji add-group ${DIST_BUILD} build
koji add-group ${DIST_BUILD} srpm-build
koji add-group-pkg ${DIST_BUILD} build bash bzip2 coreutils cpio glibc diffutils fedora-release findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which
koji add-group-pkg ${DIST_BUILD} srpm-build bash curl cvs fedora-release gnupg make redhat-rpm-config rpm-build shadow-utils python
