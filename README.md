# awx - Another wxWidgets Installer

Instalador não oficial para compilações pré-compiladas
do wxWidgets, inspirado no `aqt`.

## 🚀 Instalação do awx

```bash
# Copie o script awx para um diretório no PATH
sudo cp awx /usr/local/bin/
sudo chmod +x /usr/local/bin/awx
```

Ou use diretamente:
```bash
python3 awx install linux 3.2.4
```

## 📦 Preparando Pacotes (Servidor)

1. **Empacote suas compilações:**
```bash
chmod +x prepare-wxwidgets-packages.sh
./prepare-wxwidgets-packages.sh
```

2. **Faça upload para seu servidor:**
```bash
# Com rsync
rsync -avz wxwidgets-packages/ usuario@servidor.com:/var/www/wxwidgets/

# Ou com scp
scp -r wxwidgets-packages/* usuario@servidor.com:/var/www/wxwidgets/
```

3. **Configure o servidor web** (exemplo nginx):
```nginx
server {
    listen 80;
    server_name wxwidgets.seu-servidor.com;

    location / {
        root /var/www/wxwidgets;
        autoindex on;
    }
}
```

## 💻 Usando o awx (Cliente)

### Listar compilações disponíveis
```bash
awx list-available
```

### Listar compilações instaladas
```bash
awx list-installed
```

### Instalar compilações

**Linux:**
```bash
awx install linux 3.2.4
awx install linux 3.3.1
awx install linux 3.3.1 cmake
```

**Windows:**
```bash
awx install windows 3.2.4
awx install windows 3.3.1
```

**Android:**
```bash
awx install android 3.2.4 debug
awx install android 3.2.4 release
```

### Remover compilações
```bash
awx remove linux 3.2.4
awx remove android 3.2.4 debug
```

### Configurar URL customizada
```bash
awx --base-url https://meu-servidor.com/wx install linux 3.2.4
```

### Diretório de instalação customizado
```bash
awx --install-dir ~/meus-frameworks/wxwidgets install linux 3.2.4
```

## 📁 Estrutura de Diretórios

**Padrão de instalação:**
```
~/.local/wxwidgets/
├── linux-wx-3.2.4/
├── linux-wx-3.3.1/
├── linux-cmake-wx-3.2.4/
├── linux-cmake-wx-3.3.1/
├── windows-wx-3.2.4/
├── windows-wx-3.3.1/
├── android-wx-3.2.4-DEBUG/
└── android-wx-3.2.4-RELEASE/
```

**Servidor:**
```
/var/www/wxwidgets/
├── linux-wx-3.2.4.tar.gz
├── linux-wx-3.3.1.tar.gz
├── linux-cmake-wx-3.2.4.tar.gz
├── linux-cmake-wx-3.3.1.tar.gz
├── windows-wx-3.2.4.tar.gz
├── windows-wx-3.3.1.tar.gz
├── android-wx-3.2.4-DEBUG.tar.gz
├── android-wx-3.2.4-RELEASE.tar.gz
└── manifest.json
```

## 🔧 Usando as compilações instaladas

### CMake
```cmake
# Linux
set(wxWidgets_ROOT_DIR "$ENV{HOME}/.local/wxwidgets/linux-wx-3.2.4")
find_package(wxWidgets REQUIRED)

# Linux (CMake build)
set(wxWidgets_ROOT_DIR "$ENV{HOME}/.local/wxwidgets/linux-cmake-wx-3.2.4")
find_package(wxWidgets REQUIRED)

# Windows
set(wxWidgets_ROOT_DIR "$ENV{HOME}/.local/wxwidgets/windows-wx-3.2.4")
find_package(wxWidgets REQUIRED)
```

### Variáveis de ambiente
```bash
# Linux
export WXWIN=$HOME/.local/wxwidgets/linux-wx-3.2.4
export PATH=$WXWIN/bin:$PATH
export LD_LIBRARY_PATH=$WXWIN/lib:$LD_LIBRARY_PATH

# Android
export WXWIN=$HOME/.local/wxwidgets/android-wx-3.2.4-RELEASE
```

### wx-config
```bash
# Adicione ao PATH
export PATH=$HOME/.local/wxwidgets/linux-wx-3.2.4/bin:$PATH

# Use normalmente
g++ myapp.cpp `wx-config --cxxflags --libs`
```

## 🎯 Exemplos de Workflow

### Setup completo para desenvolvimento Linux
```bash
# Instala versão padrão e CMake
awx install linux 3.2.4
awx install linux 3.2.4 cmake

# Adiciona ao .bashrc ou .zshrc
echo 'export WXWIN=$HOME/.local/wxwidgets/linux-wx-3.2.4' >> ~/.bashrc
echo 'export PATH=$WXWIN/bin:$PATH' >> ~/.bashrc
```

### Setup para cross-compilation Android
```bash
# Instala debug e release
awx install android 3.2.4 debug
awx install android 3.2.4 release

# Usa no CMake
# -DWXWIN=$HOME/.local/wxwidgets/android-wx-3.2.4-RELEASE
```

## 🛠️ Desenvolvimento

### Adicionar nova versão
1. Compile o wxWidgets
2. Coloque na estrutura de diretórios correta
3. Execute `prepare-wxwidgets-packages.sh`
4. Faça upload dos novos arquivos

### Estrutura esperada dos diretórios
Cada diretório deve conter a instalação completa do wxWidgets:
```
linux-wx-3.2.4/
├── bin/
├── include/
├── lib/
└── share/
```

## 📝 Notas

- Os pacotes são compactados com gzip para economizar largura de banda
- SHA256 checksums são gerados para verificação de integridade
- Instalações paralelas são suportadas (múltiplas versões simultaneamente)
- O diretório padrão `~/.local/wxwidgets` segue o padrão FHS do Linux

## 🐛 Troubleshooting

**Erro de download:**
```bash
# Verifique a URL
awx --base-url https://seu-servidor.com/wxwidgets list-available
```

**Permissões:**
```bash
# Se não conseguir escrever em ~/.local
awx --install-dir ~/meu-diretorio install linux 3.2.4
```

**Compilação não encontrada após instalação:**
```bash
# Liste instaladas
awx list-installed

# Verifique o PATH
echo $PATH | grep wxwidgets
```

## 📄 Licença

Ferramenta de distribuição. O wxWidgets possui sua própria licença (wxWindows Library Licence).
