# 🏗️ Crypto Fetch App - Arquitetura MVVM

## 📋 Visão Geral

**Crypto Fetch App** é uma aplicação Flutter de rastreamento de criptomoedas que implementa a arquitetura **MVVM (Model-View-ViewModel)** com foco em separação de responsabilidades, testabilidade e manutenibilidade.

### 🎯 Objetivo
Fornecer uma interface moderna e responsiva para visualizar preços de criptomoedas em tempo real usando a API CoinCap, com recursos como:
- 📊 Listagem de criptomoedas com preços atualizados
- 🔍 Busca e filtro de ativos
- ❤️ Sistema de favoritos persistente
- 📱 Interface responsiva com ícones de criptomoedas
- 🌐 Atualização em tempo real via WebSocket
- 🌍 Suporte a múltiplos idiomas (i18n)

---

## 🏛️ Arquitetura MVVM

### Diagrama de Fluxo de Dados

```
┌─────────────────────────────────────────────────────────────┐
│                    VIEW LAYER (UI)                          │
│  (HomePage, SearchView, FavoritesView, AssetCard)           │
└────────────────────┬────────────────────────────────────────┘
                     │ Observa changes
                     ↓
┌─────────────────────────────────────────────────────────────┐
│              VIEWMODEL LAYER (Business Logic)               │
│  (AssetViewModel, MarketStreamViewModel)                    │
│  - Gerencia estado da UI                                    │
│  - Lógica de negócio                                        │
│  - Comunicação com Repository                              │
└────────────────────┬────────────────────────────────────────┘
                     │ Solicita dados
                     ↓
┌─────────────────────────────────────────────────────────────┐
│           REPOSITORY LAYER (Data Access)                    │
│  (AssetRepository)                                          │
│  - Abstrai a fonte de dados                                 │
│  - Gerencia requisições API                                 │
└────────────────────┬────────────────────────────────────────┘
                     │ Requisita dados
                     ↓
┌─────────────────────────────────────────────────────────────┐
│          MODEL LAYER (Data Structures)                      │
│  (Asset, AssetsResponse)                                    │
│  - Estruturas de dados                                      │
│  - Métodos de transformação                                 │
└────────────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura de Diretórios

```
lib/
├── main.dart                          # Ponto de entrada da app
│
├── core/                              # Utilidades e infraestrutura
│   ├── api/
│   │   └── api_client.dart           # Cliente HTTP genérico
│   │
│   ├── constants/
│   │   └── api_endpoints.dart        # URLs e constantes da API
│   │
│   ├── extensions/                   # Extensões globais
│   │   ├── string_extensions.dart    # Métodos para String (normalização, tradução)
│   │   ├── double_extensions.dart    # Métodos para Double (formatação)
│   │   └── widget_extensions.dart    # Métodos para Widget (padding, etc)
│   │
│   ├── storage/
│   │   └── favorites_storage.dart    # Persistência de favoritos (SharedPreferences)
│   │
│   ├── theme/
│   │   └── app_theme.dart            # Tema global da aplicação
│   │
│   └── websocket/
│       ├── binance_tickers_ws_client.dart   # WebSocket para Binance
│       └── coincap_prices_ws_client.dart    # WebSocket para CoinCap
│
├── i18n/                              # Internacionalização
│   └── pt_BR.json                    # Traduções em português
│
├── models/                            # Modelos de dados
│   ├── asset_model.dart              # Modelo de uma criptomoeda
│   ├── assets_response_model.dart    # Resposta da API
│   └── agg_trade_model.dart          # Dados de trades agregados
│
├── repositories/                      # Data access layer
│   └── asset_repository.dart         # Interface para dados de ativos
│
├── viewmodels/                        # Business logic layer
│   ├── asset_view_model.dart         # ViewModel para ativos
│   └── market_stream_view_model.dart # ViewModel para dados em tempo real
│
├── views/                             # Presentation layer (Screens)
│   ├── main_view.dart                # Container principal com navegação
│   ├── home_view.dart                # Tela inicial com top 100
│   ├── assets_search_view.dart       # Tela de busca de ativos
│   └── favorites_view.dart           # Tela de favoritos
│
└── widgets/                           # Componentes reutilizáveis
    ├── asset_card.dart               # Card para exibir um ativo
    └── stream_header.dart            # Header com dados de mercado
