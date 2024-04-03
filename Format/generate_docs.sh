#!/bin/sh
# Script for generating jazzy docs

if [ "$#" -ne 2 ]; then
    echo "Script requires two arguments: 1. path to docs repo checkout 2. path to updated SDK checkout."
else
    sdk_version="$(git describe --abbrev=0 --tags)"
    docs_repo_location="$1"
    sdk_repo_location="$2"

    echo "Checking doc repo exists..."

    if [ -d $docs_repo_location ]; then
        if [ -d $sdk_repo_location ]; then
            docs_location="$docs_repo_location/api-docs/$sdk_version"
            if [ -d $docs_location ]; then
                rm -rf $docs_location
            fi

            mkdir $docs_location

            echo "Generating documents..."
            cd ..
                jazzy --readme $sdk_repo_location/README.md --config $sdk_repo_location/.jazzy.json --github_url https://github.com/dropbox/SwiftyDropbox --module-version $sdk_version --podspec SwiftyDropbox.podspec -o $docs_location
            cd -

            cd $docs_repo_location/api-docs
            rm -rf latest
            mkdir latest
            cp -R $sdk_version/* latest/
            cd -

            echo "Finished generating docs to: $docs_repo_location/api-docs."
        else
            echo "SDK directory does not exist"
        fi
    else
        echo "Docs directory does not exist"
    fi
fi
