# Script for generating jazzy docs

if [ "$#" -ne 1 ]; then
    echo "Script requires version number argument"
else
    sdk_version="$1"

    base_location="../../docs/api-docs"

    echo "Checking doc repo exists..."

    if [ -d $base_location ]; then
        docs_location="$base_location/$sdk_version"
        tmp_location="$base_location/all_sdk_files"
        if [ -d $docs_location ]; then
            rm -rf $docs_location
        fi
        
        mkdir $docs_location

        if [ -d $tmp_location ]; then
            rm -rf $tmp_location
        fi
        mkdir $tmp_location

        echo "Copying all sdk files to tmp directory..."
        find ../Source/Source/ -name \*.[h,m] -exec cp {} $tmp_location \;
        cp ../README.md $tmp_location

        echo "Generating documents..."
        jazzy --readme $tmp_location/README.md --config ../.jazzy.json --project ../Source/SwiftyDropbox -o $docs_location

        cp jazzy.css $docs_location/css/

        echo "Removing tmp sdk files..."
        rm -rf $tmp_location

        cd $base_location/
        rm latest
        ln -s $sdk_version latest
        cd -
    else
        echo "Docs directory does not exist"
    fi
fi