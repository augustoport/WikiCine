> ⚠️ **Documento desatualizado.** Este arquivo descreve um estado anterior do projeto e contém nomes de arquivos e afirmações que não correspondem mais ao código.
> A documentação oficial e atual está em [`docs/ARQUITETURA_DO_SISTEMA.md`](docs/ARQUITETURA_DO_SISTEMA.md) e [`docs/OBJETIVO_DO_SISTEMA.md`](docs/OBJETIVO_DO_SISTEMA.md), com READMEs locais em cada pasta de `lib/`.

# Clean Architecture - CineRating

## Estrutura de Diretórios

```
lib/
├── domain/                    # Camada de Domínio (Regras de Negócio)
│   ├── entities/             # Entidades do domínio
│   │   ├── user.dart
│   │   ├── movie.dart
│   │   └── tv_show.dart
│   ├── repositories/         # Interfaces de repositórios (abstratas)
│   │   ├── auth_repository.dart
│   │   ├── movie_repository.dart
│   │   └── tv_repository.dart
│   └── usecases/             # Casos de uso (lógica de negócio)
│       ├── login_usecase.dart
│       ├── get_current_user_usecase.dart
│       ├── logout_usecase.dart
│       ├── get_movies_usecase.dart
│       ├── search_movies_usecase.dart
│       ├── get_tv_shows_usecase.dart
│       └── search_tv_shows_usecase.dart
│
├── data/                     # Camada de Dados (Implementação)
│   ├── datasources/          # Fontes de dados (API, Local)
│   │   ├── auth_remote_datasource.dart
│   │   ├── auth_remote_datasource_impl.dart
│   │   ├── movie_remote_datasource.dart
│   │   ├── movie_remote_datasource_impl.dart
│   │   ├── tv_remote_datasource.dart
│   │   └── tv_remote_datasource_impl.dart
│   ├── models/               # Models DTOs (Data Transfer Objects)
│   │   ├── crew_model.dart
│   │   ├── movie_detail_model.dart
│   │   ├── movie_simple_model.dart
│   │   ├── tv_crew_model.dart
│   │   ├── tv_show_model.dart
│   │   └── user_model.dart
│   └── repositories/         # Implementações de repositórios
│       ├── auth_repository_impl.dart
│       ├── movie_repository_impl.dart
│       └── tv_repository_impl.dart
│
├── presentation/             # Camada de Apresentação (UI)
│   ├── bloc/                # Blocs/Cubits
│   │   ├── home/
│   │   ├── movie_detail/
│   │   └── serie_detail/
│   ├── controllers/         # Controllers
│   │   └── login_controller.dart
│   ├── pages/               # Páginas
│   │   ├── login_page.dart
│   │   ├── home_page.dart
│   │   ├── movie_detail_page.dart
│   │   ├── tv_show_detail_page.dart
│   │   └── profile_page.dart
│   └── widgets/             # Widgets reutilizáveis
│       ├── content_list.dart
│       ├── content_detail.dart
│       ├── cast_card.dart
│       ├── movie_card.dart
│       ├── navigation_blur.dart
│       ├── session_card.dart
│       └── text_field_custom.dart
│
├── core/                     # Configurações e utilitários globais
│   ├── locator.dart         # Service Locator (Get It)
│   └── services/            # Serviços legados (usados por cubits de detalhes)
│       ├── auth_service.dart
│       ├── movie_service.dart
│       └── tv_service.dart
│
├── shared/                   # Recursos compartilhados
│   ├── themes/              # Temas
│   └── env.dart             # Variáveis de ambiente
│
└── main.dart                # Ponto de entrada
```

## Fluxo de Dados

```
Presentation (UI)
    ↓ (chama)
Use Cases
    ↓ (chama)
Repositories (Interfaces)
    ↓ (implementado por)
Repository Implementations
    ↓ (usa)
DataSources
    ↓ (retorna)
Models (DTOs)
    ↓ (converte para)
Entities
```

## Exemplo de Fluxo: Login

