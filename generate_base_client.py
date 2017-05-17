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

    dropbox_pkg_path = os.path.abspath('Source/SwiftyDropbox/Shared/Generated')

    # clear out all old files
    shutil.rmtree(dropbox_pkg_path)
    os.makedirs(dropbox_pkg_path)

    if verbose:
        print('Dropbox package path: %s' % dropbox_pkg_path)

    if verbose:
        print('Generating Swift types')
    o = subprocess.check_output(
        (['python', '-m', 'stone.cli', '-a', 'host', '-a', 'style', 'swift_types', dropbox_pkg_path] +
         specs),
        cwd=stone_path)
    if o:
        print('Output:', o)

    client_args = _get_client_args()
    style_to_request = _get_style_to_request()

    if verbose:
        print('Generating Swift user and team clients')
    o = subprocess.check_output(
        (['python', '-m', 'stone.cli', '-a', 'host', '-a', 'style', 'swift_client', dropbox_pkg_path] +
         specs + ['-b', 'team', '--', '-m', 'Base', '-c', 'DropboxBase',
         '-t', 'DropboxTransportClient', '-y', client_args, '-z', style_to_request]),
        cwd=stone_path)
    if o:
        print('Output:', o)
    o = subprocess.check_output(
        (['python', '-m', 'stone.cli', '-a', 'host', '-a', 'style', 'swift_client', dropbox_pkg_path] +
         specs + ['-w', 'team', '--', '-m', 'BaseTeam', '-c', 'DropboxTeamBase',
         '-t', 'DropboxTransportClient', '-y', client_args, '-z', style_to_request]),
        cwd=stone_path)
    if o:
        print('Output:', o)

def _get_client_args():
    input_doc = "The file to upload, as an {} object."
    dest_doc = ('A closure used to compute the destination, '
        + 'given the temporary file location and the response.')

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
                ('destination', 'destination', '@escaping (URL, HTTPURLResponse) -> URL', dest_doc)]),
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
