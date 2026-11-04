"""Build the read-only helper using existing local MSVC/AzerothCore libraries."""
import argparse
import os
from pathlib import Path
import subprocess
import shutil

def build(source, acore_build, vcvars, output, icons=False):
    source, acore_build, vcvars, output = (Path(p).resolve() for p in (source, acore_build, vcvars, output))
    output.mkdir(parents=True, exist_ok=True)
    # Environment setup only: no credentials printed, no filesystem operations
    # composed across shells. Compilation outputs stay in the explicit folder.
    if any(c in str(vcvars) for c in '"\r\n&|<>%'):
        raise ValueError('Unsupported compiler setup path')
    setup = subprocess.check_output(f'cmd.exe /d /s /c ""{vcvars}" amd64 >nul && set"', text=True)
    env = {key.upper(): value for key, value in os.environ.items()}
    for line in setup.splitlines():
        if '=' in line and not line.startswith('='):
            key, value = line.split('=', 1)
            env[key.upper()] = value
    libraries = [acore_build / 'deps' / kind / 'RelWithDebInfo' / name for kind, name in
                 [('libmpq', 'mpq.lib'), ('zlib', 'zlib.lib'), ('bzip2', 'bzip2.lib')]]
    for path in libraries:
        if not path.is_file():
            raise ValueError('Required prebuilt library missing: ' + path.name)
    stem = 'icon_archive' if icons else 'map_archive'
    helper = Path(__file__).with_name(stem+'.cpp').resolve()
    compiler = shutil.which('cl.exe', path=env.get('PATH'))
    if not compiler:
        raise ValueError('Compiler environment did not provide cl.exe')
    command = [compiler, '/nologo', '/EHsc', '/O2', '/MD', '/std:c++17', '/DWIN32',
               '/I' + str(source / 'deps/libmpq/libmpq'), str(helper), *map(str, libraries),
               '/Fe:' + str(output / (stem+'.exe')), '/Fo:' + str(output / (stem+'.obj'))]
    subprocess.run(command, env=env, cwd=output, check=True)
    return output / (stem+'.exe')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('acore-source', 'acore-build', 'vcvars', 'output'):
        parser.add_argument('--' + name, required=True)
    parser.add_argument('--icons', action='store_true')
    args = parser.parse_args()
    build(args.acore_source, args.acore_build, args.vcvars, args.output, args.icons)
