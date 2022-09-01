#!/bin/sh
set -e

compare_versions() {
  export regex="^([0-9]+.[0-9]+.[0-9]+)"

      git fetch --all --tags
      TAGS=( $(git tag) )
      declare -a VERSIONS=()

      for i in "${TAGS[@]}"
      do
        if [[ "$i"  =~ $regex ]];
        then
           VERSIONS+=($i)
        fi
      done

      if [ -z "$VERSIONS" ]; then
        echo "$1"
      else
        sorted=( $(sort -V <<<"${VERSIONS[*]}") )
        VERSION=${sorted[-1]}

        if dpkg --compare-versions $1 gt $VERSION ; then
          echo "$1"
        else
          echo $VERSION
        fi
      fi
}

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
elif [ "$1" = "check" ]
then
    # Get highest tagged version(if exists), and compares to version from params. Sets VERSION equal to whichever is higher.
    if [ -z "$2" ]
    then
      echo "Requires a semver version number for comparison"
    else
      NEWEST_VERSION=compare_versions "$2"
      echo "::set-output name=VERSION::$NEWEST_VERSION"
    fi
elif [ "$1" = "update" ]
then
    # Updates .bumpversion files to tagged version
    VERSION="$2"

    bumpversion minor --no-tag --new-version ${VERSION}
    echo ::set-output name=VERSION::$VERSION
fi