<img width="1080" height="2280" alt="Screenshot_1766463473" src="https://github.com/user-attachments/assets/8d824767-a0ac-4114-aed0-62ebef65a1ff" />

<img width="1080" height="2280" alt="Screenshot_1766463475" src="https://github.com/user-attachments/assets/07c7cc43-0105-4abd-8f82-f053a44898ee" />

# Crypto Fetch App

Aplicação Flutter para explorar criptomoedas em tempo real com dados da API CoinCap. Estruturada em MVVM com gerenciamento de estado reativo usando Provider.

## 🚀 Funcionalidades

- **Listagem de Criptomoedas**: Visualize uma lista atualizada de ativos digitais com preços em tempo real
- **Pesquisa Integrada**: Busque criptomoedas por nome ou símbolo diretamente na tela inicial
- **Top 3 por Market Cap**: Gráfico mostrando os 3 maiores ativos por capitalização de mercado
- **Favoritos**: Marque e gerencie seus ativos favoritos
- **Preços em Tempo Real**: WebSocket Binance para atualizações instantâneas de preços
- **Interface Responsiva**: Design moderno com tema escuro

## � Pré-requisitos

Antes de começar, certifique-se de ter instalado:

### Flutter
- **Flutter SDK** (versão 3.0+): [Baixe aqui](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (incluído no Flutter)

### Dependências do Sistema

Para executar este projeto, você precisará de:

- **Git**: Para clonar o repositório
- **Java Development Kit (JDK)** 11+: Para compilar aplicações Android
- **Android Studio**: Para SDK e emulador Android

### Android Setup

#### Instale o Android SDK
1. Baixe o [Android Studio](https://developer.android.com/studio)
2. Abra o Android Studio
3. Vá em **Preferences/Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
4. Selecione as abas necessárias:
   - Android SDK Platforms (Android 13+)
   - Android SDK Tools (Build Tools, Platform Tools)

#### Configure o emulador Android
```bash
# Liste dispositivos virtuais disponíveis
flutter emulators

# Crie um novo emulador (se necessário)
flutter emulators create --name pixel_5

# Inicie o emulador
flutter emulators launch pixel_5
```

#### Configure variáveis de ambiente
```bash
# Adicione ao seu shell profile (~/.bashrc, ~/.zshrc, etc.)
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

## 🔑 Configuração da API Key

Este projeto usa a [API CoinCap](https://rest.coincap.io) para dados de criptomoedas.

### 1. Gere sua API Key

Visite [https://pro.coincap.io/dashboard](https://pro.coincap.io/dashboard) e:
1. Crie uma conta ou faça login
2. Acesse o dashboard
3. Gere uma nova API Key

### 2. Configure o arquivo `.env`

Na raiz do projeto, crie um arquivo `.env` baseado em `.env.example`:

```bash
cp .env.example .env
```

Edite o arquivo `.env` e adicione sua API Key:

```dotenv
COINCAP_API_KEY="sua_chave_aqui"
```

⚠️ **Importante**: Nunca commite o arquivo `.env` com suas chaves reais no repositório. O arquivo `.env` está no `.gitignore`.

## 📦 Instalação e Execução

### 1. Clone o repositório
```bash
git clone https://github.com/KenzoUMZ/Crypto-Fetch-App.git
cd Crypto-Fetch-App
```

### 2. Instale as dependências Flutter
```bash
flutter pub get
```

### 3. Configure a API Key (veja seção acima)

### 4. Execute o app

#### No emulador Android
```bash
flutter run
```

#### Em um dispositivo Android físico (conectado via USB)
```bash
flutter run
```

## 🔌 APIs Utilizadas

### CoinCap REST API
- **Base URL**: `https://rest.coincap.io/v3`
- **Dados**: Preços, mercado cap, volume de trading
- **Documentação**: https://docs.coincap.io

### Binance WebSocket
- **URL**: `wss://stream.binance.com:9443`
- **Dados**: Preços em tempo real via streaming
- **Pairs**: `btcusdt@trade`, `ethusdt@trade`, etc.

## 🛠️ Dependências Principais

```yaml
provider: ^6.0.0              # Gerenciamento de estado
cached_network_image: ^3.0.0  # Cache de imagens de ícones
shared_preferences: ^2.0.0    # Armazenamento local
web_socket_channel: ^2.0.0    # WebSocket para preços reais
http: ^1.0.0                  # Requisições HTTP
flutter_dotenv: ^5.0.0        # Variáveis de ambiente
localization: ^2.0.0          # Internacionalização
```

## 📱 Estrutura do Projeto

### Models
- **Asset**: Representação de uma criptomoeda
- **AggTrade**: Dados de trades agregados

### ViewModels
- **AssetViewModel**: Gerencia lista de ativos, favoritos, pesquisa
- **Atualiza em tempo real** via WebSocket Binance

### Views
- **HomeView**: Tela principal com lista e pesquisa
- **FavoritesView**: Seus ativos favoritos salvos
- **MainView**: Navegação entre telas

### Widgets
- **AssetCard**: Card genérico para exibir ativos
- **CryptoAvatar**: Avatar com ícone da criptomoeda
- **TopThreeChart**: Gráfico dos top 3 por market cap
