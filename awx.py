#!/usr/bin/env python3
"""
awx - Another wxWidgets Installer
Instalador não oficial para compilações pré-compiladas do wxWidgets
"""

import argparse
import os
import sys
import json
import tarfile
import shutil
from pathlib import Path
from urllib.request import urlretrieve
from urllib.error import URLError

VERSION = "1.0.0"
DEFAULT_BASE_URL = "http://wxwidgets.com.br/wxwidgets"
DEFAULT_INSTALL_DIR = Path.home() / ".local" / "wxwidgets"


class AWXInstaller:
    def __init__(self, base_url=DEFAULT_BASE_URL, install_dir=DEFAULT_INSTALL_DIR):
        self.base_url = base_url
        self.install_dir = Path(install_dir)
        self.install_dir.mkdir(parents=True, exist_ok=True)

    def list_available(self):
        """Lista compilações disponíveis no servidor"""
        print("Compilações disponíveis:")
        print("\nLinux:")
        print("  - linux 3.2.4")
        print("  - linux 3.3.1")
        print("  - linux-cmake 3.2.4")
        print("  - linux-cmake 3.3.1")
        print("\nWindows:")
        print("  - windows 3.2.4")
        print("  - windows 3.3.1")
        print("\nAndroid:")
        print("  - android 3.2.4 debug")
        print("  - android 3.2.4 release")

    def list_installed(self):
        """Lista compilações instaladas localmente"""
        if not self.install_dir.exists():
            print("Nenhuma compilação instalada")
            return

        installed = list(self.install_dir.iterdir())
        if not installed:
            print("Nenhuma compilação instalada")
            return

        print("Compilações instaladas:")
        for item in sorted(installed):
            if item.is_dir():
                print(f"  - {item.name}")

    def _download_file(self, url, dest):
        """Baixa arquivo com barra de progresso"""
        def progress(block_num, block_size, total_size):
            downloaded = block_num * block_size
            percent = min(downloaded * 100 / total_size, 100)
            bar_length = 40
            filled = int(bar_length * percent / 100)
            bar = '=' * filled + '-' * (bar_length - filled)
            print(f'\r[{bar}] {percent:.1f}%', end='', flush=True)

        try:
            urlretrieve(url, dest, progress)
            print()  # Nova linha após o download
        except URLError as e:
            print(f"\nErro ao baixar: {e}")
            return False
        return True

    def _get_archive_name(self, platform, version, variant=None):
        """Gera nome do arquivo baseado nos parâmetros"""
        if platform == "linux":
            if variant == "cmake":
                return f"linux-cmake-wx-{version}.tar.gz"
            return f"linux-wx-{version}.tar.gz"
        elif platform == "windows":
            return f"windows-wx-{version}.tar.gz"
        elif platform == "android":
            build_type = variant.upper() if variant else "RELEASE"
            return f"android-wx-{version}-{build_type}.tar.gz"
        return None

    def _get_install_path(self, platform, version, variant=None):
        """Gera path de instalação"""
        if platform == "linux":
            if variant == "cmake":
                return self.install_dir / f"linux-cmake-wx-{version}"
            return self.install_dir / f"linux-wx-{version}"
        elif platform == "windows":
            return self.install_dir / f"windows-wx-{version}"
        elif platform == "android":
            build_type = variant.upper() if variant else "RELEASE"
            return self.install_dir / f"android-wx-{version}-{build_type}"
        return None

    def install(self, platform, version, variant=None):
        """Instala uma compilação específica"""
        archive_name = self._get_archive_name(platform, version, variant)
        if not archive_name:
            print(f"Plataforma inválida: {platform}")
            return False

        install_path = self._get_install_path(platform, version, variant)

        # Verifica se já está instalado
        if install_path.exists():
            print(f"Compilação já instalada em: {install_path}")
            return True

        # Baixa o arquivo
        url = f"{self.base_url}/{archive_name}"
        temp_file = self.install_dir / archive_name

        print(f"Baixando {archive_name}...")
        if not self._download_file(url, temp_file):
            return False

        # Extrai o arquivo
        print(f"Extraindo para {install_path}...")
        try:
            with tarfile.open(temp_file, 'r:gz') as tar:
                tar.extractall(self.install_dir)

            # Remove o arquivo temporário
            temp_file.unlink()

            print(f"✓ Instalado com sucesso em: {install_path}")
            return True

        except Exception as e:
            print(f"Erro ao extrair: {e}")
            if temp_file.exists():
                temp_file.unlink()
            return False

    def remove(self, platform, version, variant=None):
        """Remove uma compilação instalada"""
        install_path = self._get_install_path(platform, version, variant)

        if not install_path.exists():
            print(f"Compilação não encontrada: {install_path.name}")
            return False

        try:
            shutil.rmtree(install_path)
            print(f"✓ Removido: {install_path.name}")
            return True
        except Exception as e:
            print(f"Erro ao remover: {e}")
            return False


def main():
    parser = argparse.ArgumentParser(
        description='awx - Another wxWidgets Installer',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  awx list-available              Lista compilações disponíveis
  awx list-installed              Lista compilações instaladas
  awx install linux 3.2.4         Instala wxWidgets 3.2.4 para Linux
  awx install linux 3.3.1 cmake   Instala wxWidgets 3.3.1 (CMake) para Linux
  awx install android 3.2.4 debug Instala wxWidgets 3.2.4 Debug para Android
  awx remove windows 3.2.4        Remove wxWidgets 3.2.4 para Windows
        """
    )

    parser.add_argument('--version', action='version',
                        version=f'awx {VERSION}')
    parser.add_argument(
        '--base-url', help=f'URL base do servidor (padrão: {DEFAULT_BASE_URL})')
    parser.add_argument(
        '--install-dir', help=f'Diretório de instalação (padrão: {DEFAULT_INSTALL_DIR})')

    subparsers = parser.add_subparsers(
        dest='command', help='Comandos disponíveis')

    # list-available
    subparsers.add_parser(
        'list-available', help='Lista compilações disponíveis no servidor')

    # list-installed
    subparsers.add_parser(
        'list-installed', help='Lista compilações instaladas')

    # install
    install_parser = subparsers.add_parser(
        'install', help='Instala uma compilação')
    install_parser.add_argument('platform', choices=['linux', 'windows', 'android'],
                                help='Plataforma alvo')
    install_parser.add_argument(
        'version', help='Versão do wxWidgets (ex: 3.2.4)')
    install_parser.add_argument('variant', nargs='?',
                                help='Variante (cmake para linux, debug/release para android)')

    # remove
    remove_parser = subparsers.add_parser(
        'remove', help='Remove uma compilação instalada')
    remove_parser.add_argument('platform', choices=['linux', 'windows', 'android'],
                               help='Plataforma alvo')
    remove_parser.add_argument(
        'version', help='Versão do wxWidgets (ex: 3.2.4)')
    remove_parser.add_argument('variant', nargs='?',
                               help='Variante (cmake para linux, debug/release para android)')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 1

    # Inicializa o instalador
    base_url = args.base_url or DEFAULT_BASE_URL
    install_dir = args.install_dir or DEFAULT_INSTALL_DIR
    installer = AWXInstaller(base_url, install_dir)

    # Executa comando
    if args.command == 'list-available':
        installer.list_available()
    elif args.command == 'list-installed':
        installer.list_installed()
    elif args.command == 'install':
        success = installer.install(args.platform, args.version, args.variant)
        return 0 if success else 1
    elif args.command == 'remove':
        success = installer.remove(args.platform, args.version, args.variant)
        return 0 if success else 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
