#!/bin/sh
set -e

if [ "$1" = "set" ]
then
    # Runs auto-semver and grabs outputs
    regex='^\s*current_version\s*=\s*\K[^\s]+'
    export RETURN_STATUS=$(semver -n || echo $?)
    export SEMVER_NEW_VERSION=`grep -Po ${regex} .bumpversion.cfg`
    export VERSION=`semver_get_version -d`

    echo "::set-output name=RETURN_STATUS::$RETURN_STATUS"
    echo "::set-output name=SEMVER_NEW_VERSION::$SEMVER_NEW_VERSION"
    echo "::set-output name=VERSION::$VERSION"
elif [ "$1" = "get" ]
then
    # Updates .bumpversion files to tagged version
    export regex="([0-9]+.[0-9]+.[0-9]+)"
    git fetch --all --tags
    VERSIONS=`git tag -l --sort=refname ${regex}`
    echo $VERSIONS
    # bumpversion minor --no-tag --new-version ${VERSION}
    # echo ::set-output name=VERSION::$VERSION
elif [ "$1" = "update" ]
then
    # Updates .bumpversion files to tagged version
    VERSION="$2"
    bumpversion minor --no-tag --new-version ${VERSION}
    echo ::set-output name=VERSION::$VERSION
fi