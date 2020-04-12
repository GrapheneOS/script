#!/usr/bin/env python3

"""
A commandline tool that replace the revision reference for every project in the
platform manifest by the matching commit hash.

If the reference is already a commit hash, it's left untouched.

Run it in the repo top directory.
"""

import sys
import subprocess
import xml.sax

from xml.sax.saxutils import XMLGenerator

def getGitRevisionHash(repo, ref):
    outb = subprocess.check_output(['git', 'rev-parse', ref], cwd=repo)
    return outb.decode(sys.stdout.encoding).strip()

class ManifestWriter(XMLGenerator):
    remote_refs = dict()

    def startElement(self, name, attrs):
        if name == 'remote':
            remote_name = attrs.get('name')
            remote_ref = attrs.get('revision')
            if remote_name and remote_ref:
                self.remote_refs[remote_name] = remote_ref
        elif name == 'default':
            remote_ref = attrs.get('revision')
            if remote_ref:
                self.remote_refs['default'] = remote_ref
        elif name == 'project':
            name, attrs = self.parseProject(name, attrs)

        # Write element
        super().startElement(name, attrs)

        # The source XML has a trailing blank after the attributes
        if len(attrs) > 0:
           self._write(' ')

    def parseProject(self, name, attrs):
        groups = attrs.get('groups', '').split(',')
        if 'notdefault' in groups:
            # Ignore project marked as non-downloable
            return name, attrs
        path = attrs.get('path')
        ref = attrs.get('revision')
        if not ref:
            # Get revision tag from remote element
            remote = attrs.get('remote')
            if not remote or remote not in self.remote_refs:
                # Remote without revision tag, fallback to default
                remote = 'default'
            ref = self.remote_refs[remote]
        new_attrs = dict(attrs.items())
        new_attrs.update(revision = getGitRevisionHash(path, ref))
        return name, new_attrs

    def endDocument(self):
        self._write('\n')

def main(args):
    if len(args) != 1:
        sys.exit('Please specify the manifest filename.')
    manifest = args[0]
    writer = ManifestWriter(sys.stdout, encoding='UTF-8', short_empty_elements=True)
    xml.sax.parse(manifest, writer)

if __name__ == '__main__':
    main(sys.argv[1:])