```

---

## 🧩 Componentes Principais

### 1️⃣ **Models (Camada de Dados)**

#### `Asset` (`lib/models/asset_model.dart`)
- Representa uma criptomoeda individual
- Propriedades: id, name, symbol, price, rank, etc.
- Métodos auxiliares:
  - `iconUrl`: Gera URL do ícone com mapeamento BTC→btc, ETH→eth, etc.
  - `priceUsdDouble`, `changePercent24HrDouble`: Converte strings em doubles
  - `isPositiveChange`: Verifica se a mudança é positiva

```dart
class Asset {
  final String? id;
  final String? name;
  final String? symbol;
  final String? priceUsd;
  
  String? get iconUrl {
    final mappedName = _iconNameMap[id];
    final iconName = mappedName ?? id!.normalizeForIconUrl();
    return 'https://assets.coincap.io/assets/icons/$iconName@2x.png';
  }
}
```

---

### 2️⃣ **Repository (Camada de Acesso a Dados)**

#### `AssetRepository` (`lib/repositories/asset_repository.dart`)
- Interface entre ViewModel e fonte de dados (API)
- Abstrai os detalhes de como os dados são obtidos
- Responsável por construir URLs, parâmetros, etc.

```dart
class AssetRepository {
  final ApiClient apiClient;
  
  Future<AssetsResponse> fetchAssets({
    String? search,
    List<String>? ids,
    int? limit,
    int? offset,
  }) async {
    // Constrói URL com parâmetros
    // Faz requisição
    // Transforma resposta em modelo
  }
}
```

---

### 3️⃣ **ViewModel (Camada de Lógica de Negócio)**

#### `AssetViewModel` (`lib/viewmodels/asset_view_model.dart`)
- Gerencia o estado de ativos
- Contém toda a lógica de negócio relacionada a criptomoedas
- Responsabilidades:
  - Carregar ativos da API via Repository
  - Buscar/filtrar ativos
  - Gerenciar lista de favoritos
  - Atualizar preços em tempo real via WebSocket
  - Notificar UI sobre mudanças

```dart
class AssetViewModel extends ChangeNotifier {
  List<Asset> _assets = const [];
  AssetStatus _status = AssetStatus.loading;
  Set<String> _favorites = {};
  
  // Métodos
  Future<void> loadAssets({String? search, int? limit}) async {
    _status = AssetStatus.loading;
    try {
      final response = await repository.fetchAssets(search: search);
      _assets = response.data ?? [];
      _status = AssetStatus.idle;
    } catch (e) {
      _status = AssetStatus.error;
      _error = e.toString();
    }
    notifyListeners(); // Notifica View sobre mudanças
  }
  
