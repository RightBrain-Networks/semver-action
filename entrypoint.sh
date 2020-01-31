if [ "$1" = "set" ]
then
    # Runs auto-semver and grabs outputs
    export regex='^\\s*current_version\\s*=\\s*\\K[^\\s]+'
    export RETURN_STATUS=`semver -n`
    echo "Semver Return Status: ${RETURN_STATUS}"

    export SEMVER_NEW_VERSION=`grep -Po '${regex}' .bumpversion.cfg`
    export VERSION=`semver_get_version -d`

    echo ::set-output name=RETURN_STATUS::$RETURN_STATUS
    echo ::set-output name=SEMVER_NEW_VERSION::$SEMVER_NEW_VERSION
    echo ::set-output name=VERSION::$VERSION
elif [ "$1" = "get"]
    # Updates .bumpversion files to tagged version
    export regex="([0-9]+.[0-9]+.[0-9]+)"
    echo ${{ github.ref }} > tag.txt
    VERSION=`grep -Po "${regex}" tag.txt`
    bumpversion minor --no-tag --new-version ${VERSION}
    echo ::set-output name=VERSION::$VERSION
fi