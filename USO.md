# Modo Debug do awx

O modo `--debug` permite simular operações sem executá-las, mostrando exatamente o que seria feito.

## 🎯 Uso Básico

```bash
awx --debug <comando> [argumentos]
```

## 📋 Exemplos

### 1. Simular instalação Linux

```bash
awx --debug install linux 3.2.4
```

**Output esperado:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets

[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====
[DEBUG] Plataforma: linux
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: padrão
[DEBUG]
[DEBUG] Arquivo: linux-wx-3.2.4.tar.gz
[DEBUG] URL de download: http://wxwidgets.com.br:8899/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG] Arquivo temporário: /home/user/.local/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG] Destino final: /home/user/.local/wxwidgets/linux-wx-3.2.4
[DEBUG]
[DEBUG] Passos que seriam executados:
[DEBUG]   1. Verificar se /home/user/.local/wxwidgets/linux-wx-3.2.4 já existe
[DEBUG]      → Não existe, prosseguiria
[DEBUG]   2. Baixar de http://wxwidgets.com.br:8899/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG]      → Salvar em /home/user/.local/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG]   3. Extrair arquivo tar.gz
[DEBUG]      → Destino: /home/user/.local/wxwidgets
[DEBUG]   4. Remover arquivo temporário
[DEBUG]   5. Mostrar componentes instalados:
[DEBUG]      - Script de build
[DEBUG]      - Diretório de instalação: /home/user/.local/wxwidgets/linux-wx-3.2.4
[DEBUG]      - Diretório fonte (para resolver links)
[DEBUG]
[DEBUG] ===== FIM DA SIMULAÇÃO =====
```

### 2. Simular instalação com variante (CMake)

```bash
awx --debug install linux 3.2.4 cmake
```

**Output:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets

[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====
[DEBUG] Plataforma: linux
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: cmake
[DEBUG]
[DEBUG] Arquivo: linux-cmake-wx-3.2.4.tar.gz
[DEBUG] URL de download: http://wxwidgets.com.br:8899/wxwidgets/linux-cmake-wx-3.2.4.tar.gz
[DEBUG] Arquivo temporário: /home/user/.local/wxwidgets/linux-cmake-wx-3.2.4.tar.gz
[DEBUG] Destino final: /home/user/.local/wxwidgets/linux-cmake-wx-3.2.4
...
```

### 3. Simular instalação Android Debug

```bash
awx --debug install android 3.2.4 debug
```

**Output:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets

[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====
[DEBUG] Plataforma: android
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: debug
[DEBUG]
[DEBUG] Arquivo: android-wx-3.2.4-DEBUG.tar.gz
[DEBUG] URL de download: http://wxwidgets.com.br:8899/wxwidgets/android-wx-3.2.4-DEBUG.tar.gz
...
```

### 4. Simular remoção

```bash
awx --debug remove linux 3.2.4
```

**Output esperado:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets

[DEBUG] ===== SIMULAÇÃO DE REMOÇÃO =====
[DEBUG] Plataforma: linux
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: padrão
[DEBUG]
[DEBUG] Caminho a remover: /home/user/.local/wxwidgets/linux-wx-3.2.4
[DEBUG]
[DEBUG] Passos que seriam executados:
[DEBUG]   1. Verificar se /home/user/.local/wxwidgets/linux-wx-3.2.4 existe
[DEBUG]      → Existe, seria removido
[DEBUG]   2. Remover diretório recursivamente
[DEBUG]      → shutil.rmtree(/home/user/.local/wxwidgets/linux-wx-3.2.4)
[DEBUG]   3. Também seria necessário remover:
[DEBUG]      → Diretório fonte: /home/user/.local/wxwidgets/wxWidgets-3.2.4-linux
[DEBUG]        (existe)
[DEBUG]      → Script: /home/user/.local/wxwidgets/build-linux-3.2.4.sh
[DEBUG]
[DEBUG] NOTA: Atualmente apenas /home/user/.local/wxwidgets/linux-wx-3.2.4 seria removido
[DEBUG]       Os outros componentes precisam ser removidos manualmente
[DEBUG]
[DEBUG] ===== FIM DA SIMULAÇÃO =====
```

### 5. Listar instalados (debug)

```bash
awx --debug list-installed
```

**Output:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets
[DEBUG] Listaria instalações em: /home/user/.local/wxwidgets
[DEBUG] Verificaria existência do diretório
[DEBUG] Iteraria sobre subdiretórios
```

### 6. Diretório customizado + debug

```bash
awx --debug --install-dir ~/my-wx install linux 3.2.4
```

**Output:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/my-wx

[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====
[DEBUG] Plataforma: linux
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: padrão
[DEBUG]
[DEBUG] Arquivo: linux-wx-3.2.4.tar.gz
[DEBUG] URL de download: http://wxwidgets.com.br:8899/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG] Arquivo temporário: /home/user/my-wx/linux-wx-3.2.4.tar.gz
[DEBUG] Destino final: /home/user/my-wx/linux-wx-3.2.4
...
```

### 7. URL customizada + debug

```bash
awx --debug --base-url https://meu-servidor.com/wx install linux 3.2.4
```

**Output:**
```
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets

[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====
[DEBUG] Plataforma: linux
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: padrão
[DEBUG]
[DEBUG] Arquivo: linux-wx-3.2.4.tar.gz
[DEBUG] URL de download: https://meu-servidor.com/wx/linux-wx-3.2.4.tar.gz
[DEBUG] Arquivo temporário: /home/user/.local/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG] Destino final: /home/user/.local/wxwidgets/linux-wx-3.2.4
...
```

## 🎯 Casos de Uso

### Verificar antes de instalar
```bash
# Ver exatamente o que será baixado e instalado
awx --debug install android 3.2.4 release

# Se estiver correto, execute sem --debug
awx install android 3.2.4 release
```

### Testar configuração de servidor
```bash
# Verificar se a URL está correta antes de tentar baixar
awx --debug --base-url https://novo-servidor.com/wxwidgets install linux 3.2.4
```

### Verificar conflitos de instalação
```bash
# Ver onde seria instalado
awx --debug --install-dir /opt/wxwidgets install linux 3.2.4
```

### Treinar/documentar comandos
```bash
# Gerar documentação dos passos sem executar
awx --debug install linux 3.2.4 > install-steps.txt
```

### Verificar componentes que seriam removidos
```bash
# Ver todos os arquivos relacionados antes de remover
awx --debug remove android 3.2.4 debug
```

## 💡 Dicas

1. **Use debug para testar URLs**: Antes de configurar uma nova URL de servidor, use `--debug` para ver se os caminhos estão corretos

2. **Combine com outras flags**: O modo debug funciona com todas as outras opções (`--base-url`, `--install-dir`)

3. **Não cria diretórios**: Em modo debug, nenhum diretório é criado, nenhum arquivo é baixado

4. **Safe para scripts**: Você pode usar em scripts para gerar logs ou validar configurações sem risco

5. **Troubleshooting**: Se algo não funciona, use `--debug` para ver exatamente o que o comando tentaria fazer

## 🚨 O que NÃO acontece no modo debug

- ❌ Não cria diretórios
- ❌ Não baixa arquivos
- ❌ Não extrai arquivos
- ❌ Não remove arquivos
- ❌ Não verifica se URLs existem (apenas mostra a URL que seria usada)
- ❌ Não modifica nada no sistema

## ✅ O que acontece no modo debug

- ✅ Mostra todos os caminhos que seriam usados
- ✅ Mostra URLs que seriam acessadas
- ✅ Verifica se arquivos/diretórios existem (sem modificá-los)
- ✅ Mostra passo a passo o que seria executado
- ✅ Retorna códigos de saída apropriados (0 para sucesso, 1 para falha)
- ✅ Identifica componentes relacionados (fonte, scripts)

## 🔄 Comparação com execução real

### Instalação normal:
```bash
$ awx install linux 3.2.4
Baixando linux-wx-3.2.4.tar.gz...
[========================================] 100.0%
Extraindo para /home/user/.local/wxwidgets...
✓ Componentes extraídos:
  - Script de build
  - Diretório de instalação: /home/user/.local/wxwidgets/linux-wx-3.2.4
  - Diretório fonte (para resolver links)

✓ Instalado com sucesso em: /home/user/.local/wxwidgets/linux-wx-3.2.4
```

### Com debug:
```bash
$ awx --debug install linux 3.2.4
[DEBUG] Modo de simulação ativado - nenhuma ação será executada
[DEBUG] Diretório de instalação: /home/user/.local/wxwidgets

[DEBUG] ===== SIMULAÇÃO DE INSTALAÇÃO =====
[DEBUG] Plataforma: linux
[DEBUG] Versão: 3.2.4
[DEBUG] Variante: padrão
[DEBUG]
[DEBUG] Arquivo: linux-wx-3.2.4.tar.gz
[DEBUG] URL de download: http://wxwidgets.com.br:8899/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG] Arquivo temporário: /home/user/.local/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG] Destino final: /home/user/.local/wxwidgets/linux-wx-3.2.4
[DEBUG]
[DEBUG] Passos que seriam executados:
[DEBUG]   1. Verificar se /home/user/.local/wxwidgets/linux-wx-3.2.4 já existe
[DEBUG]      → Não existe, prosseguiria
[DEBUG]   2. Baixar de http://wxwidgets.com.br:8899/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG]      → Salvar em /home/user/.local/wxwidgets/linux-wx-3.2.4.tar.gz
[DEBUG]   3. Extrair arquivo tar.gz
[DEBUG]      → Destino: /home/user/.local/wxwidgets
[DEBUG]   4. Remover arquivo temporário
[DEBUG]   5. Mostrar componentes instalados:
[DEBUG]      - Script de build
[DEBUG]      - Diretório de instalação: /home/user/.local/wxwidgets/linux-wx-3.2.4
[DEBUG]      - Diretório fonte (para resolver links)
[DEBUG]
[DEBUG] ===== FIM DA SIMULAÇÃO =====
```

Muito mais informativo e nenhum arquivo tocado! 🎉