  void toggleFavorite(String? id) {
    if (id == null) return;
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    _favoritesStorage.saveFavorites(_favorites);
    notifyListeners();
  }
}
```

#### `MarketStreamViewModel` (`lib/viewmodels/market_stream_view_model.dart`)
- Gerencia dados em tempo real do mercado
- Conecta aos WebSockets do CoinCap e Binance
- Atualiza preços globais enquanto app está em execução

---

### 4️⃣ **Views (Camada de Apresentação)**

#### `MainView` (`lib/views/main_view.dart`)
- Container principal com BottomNavigationBar
- Oferece navegação entre: Home, Search, Favorites

#### `HomeView` (`lib/views/home_view.dart`)
- Exibe top 100 criptomoedas
- Mostra dados em tempo real
- Refresh indicator para atualizar manualmente

```dart
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssetViewModel>(); // Observa mudanças
    
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          return AssetCard(
            asset: vm.assets[index],
            price: '\$${vm.priceFor(...).formatPrice()}',
            // ... outros parâmetros
          );
        },
      ),
    );
  }
}
```

#### `AssetsSearchView` (`lib/views/assets_search_view.dart`)
- Permite buscar criptomoedas por nome ou símbolo
- TextField para input de busca
- Executa `vm.loadAssets(search: query)` ao submeter

#### `FavoritesView` (`lib/views/favorites_view.dart`)
- Exibe apenas ativos marcados como favoritos
- Permite remover de favoritos com swipe ou botão

---

### 5️⃣ **Widgets (Componentes Reutilizáveis)**

#### `AssetCard` (`lib/widgets/asset_card.dart`)
- Card que exibe informações de um ativo
- Componentes internos:
  - `_CryptoAvatar`: Avatar com ícone da criptomoeda
    - Valida URL do ícone via HTTP HEAD
    - Se válida: mostra imagem
    - Se inválida: mostra fallback com símbolo em texto
  - Preço, mudança percentual, rank
  - Botão de favorito

```dart
class AssetCard extends StatelessWidget {
  final Asset asset;
  final String price;
  final double percent;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: _CryptoAvatar(
          iconUrl: asset.iconUrl,
          leading: clippedSymbol,
          theme: theme,
        ),
        // ... resto do card
      ),
    );
  }
}
```

---

## 🔄 Fluxo de Dados: Exemplo Prático

### Usuário busca "Bitcoin":

1. **View**: Usuário digita "bitcoin" no TextField
2. **View**: Chama `vm.loadAssets(search: 'bitcoin')`
3. **ViewModel**: Atualiza `_status` para `loading`
4. **ViewModel**: Notifica listeners (View recebe notificação)
5. **View**: Exibe CircularProgressIndicator
6. **ViewModel**: Chama `repository.fetchAssets(search: 'bitcoin')`
7. **Repository**: Monta URL: `/assets?search=bitcoin`
8. **Repository**: Chama `apiClient.get(url)`
9. **ApiClient**: Faz requisição HTTP GET para CoinCap
10. **CoinCap**: Retorna JSON com resultados
11. **Repository**: Converte JSON para `AssetsResponse`
12. **ViewModel**: Atualiza `_assets` com resultados
13. **ViewModel**: Atualiza `_status` para `idle`
14. **ViewModel**: Chama `notifyListeners()`
15. **View**: Recebe notificação, reconstrói
16. **View**: Exibe lista de ativos em `ListView`

---

## 📦 Extensões Globais

### String Extensions (`lib/core/extensions/string_extensions.dart`)
```dart
extension StringExtensions on String {
  // Tradução
  String translate([List<String> args = const []]) => i18n(args);
  
  // Normaliza para URL de ícone (remove USDT, espaços, caracteres especiais)
  String normalizeForIconUrl() {
    return toLowerCase()
        .replaceAll('usdt', '')
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\w-]'), '')
        .replaceAll(RegExp(r'-+$'), '')
        .replaceAll(RegExp(r'^-+'), '');
  }
}
```

### Double Extensions (`lib/core/extensions/double_extensions.dart`)
```dart
extension DoubleExtensions on double {
  // Formata preço com casas decimais apropriadas
  String formatPrice() {
    if (this >= 1000) {
      return toStringAsFixed(2);
    } else if (this >= 1) {
      return toStringAsFixed(4);
    } else {
      return toStringAsFixed(6);
    }
  }
  
