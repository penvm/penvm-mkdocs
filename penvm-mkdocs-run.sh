#! /bin/bash
#
# penvm-mkdocs-run.sh

print_usage() {
	echo "\
usage: ${PROGNAME} [<penvm-repo>] [<tag>]
	${PROGNAME} -h|--help

Build PENVM mkdocs documentation."
}

PROGNAME=$(basename $0)
REPO="https://github.com/penvm/penvm.git"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

while [ $# -gt 0 ]; do
	case $1 in
	-h|--help)
		print_usage
		exit 0
		;;
	*)
		REPO=$1; shift 1
		if [ $# -gt 0 ]; then
			TAG=$1; shift 1
		fi
		break
		;;
	esac
done

case "${REPO}" in
https:*|git@*)
	echo "Cloning repo (${REPO}) ..."
	git clone "${REPO}" penvm
	;;
/*)
	echo "Copying repo (${REPO}) ..."
	cp -r "${REPO}" penvm
	;;
esac

if [ -z "${TAG}" ]; then
	# use (semantically) "latest" tag
	TAG=$(cd penvm; git tag -l | tail -1)
fi

tags=$(cd penvm; git tag -l)
if ! echo "${tags}" | grep "^${TAG}$"; do
	echo "error: ${TAG} not found"
	exit 1
fi

(cd penvm; git checkout "${TAG}")

name="site-${TAG}-${TIMESTAMP}"
mkdocs --verbose build
mv site "${name}"

echo "Results are at ${name}"
