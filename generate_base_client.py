#!/usr/bin/env python
from __future__ import absolute_import, division, print_function, unicode_literals

import argparse
import glob
import json
import os
import shutil
import subprocess
import sys

cmdline_desc = """\
Runs Stone to generate Swift types and client for the Dropbox client. 
"""

_cmdline_parser = argparse.ArgumentParser(description=cmdline_desc)
_cmdline_parser.add_argument(
    '-v',
    '--verbose',
    action='store_true',
    help='Print debugging statements.',
)
_cmdline_parser.add_argument(
    'spec',
    nargs='*',
    type=str,
    help='Path to API specifications. Each must have a .stone extension.',
)
_cmdline_parser.add_argument(
    '-s',
    '--stone',
    type=str,
    help='Path to clone of stone repository.',
)
_cmdline_parser.add_argument(
    '-o',
    '--output-path',
    type=str,
    help='Path to generation output.',
)
_cmdline_parser.add_argument(
    '--objc',
    action='store_true',
    help='Generate objective-c routes',
)
_cmdline_parser.add_argument(
    '-r',
    '--route-whitelist-filter',
    type=str,
    help='Path to route whitelist filter used by Stone. See stone -r for detailed instructions.',
)
_cmdline_parser.add_argument(
    '-d',
    '--documentation',
    action='store_true',
    help='Sets whether documentation file should be generated.',
)

def main():
    """The entry point for the program."""

    args = _cmdline_parser.parse_args()
    verbose = args.verbose

    if args.spec:
        specs = args.spec
    else:
        # If no specs were specified, default to the spec submodule.
        specs = glob.glob('spec/*.stone')  # Arbitrary sorting
        specs.sort()

    specs = [os.path.join(os.getcwd(), s) for s in specs]

    stone_path = os.path.abspath('stone')
    if args.stone:
        stone_path = args.stone

    dropbox_default_output_path = 'Source/SwiftyDropbox/Shared/Generated'
    dropbox_objc_output_path = 'Source/SwiftyDropboxObjC/Shared/Generated'
    dropbox_pkg_path = args.output_path if args.output_path else dropbox_default_output_path
    dropbox_objc_pkg_path = args.output_path if args.output_path else dropbox_objc_output_path

    # we run stone generation relative to the stone module,
    # so we make our output path absolute here so it's relative to where we are called
    if not os.path.isabs(dropbox_pkg_path):
        dropbox_pkg_path = os.path.abspath(dropbox_pkg_path)

    if not os.path.isabs(dropbox_objc_pkg_path):
        dropbox_objc_pkg_path = os.path.abspath(dropbox_objc_pkg_path)

    # clear out all old files
    if args.objc:
        if os.path.exists(dropbox_objc_pkg_path):
            shutil.rmtree(dropbox_objc_pkg_path)
        os.makedirs(dropbox_objc_pkg_path)
    else:
        if os.path.exists(dropbox_pkg_path):
            shutil.rmtree(dropbox_pkg_path)
        os.makedirs(dropbox_pkg_path)

    if verbose:
        print('Dropbox package path: %s' % dropbox_pkg_path)
        print('Dropbox objc package path: %s' % dropbox_objc_pkg_path)
        print('Generating Swift types')

    stone_cmd_prefix = [
        sys.executable,
        '-m', 'stone.cli',
        '-a', 'host',
        '-a', 'style',
        '-a', 'auth',
    ]

    if args.route_whitelist_filter:
        stone_cmd_prefix += ['-r', args.route_whitelist_filter]

    output_path = dropbox_objc_pkg_path if args.objc else dropbox_pkg_path
    types_cmd = list(stone_cmd_prefix + ['swift_types', output_path] + specs)

    if args.objc or args.documentation:
        types_cmd.append('--')
        if args.objc:
            types_cmd.append('--objc')
        if args.documentation:
            types_cmd.append('--documentation')

    o = subprocess.check_output(
        (types_cmd),
        cwd=stone_path)
    if o:
        print('Output:', o)

    client_args = _get_client_args()
    style_to_request = _get_style_to_request()

    if verbose:
        print('Generating Swift user and team clients')

    route_attrs = ['-a', 'scope']
    swift_client = ['swift_client', output_path]

    base_args = ['-b', 'team', '--', '-w', 'user', '-m', 'Base', '-c', 'DropboxBase',
            '-t', 'DropboxTransportClient', '-y', client_args, '-z', style_to_request]
    team_args = ['-w', 'team', '--', '-w', 'team', '-m', 'BaseTeam', '-c', 'DropboxTeamBase',
            '-t', 'DropboxTransportClient', '-y', client_args, '-z', style_to_request]
    app_args = ['--', '-w', 'app', '-m', 'BaseApp', '-c', 'DropboxAppBase',
            '-t', 'DropboxTransportClient', '-y', client_args, '-z', style_to_request]


    if args.objc:
        base_args.append('--objc')
        team_args.append('--objc')
        app_args.append('--objc')

    o = subprocess.check_output(
        (stone_cmd_prefix + route_attrs + swift_client + specs + base_args),
        cwd=stone_path)
    if o:
        print('Output:', o)
    o = subprocess.check_output(
        (stone_cmd_prefix + route_attrs + swift_client + specs + team_args),
        cwd=stone_path)
    if o:
        print('Output:', o)

    o = subprocess.check_output(
        (stone_cmd_prefix + route_attrs + swift_client + specs + app_args),
        cwd=stone_path)
    if o:
        print('Output:', o)

def _get_client_args():
    input_doc = "The file to upload, as an {} object."
    dest_doc = ('The location to write the download to.')

    overwrite_doc = ('A boolean to set behavior in the event of a naming conflict. `True` will '
        + 'overwrite conflicting file at destination. `False` will take no action (but '
        + 'if left unhandled in destination closure, an NSError will be thrown).')

    client_args = {
        'upload': [
            ('upload', [('input', '.data(input)', 'Data', input_doc.format('Data')),]),
            ('upload', [('input', '.file(input)', 'URL', input_doc.format('URL')),]),
            ('upload', [('input', '.stream(input)', 'InputStream', input_doc.format('InputStream')),]),
        ],
        'download': [
            ('download_file', [('overwrite', 'overwrite', 'Bool = false', overwrite_doc),
                ('destination', 'destination', 'URL', dest_doc)]),
            ('download_memory', []),
        ],
    }

    return json.dumps(client_args)

def _get_style_to_request():
    style_to_request = {
        'rpc': 'RpcRequest',
        'upload': 'UploadRequest',
        'download_file': 'DownloadRequestFile',
        'download_memory': 'DownloadRequestMemory',
    }

    return json.dumps(style_to_request)

if __name__ == '__main__':
    main()