  // Formata volume (1.5B, 2.3M, etc)
  String formatVolume() { ... }
}
```

---

## 🔌 Integração com Provider

A app usa **Provider** para injeção de dependências e gerenciamento de estado:

```dart
void main() async {
  final apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);
  final assetRepository = AssetRepository(apiClient: apiClient);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AssetViewModel(repository: assetRepository)
                          ..loadAssets(limit: 100),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketStreamViewModel()..connectAndSubscribe(),
        ),
      ],
      child: MaterialApp(...),
    ),
  );
}
```

**Benefícios:**
- ✅ Injeção automática de dependências
- ✅ Acesso fácil via `context.watch<AssetViewModel>()`
- ✅ Notificação automática de mudanças
- ✅ Testabilidade melhorada

---

## 🎯 Padrões de Design Utilizados

### 1. **MVVM (Model-View-ViewModel)**
- Separação de responsabilidades
- ViewModel como intermediário entre View e dados

### 2. **Repository Pattern**
- Abstrai fonte de dados
- Facilita testes e mudanças de fonte de dados

### 3. **Dependency Injection**
- Via Provider
- Torna código testável e desacoplado

### 4. **Observer Pattern**
- ChangeNotifier notifica listeners
- View reconstrói automaticamente

### 5. **Extension Methods**
- Estende funcionalidades de tipos built-in
- Código mais legível e reutilizável

---

## 💾 Persistência

### Favorites Storage (`lib/core/storage/favorites_storage.dart`)
- Usa **SharedPreferences** para persistir lista de favoritos
- Carregado ao inicializar o app
- Salvo sempre que favorito é adicionado/removido

```dart
class FavoritesStorage {
  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites.toList());
  }
  
  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('favorites') ?? []).toSet();
  }
}
```

---

## 🌍 Internacionalização (i18n)

### Estrutura
```
lib/i18n/
└── pt_BR.json
```

### Uso
```dart
// Em qualquer Widget:
Text('no_assets_found'.translate())

// Em JSON:
{
  "no_assets_found": "Nenhum ativo encontrado",
  "search_hint": "Buscar criptomoeda...",
  ...
}
```

---

## 🔒 Segurança & Variáveis de Ambiente

### .env
```
COINCAP_API_KEY=seu_api_key_aqui
```

### Carregamento
```dart
await dotenv.load(fileName: '.env');
final apiKey = dotenv.env['COINCAP_API_KEY'];
```

### .gitignore
```
.env
.env.*
!.env.example
```

---

## 📊 Estado da App

### AssetStatus (enum)
```dart
enum AssetStatus {
  idle,     // Nenhuma operação em andamento
  loading,  // Carregando dados
  error     // Erro na operação
}
```

---

## 🚀 Fluxo de Desenvolvimento

### Adicionar nova feature:

1. **Model**: Criar modelo de dado (`lib/models/`)
2. **Repository**: Adicionar método para buscar dados (`lib/repositories/`)
3. **ViewModel**: Implementar lógica de negócio (`lib/viewmodels/`)
4. **View**: Criar UI para exibir dados (`lib/views/`)
5. **Widgets**: Extrair componentes reutilizáveis (`lib/widgets/`)

### Exemplo: Adicionar cache de ativos

```
1. Model: Asset + novo campo 'lastFetchedAt'
2. Repository: Adicionar método getAssetsCached() com lógica de TTL
3. ViewModel: Usar repository com cache
4. View: Mostrar indicador de "dados em cache"
```

---

## ✅ Vantagens da Arquitetura MVVM

| Aspecto | Benefício |
|---------|-----------|
| **Testabilidade** | ViewModel pode ser testado sem View |
| **Manutenibilidade** | Código organizado e bem separado |
| **Reusabilidade** | Widgets e extensions reutilizáveis |
| **Escalabilidade** | Fácil adicionar novas features |
| **Desacoplamento** | View não conhece Repository |
| **Performance** | Notificas apenas o necessário |

---

## 📝 Checklist para Novos Desenvolvedores

- [ ] Entender arquitetura MVVM
- [ ] Conhecer estrutura de diretórios
- [ ] Familiarizar com extensions globais
- [ ] Entender fluxo Provider
- [ ] Saber como adicionar novas features
- [ ] Conhecer padrões de design utilizados

---

## 🔗 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # HTTP
  http: ^1.1.0
  
  # Persistência
  shared_preferences: ^2.2.0
  
  # Dotenv
  flutter_dotenv: ^5.1.0
  
  # Localização
  localization: ^2.2.0
  
  # UI
  flutter_gap: ^2.0.0
```

---

**Última atualização**: 22 de Dezembro de 2025

**Status**: ✅ Documentação Completa

