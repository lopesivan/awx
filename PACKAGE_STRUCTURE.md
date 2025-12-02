# Estrutura dos Pacotes wxWidgets

## 📦 Composição de cada pacote

Cada arquivo `.tar.gz` contém **3 componentes essenciais**:

```
wxwidgets-package/
├── build-*.sh              # Script de build original
├── *-wx-*/                 # Diretório de instalação (bin, lib, include)
└── wxWidgets-*-*/          # Código fonte (resolve links simbólicos)
```

## 🔗 Por que incluir o código fonte?

Durante a compilação, o wxWidgets cria **links simbólicos** na instalação que apontam para arquivos no diretório fonte original:

```bash
# Exemplo de links encontrados:
linux-wx-3.2.4/lib/wx/include/gtk3-unicode-3.2/wx/setup.h 
  → ../../../../../wxWidgets-3.2.4-linux/lib/wx/include/gtk3-unicode-3.2/wx/setup.h

linux-wx-3.2.4/include/wx-3.2/wx/version.h
  → ../../../../wxWidgets-3.2.4-linux/include/wx-3.2/wx/version.h
```

Sem o código fonte, esses links ficam **quebrados** e a compilação falha.

## 📋 Exemplos de estrutura por plataforma

### Linux 3.2.4 (Makefile)
```
linux-wx-3.2.4.tar.gz
└── wxwidgets-package/
    ├── build-linux-3.2.4.sh
    ├── linux-wx-3.2.4/
    │   ├── bin/
    │   │   └── wx-config
    │   ├── include/
    │   │   └── wx-3.2/
    │   ├── lib/
    │   │   ├── libwx_*.so
    │   │   └── wx/
    │   └── share/
    └── wxWidgets-3.2.4-linux/
        ├── include/
        ├── lib/
        ├── src/
        └── samples/
```

### Linux 3.2.4 (CMake)
```
linux-cmake-wx-3.2.4.tar.gz
└── wxwidgets-package/
    ├── build-linux-cmake-3.2.4.sh
    ├── linux-cmake-wx-3.2.4/
    │   ├── bin/
    │   ├── include/
    │   ├── lib/
    │   │   ├── libwx_*.so
    │   │   └── cmake/
    │   │       └── wxWidgets/
    │   │           ├── wxWidgetsConfig.cmake
    │   │           └── wxWidgetsTargets.cmake
    │   └── share/
    └── wxWidgets-3.2.4-linux-cmake/
        └── (código fonte)
```

### Android 3.2.4 (Debug)
```
android-wx-3.2.4-DEBUG.tar.gz
└── wxwidgets-package/
    ├── build-android-3.2.4-debug.sh
    ├── android-debug-wx-3.2.4/
    │   ├── include/
    │   ├── lib/
    │   │   ├── arm64-v8a/
    │   │   ├── armeabi-v7a/
    │   │   ├── x86/
    │   │   └── x86_64/
    │   └── share/
    └── wxWidgets-3.2.4-android-debug/
        └── (código fonte)
```

## 🎯 Após instalação com awx

Quando você executa:
```bash
awx install linux 3.2.4
```

O `awx` extrai tudo para `~/.local/wxwidgets/`:

```
~/.local/wxwidgets/
├── build-linux-3.2.4.sh
├── linux-wx-3.2.4/          # ← PATH de instalação principal
│   ├── bin/
│   ├── include/
│   └── lib/
└── wxWidgets-3.2.4-linux/   # ← Resolve os links simbólicos
    ├── include/
    ├── lib/
    └── src/
```

## ✅ Verificando links após instalação

```bash
# Verifica se há links quebrados
find ~/.local/wxwidgets/linux-wx-3.2.4 -xtype l

# Lista todos os links (quebrados ou não)
find ~/.local/wxwidgets/linux-wx-3.2.4 -type l -ls

# Verifica para onde apontam
find ~/.local/wxwidgets/linux-wx-3.2.4 -type l -exec sh -c 'echo "{}"; readlink "{}"' \;
```

Se tudo estiver correto, **nenhum link quebrado** deve ser encontrado.

## 🔧 Uso após instalação

### Com CMake (Linux CMake build)
```cmake
set(wxWidgets_ROOT_DIR "$ENV{HOME}/.local/wxwidgets/linux-cmake-wx-3.2.4")
find_package(wxWidgets REQUIRED CONFIG)
target_link_libraries(myapp wxWidgets::Core wxWidgets::Base)
```

### Com wx-config (Linux Makefile build)
```bash
export PATH=$HOME/.local/wxwidgets/linux-wx-3.2.4/bin:$PATH
g++ myapp.cpp `wx-config --cxxflags --libs`
```

### Android (NDK)
```cmake
set(wxWidgets_ROOT_DIR "$ENV{HOME}/.local/wxwidgets/android-wx-3.2.4-RELEASE")
# Configure seu Android.mk ou CMakeLists.txt
```

## 📊 Tamanhos típicos

| Pacote | Instalação | Fonte | Total (comprimido) |
|--------|-----------|-------|-------------------|
| Linux 3.2.4 | ~50 MB | ~80 MB | ~25 MB |
| Linux CMake 3.2.4 | ~50 MB | ~80 MB | ~25 MB |
| Android 3.2.4 Debug | ~200 MB | ~80 MB | ~45 MB |
| Android 3.2.4 Release | ~80 MB | ~80 MB | ~30 MB |

## 🚨 Troubleshooting

### Links quebrados após instalação
```bash
# Isso não deveria acontecer, mas se ocorrer:
# 1. Verifique se o código fonte está presente
ls ~/.local/wxwidgets/wxWidgets-*-linux/

# 2. Verifique se os caminhos relativos estão corretos
cd ~/.local/wxwidgets/linux-wx-3.2.4
find . -type l -exec readlink {} \; | head
```

### Script de build não encontrado
```bash
# O script deve estar no diretório raiz
ls ~/.local/wxwidgets/build-*.sh
```

### Recompilar a partir do pacote instalado
```bash
cd ~/.local/wxwidgets/wxWidgets-3.2.4-linux
../build-linux-3.2.4.sh
```

## 💡 Dicas

1. **Mantenha a estrutura intacta**: Não renomeie ou mova os diretórios fonte
2. **Backup dos scripts**: Os scripts de build são úteis para recompilar
3. **Espaço em disco**: Cada pacote ocupa ~2-3x o tamanho comprimido após extração
4. **Instalações paralelas**: Você pode ter várias versões instaladas simultaneamente

## 🔄 Atualizando um pacote

```bash
# Remove a versão antiga
awx remove linux 3.2.4

# Instala a nova versão
awx install linux 3.2.4
```

O `awx` automaticamente remove todos os 3 componentes ao desinstalar.

