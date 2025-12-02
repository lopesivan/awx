#!/usr/bin/env python3
"""
awx - Another wxWidgets Installer
Instalador não oficial para compilações pré-compiladas do wxWidgets,
baseado em um manifest.json com a lista de pacotes.
"""

import argparse
import sys
import json
import tarfile
import shutil
from pathlib import Path
from urllib.request import urlretrieve
from urllib.error import URLError

VERSION = "1.0.0"
DEFAULT_BASE_URL = "http://wxwidgets.com.br:8899/wxwidgets"
DEFAULT_INSTALL_DIR = Path.home() / ".local" / "wxwidgets"
MANIFEST_FILENAME = "manifest.json"


class AWXInstaller:
    def __init__(self, base_url=DEFAULT_BASE_URL, install_dir=DEFAULT_INSTALL_DIR, debug=False):
        self.base_url = base_url
        self.install_dir = Path(install_dir).expanduser()
        self.debug = debug
        self._manifest = None  # carregado sob demanda

        if not self.debug:
            self.install_dir.mkdir(parents=True, exist_ok=True)
        else:
            print(f"[DEBUG] Modo de simulação ativado - nenhuma ação será executada")
            print(f"[DEBUG] Diretório de instalação: {self.install_dir}")

    # ---------------------------
    # Manifest
    # ---------------------------
    def _manifest_path(self) -> Path:
        """Retorna o caminho local do manifest (ao lado do script)."""
        return Path(__file__).resolve().with_name(MANIFEST_FILENAME)

    def _load_manifest(self):
        """Carrega o manifest.json local apenas uma vez."""
        if self._manifest is not None:
            return self._manifest

        manifest_path = self._manifest_path()
        if self.debug:
            print(f"[DEBUG] Carregaria manifest de: {manifest_path}")

        if not manifest_path.exists():
            print(f"Erro: manifest não encontrado em {manifest_path}")
            self._manifest = None
            return None

        try:
            with manifest_path.open("r", encoding="utf-8") as f:
                self._manifest = json.load(f)
        except Exception as e:
            print(f"Erro ao ler manifest: {e}")
            self._manifest = None

        return self._manifest

    def _find_package(self, platform: str, version: str, variant: str | None):
        """
        Localiza, no manifest, o pacote correspondente a (platform, version, variant).

        Retorna um dict com:
          - package (entrada do manifest)
          - archive_name
          - install_dir_name
          - script_name
          - source_dir_name
        ou None em caso de erro.
        """
        manifest = self._load_manifest()
        if manifest is None:
            return None

        packages = manifest.get("packages", [])

        # Monta o nome esperado do arquivo conforme convenção do manifest
        if platform == "linux":
            if variant is None:
                expected_name = f"linux-wx-{version}.tar.gz"
            elif variant == "cmake":
                expected_name = f"linux-cmake-wx-{version}.tar.gz"
            else:
                print(
                    f"Variante inválida para linux: {variant}. Use 'cmake' ou deixe em branco.")
                return None

        elif platform == "windows":
            expected_name = f"windows-wx-{version}.tar.gz"

        elif platform == "android":
            # Agora a variante é a ABI (ex: arm64-v8a)
            if not variant:
                print("Para android é necessário informar a ABI (ex: arm64-v8a).")
                return None
            expected_name = f"android-{variant}-wx-{version}.tar.gz"

        else:
            print(f"Plataforma inválida: {platform}")
            return None

        for pkg in packages:
            name = pkg.get("name")
            if name == expected_name:
                components = pkg.get("components", {})
                install_dir_name = components.get("install_dir")
                script_name = components.get("script")
                source_dir_name = components.get("source_dir")

                # Fallback: se não tiver install_dir no manifest, deduzir do nome
                if not install_dir_name:
                    install_dir_name = expected_name.replace(".tar.gz", "")

                return {
                    "package": pkg,
                    "archive_name": name,
                    "install_dir_name": install_dir_name,
                    "script_name": script_name,
                    "source_dir_name": source_dir_name,
                }

        print(
            f"Pacote não encontrado no manifest para: plataforma={platform}, versão={version}, variante={variant}")
        print(f"Nome esperado: {expected_name}")
        return None

    # ---------------------------
    # Listagens
    # ---------------------------
    def list_available(self):
        """Lista compilações disponíveis baseado no manifest."""
        manifest = self._load_manifest()
        if manifest is None:
            # Fallback antigo, caso não haja manifest
            print("Compilações disponíveis (fallback):")
            print("\nLinux:")
            print("  - linux 3.2.4")
            print("  - linux 3.3.1")
            print("  - linux-cmake 3.2.4")
            print("  - linux-cmake 3.3.1")
            print("\nWindows:")
            print("  - windows 3.2.4")
            print("  - windows 3.3.1")
            print("\nAndroid:")
            print("  - android 3.2.4 arm64-v8a")
            print("  - android 3.3.1 arm64-v8a")
            return

        packages = manifest.get("packages", [])
        linux = []
        windows = []
        android = []

        for pkg in packages:
            name = pkg.get("name", "")
            if name.startswith("linux-cmake-wx-"):
                version = name.removeprefix(
                    "linux-cmake-wx-").removesuffix(".tar.gz")
                linux.append(f"linux {version} cmake")
            elif name.startswith("linux-wx-"):
                version = name.removeprefix(
                    "linux-wx-").removesuffix(".tar.gz")
                linux.append(f"linux {version}")
            elif name.startswith("windows-wx-"):
                version = name.removeprefix(
                    "windows-wx-").removesuffix(".tar.gz")
                windows.append(f"windows {version}")
            elif name.startswith("android-"):
                # Ex: android-arm64-v8a-wx-3.2.4.tar.gz
                without_prefix = name.removeprefix("android-")
                try:
                    abi, rest = without_prefix.split("-wx-", 1)
                    version = rest.removesuffix(".tar.gz")
                    android.append(f"android {version} {abi}")
                except ValueError:
                    android.append(name)

        print("Compilações disponíveis:")
        if linux:
            print("\nLinux:")
            for item in sorted(linux):
                print(f"  - {item}")
        if windows:
            print("\nWindows:")
            for item in sorted(windows):
                print(f"  - {item}")
        if android:
            print("\nAndroid:")
            for item in sorted(android):
                print(f"  - {item}")

    def list_installed(self):
        """Lista compilações instaladas localmente"""
        if self.debug:
            print(f"[DEBUG] Listaria instalações em: {self.install_dir}")
            print(f"[DEBUG] Verificaria existência do diretório")
            if self.install_dir.exists():
                print(f"[DEBUG]   → Diretório existe")
                print(f"[DEBUG] Iteraria sobre subdiretórios")
                for item in sorted(self.install_dir.iterdir()):
                    if item.is_dir():
                        print(f"[DEBUG]   → Encontrado: {item.name}")
            else:
                print(f"[DEBUG]   → Diretório não existe")
            return

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

    # ---------------------------
    # Download real
    # ---------------------------
    def _download_file(self, url, dest):
        """Baixa arquivo com barra de progresso"""
        def progress(block_num, block_size, total_size):
            downloaded = block_num * block_size
            percent = min(downloaded * 100 / total_size,
                          100) if total_size > 0 else 0
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

    # ---------------------------
    # Paths
    # ---------------------------
    def _get_install_path_from_name(self, install_dir_name: str) -> Path:
        return self.install_dir / install_dir_name

    # ---------------------------
    # Operações
    # ---------------------------
    def install(self, platform, version, variant=None):
        """Instala uma compilação específica (ou simula, em debug) usando o manifest."""
        pkg_info = self._find_package(platform, version, variant)
        if not pkg_info:
            return False

        archive_name = pkg_info["archive_name"]
        install_dir_name = pkg_info["install_dir_name"]
        script_name = pkg_info["script_name"]
        source_dir_name = pkg_info["source_dir_name"]

        install_path = self._get_install_path_from_name(install_dir_name)
        url = f"{self.base_url}/{archive_name}"
        temp_file = self.install_dir / archive_name
        variante_str = variant if variant else "padrão"

        if self.debug:
            print()
            print("[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====")
            print(f"[DEBUG] Plataforma: {platform}")
            print(f"[DEBUG] Versão: {version}")
            print(f"[DEBUG] Variante: {variante_str}")
            print("[DEBUG]")
            print(f"[DEBUG] Arquivo: {archive_name}")
            print(f"[DEBUG] URL de download: {url}")
            print(f"[DEBUG] Arquivo temporário: {temp_file}")
            print(f"[DEBUG] Destino final: {install_path}")
            print("[DEBUG]")
            print(f"[DEBUG] Passos que seriam executados:")
            print(f"[DEBUG]   1. Verificar se {install_path} já existe")
            if install_path.exists():
                print(
                    f"[DEBUG]      → Existe, instalação real falharia ou seria sobrescrita")
            else:
                print(f"[DEBUG]      → Não existe, prosseguiria")
            print(f"[DEBUG]   2. Baixar de {url}")
            print(f"[DEBUG]      → Salvar em {temp_file}")
            print(f"[DEBUG]   3. Extrair arquivo tar.gz")
            print(f"[DEBUG]      → Destino: {self.install_dir}")
            print(f"[DEBUG]   4. Remover arquivo temporário")
            print(f"[DEBUG]   5. Mostrar componentes instalados:")
            if script_name:
                print(
                    f"[DEBUG]      - Script de build: {self.install_dir / script_name}")
            else:
                print(f"[DEBUG]      - Script de build")
            print(f"[DEBUG]      - Diretório de instalação: {install_path}")
            if source_dir_name:
                print(
                    f"[DEBUG]      - Diretório fonte: {self.install_dir / source_dir_name}")
            else:
                print(f"[DEBUG]      - Diretório fonte (para resolver links)")
            print("[DEBUG]")
            print("[DEBUG] ===== FIM DA SIMULAÇÃO =====")
            return not install_path.exists()

        # Execução real
        if install_path.exists():
            print(f"Compilação já instalada em: {install_path}")
            return True

        print(f"Baixando {archive_name}...")
        if not self._download_file(url, temp_file):
            return False

        print(f"Extraindo para {self.install_dir}...")
        try:
            with tarfile.open(temp_file, 'r:gz') as tar:
                # Extrai com strip-components para remover diretório raiz, se existir
                members = tar.getmembers()
                for member in members:
                    parts = member.name.split('/', 1)
                    if len(parts) > 1:
                        member.name = parts[1]
                        tar.extract(member, self.install_dir)

            temp_file.unlink()

            print(f"✓ Componentes extraídos:")
            if script_name:
                print(f"  - Script de build: {self.install_dir / script_name}")
            else:
                print(f"  - Script de build")
            print(f"  - Diretório de instalação: {install_path}")
            if source_dir_name:
                print(
                    f"  - Diretório fonte: {self.install_dir / source_dir_name}")
            else:
                print(f"  - Diretório fonte (para resolver links)")

            print(f"\n✓ Instalado com sucesso em: {install_path}")
            return True

        except Exception as e:
            print(f"Erro ao extrair: {e}")
            if temp_file.exists():
                temp_file.unlink()
            return False

    def remove(self, platform, version, variant=None):
        """Remove uma compilação instalada (ou simula, em debug) usando o manifest quando possível."""
        pkg_info = self._find_package(platform, version, variant)
        if pkg_info:
            install_dir_name = pkg_info["install_dir_name"]
            script_name = pkg_info["script_name"]
            source_dir_name = pkg_info["source_dir_name"]
        else:
            # Fallback: tentar um padrão simples
            script_name = None
            source_dir_name = None
            if platform == "linux":
                if variant == "cmake":
                    install_dir_name = f"linux-cmake-wx-{version}"
                else:
                    install_dir_name = f"linux-wx-{version}"
            elif platform == "windows":
                install_dir_name = f"windows-wx-{version}"
            elif platform == "android":
                abi = variant or "arm64-v8a"
                install_dir_name = f"android-{abi}-wx-{version}"
            else:
                print(f"Plataforma inválida: {platform}")
                return False

        install_path = self._get_install_path_from_name(install_dir_name)
        variante_str = variant if variant else "padrão"

        if self.debug:
            print()
            print("[DEBUG] ===== SIMULAÇÃO DE REMOÇÃO =====")
            print(f"[DEBUG] Plataforma: {platform}")
            print(f"[DEBUG] Versão: {version}")
            print(f"[DEBUG] Variante: {variante_str}")
            print("[DEBUG]")
            print(f"[DEBUG] Caminho a remover: {install_path}")
            print("[DEBUG]")
            print(f"[DEBUG] Passos que seriam executados:")
            print(f"[DEBUG]   1. Verificar se {install_path} existe")
            if install_path.exists():
                print(f"[DEBUG]      → Existe, seria removido")
            else:
                print(f"[DEBUG]      → Não existe, remoção real falharia")
            print(f"[DEBUG]   2. Remover diretório recursivamente")
            print(f"[DEBUG]      → shutil.rmtree({install_path})")

            print(f"[DEBUG]   3. Também seria necessário remover:")
            if source_dir_name:
                source_dir = self.install_dir / source_dir_name
                print(f"[DEBUG]      → Diretório fonte: {source_dir}")
                print(
                    f"[DEBUG]        ({'existe' if source_dir.exists() else 'não existe'})")
            if script_name:
                script = self.install_dir / script_name
                print(f"[DEBUG]      → Script: {script}")
                print(
                    f"[DEBUG]        ({'existe' if script.exists() else 'não existe'})")
            print("[DEBUG]")
            print(
                f"[DEBUG] NOTA: Atualmente apenas {install_path} seria removido")
            print(
                f"[DEBUG]       Os outros componentes precisam ser removidos manualmente")
            print("[DEBUG]")
            print("[DEBUG] ===== FIM DA SIMULAÇÃO =====")
            return install_path.exists()

        # Execução real
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