1. **Presentation**: `LoginController` chama `LoginUseCase`
2. **Domain**: `LoginUseCase` chama `AuthRepository` (interface)
3. **Data**: `AuthRepositoryImpl` implementa `AuthRepository`
4. **Data**: `AuthRepositoryImpl` usa `AuthRemoteDataSource`
5. **Data**: `AuthRemoteDataSourceImpl` faz requisição HTTP
6. **Data**: Retorna `User` (Entity direto do datasource)
7. **Domain**: `LoginUseCase` retorna `User` (Entity)
8. **Presentation**: `LoginController` recebe `User` e atualiza UI

## Benefícios

### 1. Separação de Responsabilidades
- Cada camada tem uma responsabilidade específica
- Domain não depende de frameworks (Flutter, Dio, etc.)
- Data lida apenas com fontes de dados
- Presentation lida apenas com UI

### 2. Testabilidade
- **Domain**: Testes unitários sem dependências externas
- **Data**: Testes com mocks de datasources
- **Presentation**: Testes com mocks de use cases

### 3. Manutenibilidade
- Mudanças na API afetam apenas Data layer
- Mudanças na UI afetam apenas Presentation layer
- Regras de negócio ficam isoladas no Domain

### 4. Escalabilidade
- Fácil adicionar novas features
- Fácil trocar implementações (ex: mudar de Dio para outra lib HTTP)
- Fácil adicionar caching, logging, etc.

## Status da Migração

### ✅ Concluído
- [x] Estrutura de diretórios Clean Architecture
- [x] Entidades em `domain/entities/`
- [x] Repositories (interfaces) em `domain/repositories/`
- [x] Use Cases em `domain/usecases/`
- [x] DataSources em `data/datasources/`
- [x] Models em `data/models/`
- [x] Repository Implementations em `data/repositories/`
- [x] Views movidas para `presentation/pages/`
- [x] Widgets movidos para `presentation/widgets/`
- [x] Controllers movidos para `presentation/controllers/`
- [x] Blocs/Cubits movidos para `presentation/bloc/`
- [x] Use cases completos (Login, GetCurrentUser, Logout, GetMovies, SearchMovies, GetTvShows, SearchTvShows)
- [x] Locator configurado com todas as dependências
- [x] LoginController usando Clean Architecture
- [x] HomeCubit usando Clean Architecture

### ⚠️ Parcialmente Migrado
- [~] Cubits de detalhes (movie_detail, serie_detail) ainda usam serviços legados
  - Motivo: Necessitam de funcionalidades específicas não implementadas nos novos use cases
  - Solução futura: Criar use cases específicos para detalhes

### 📝 Próximos Passos (Opcionais)
1. Criar use cases para detalhes de filmes e séries
2. Migrar cubits de detalhes para usar novos use cases
3. Remover serviços legados completamente
4. Adicionar repository local (SQLite/SharedPreferences)
5. Adicionar testes unitários para cada camada

## Legado vs Clean Architecture

### Legado (Antes)
```
Views → Controllers → Services → API
```

### Clean Architecture (Agora)
```
Pages → Controllers → Use Cases → Repositories → DataSources → API
```

## Como Adicionar Nova Feature

1. **Domain**: Criar Entity em `domain/entities/`
2. **Domain**: Criar Repository interface em `domain/repositories/`
3. **Domain**: Criar Use Case em `domain/usecases/`
4. **Data**: Criar DataSource em `data/datasources/`
5. **Data**: Criar Repository implementation em `data/repositories/`
6. **Data**: Criar Model em `data/models/` (se necessário)
7. **Presentation**: Criar Controller/Bloc em `presentation/`
8. **Presentation**: Criar Page em `presentation/pages/`
9. **Core**: Registrar tudo no `locator.dart`

## Service Locator (Get It)

### Datasources (LazySingleton)
- Criados na primeira solicitação
- Única instância compartilhada
- Usados por repositories

### Repositories (LazySingleton)
- Criados na primeira solicitação
- Única instância compartilhada
- Implementam interfaces do domain

### Use Cases (Factory)
- Nova instância a cada solicitação
- Usam repositories
- Usados por controllers/blocs

### Controllers (Factory)
- Nova instância a cada solicitação
- Usam use cases
- Gerenciam estado de UI

### Cubits (Factory)
- Nova instância a cada solicitação
- Usam use cases ou serviços legados
- Gerenciam estado de blocs

### Serviços Legados (LazySingleton)
- Criados na primeira solicitação
- Única instância compartilhada
- Usados temporariamente por cubits de detalhes
