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
elif [ "$1" = "get" ]
then
    # Updates .bumpversion files to tagged version
    export regex="^([0-9]+.[0-9]+.[0-9]+)"
    echo "${{ github.ref }}" > tag.txt
    echo "$(cat tag.txt)"
    VERSION=$(grep -Po "${regex}" tag.txt)

    # bumpversion minor --no-tag --new-version ${VERSION}
    echo ::set-output name=VERSION::$VERSION
fi