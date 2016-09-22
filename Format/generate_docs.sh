# Script for generating jazzy docs

if [ "$#" -ne 1 ]; then
    echo "Script requires version number argument"
else
    sdk_version="$1"

    base_location="../../docs/api-docs"

    echo "Checking doc repo exists..."

    if [ -d $base_location ]; then
        docs_location="$base_location/$sdk_version"
        if [ -d $docs_location ]; then
            rm -rf $docs_location
        fi
        
        mkdir $docs_location

        echo "Generating documents..."
        cd ../Source/SwiftyDropbox
        jazzy --readme ../../README.md --config ../../.jazzy.json --github_url https://github.com/dropbox/SwiftyDropbox --module-version 4.0.4 --module SwiftyDropbox -o ../../Format/$docs_location
        cd -

        cd $base_location/
        rm latest
        ln -s $sdk_version latest
        cd -
    else
        echo "Docs directory does not exist"
    fi
fi