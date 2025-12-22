# Desafio GRP — MVVM com Integração de API

Projeto Flutter básico estruturado em MVVM, com integração a uma API pública (JSONPlaceholder) para listar posts.

## Arquitetura
- **Model**: Representa dados (`lib/models/post.dart`).
- **Repository**: Camada de acesso a dados (`lib/repositories/post_repository.dart`).
- **ViewModel**: Lógica de apresentação com estado reativo (`lib/viewmodels/post_view_model.dart`).
- **View**: Widgets/UI (`lib/views/post_list_view.dart`).
- **Core/API**: Cliente HTTP (`lib/core/api/api_client.dart`).

## Dependências
- `http`: requisições HTTP.
- `provider`: injeção e gerenciamento de estado via `ChangeNotifier`.

## Como rodar
1. Instale dependências:
	```bash
	flutter pub get
	```
2. Rode o app:
	```bash
	flutter run
	```

## Fluxo de dados
`PostListView` observa `PostViewModel`. Ao abrir o app, a ViewModel chama `loadPosts()`, que usa o `PostRepository` e `ApiClient` para buscar `GET /posts` em `https://jsonplaceholder.typicode.com`. O estado (carregando/erro/dados) é notificado para a View.

## Personalização
- Troque o `baseUrl` em `lib/main.dart` para sua API.
- Adicione novos Models/Repositories/ViewModels/Vistas conforme necessário.