def _preprocess_argv(raw_args):
    """
    Permite atalhos como:

      awx linux 3.2.4
      awx --debug linux 3.2.4
      awx --debug --base-url X --install-dir Y linux 3.2.4

    que serão reescritos para:

      awx install linux 3.2.4
      awx --debug install linux 3.2.4
      awx --debug --base-url X --install-dir Y install linux 3.2.4
    """
    args = list(raw_args)
    if not args:
        return args

    # Se pediu help ou version, não mexe
    for a in args:
        if a in ("-h", "--help", "--version"):
            return args

    platforms = {"linux", "windows", "android"}
    commands = {"list-available", "list-installed", "install", "remove"}

    # Acha o primeiro token que não é opção (-algo)
    for i, a in enumerate(args):
        if a.startswith("-"):
            continue

        # Se já é um comando conhecido, não mexe
        if a in commands:
            return args

        # Se é uma plataforma, insere "install" antes
        if a in platforms:
            return args[:i] + ["install"] + args[i:]

        # Qualquer outra coisa: deixa o argparse reclamar
        return args

    return args


def main():
    parser = argparse.ArgumentParser(
        description='awx - Another wxWidgets Installer',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  awx list-available                      Lista compilações disponíveis
  awx list-installed                      Lista compilações instaladas
  awx install linux 3.2.4                 Instala wxWidgets 3.2.4 para Linux
  awx install linux 3.3.1 cmake           Instala wxWidgets 3.3.1 (CMake) para Linux
  awx install android 3.2.4 arm64-v8a     Instala wxWidgets 3.2.4 (arm64-v8a) para Android
  awx remove windows 3.2.4                Remove wxWidgets 3.2.4 para Windows

Atalhos:
  awx linux 3.2.4                         ≡ awx install linux 3.2.4
  awx --debug linux 3.2.4                 ≡ awx --debug install linux 3.2.4
        """
    )

    parser.add_argument('--version', action='version',
                        version=f'awx {VERSION}')
    parser.add_argument(
        '--base-url', help=f'URL base do servidor (padrão: {DEFAULT_BASE_URL})')
    parser.add_argument(
        '--install-dir', help=f'Diretório de instalação (padrão: {DEFAULT_INSTALL_DIR})')
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Ativa modo de simulação (não faz alterações no sistema)'
    )

    subparsers = parser.add_subparsers(
        dest='command', help='Comandos disponíveis')

    # list-available
    subparsers.add_parser(
        'list-available', help='Lista compilações disponíveis no servidor (via manifest)')

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
    install_parser.add_argument(
        'variant',
        nargs='?',
        help='Variante (cmake para linux, arm64-v8a para android)'
    )

    # remove
    remove_parser = subparsers.add_parser(
        'remove', help='Remove uma compilação instalada')
    remove_parser.add_argument('platform', choices=['linux', 'windows', 'android'],
                               help='Plataforma alvo')
    remove_parser.add_argument(
        'version', help='Versão do wxWidgets (ex: 3.2.4)')
    remove_parser.add_argument(
        'variant',
        nargs='?',
        help='Variante (cmake para linux, arm64-v8a para android)'
    )

    # Pré-processa argv para suportar atalhos
    raw_args = sys.argv[1:]
    processed_args = _preprocess_argv(raw_args)

    args = parser.parse_args(processed_args)

    if not args.command:
        parser.print_help()
        return 1

    base_url = args.base_url or DEFAULT_BASE_URL
    install_dir = args.install_dir or DEFAULT_INSTALL_DIR
    installer = AWXInstaller(base_url, install_dir, debug=args.debug)

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
