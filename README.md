# WikiCine — Projeto de Portfólio

Aplicativo mobile companion para filmes e séries, desenvolvido em Flutter, que permite explorar títulos, consultar avaliações dos usuários, visualizar informações detalhadas como elenco, direção e duração, além de conectar sua conta do TMDB para acessar recursos personalizados.

**Principais tecnologias e recursos:**
- **Flutter 3.50:** desenvolvimento da aplicação mobile.
- **API REST (TMDB):** integração para consulta de filmes, séries e informações relacionadas.
- **Clean Architecture:** organização em camadas e separação de responsabilidades.
- **BLoC/Cubit:** gerenciamento de estado e controle do fluxo de dados.
- **Integração com TMDB:** conexão com uma conta pessoal da plataforma para acesso aos recursos de usuário.

**Documentação da API:** https://developer.themoviedb.org/docs/getting-started

**Download do aplicativo:** https://drive.google.com/drive/folders/1CRf-UBNs1AkY9r8Sc2G995rQ3hDWscL7?usp=drive_link

<img width="407" height="859" alt="download" src="https://github.com/user-attachments/assets/eadfcb5a-851b-4886-8d5e-9ed92224b3c0" />

<img width="425" height="888" alt="download" src="https://github.com/user-attachments/assets/cb4f6ead-cbd1-4cd3-9569-7142f5a23e03" />

<img width="439" height="870" alt="download" src="https://github.com/user-attachments/assets/246a2e33-ad98-4e7a-b1c7-36c5bba68de3" />

<img width="444" height="872" alt="{F6A6031E-4B96-4BE0-97C9-ACA341B1B6B9}" src="https://github.com/user-attachments/assets/df77b806-f037-4753-97ec-844e4a7e6528" />

## CI/CD

| Workflow | Quando roda | O que faz |
|---|---|---|
| [`ci.yml`](.github/workflows/ci.yml) | Todo pull request e push na `master` | Verifica formatação (`dart format`), `flutter analyze`, `flutter test --coverage` e gera um APK de release (artefato do workflow, guardado por 7 dias). |
| [`release.yml`](.github/workflows/release.yml) | Push de tag `v*.*.*` | Roda análise e testes, gera APK + AAB assinados e publica uma **GitHub Release** com os arquivos. Tags com hífen (`v1.2.0-beta.1`) viram pré-release. |

**Publicar uma versão:**
```bash
git tag v1.1.0 && git push origin v1.1.0
```
O `versionName` vem da tag e o `versionCode` do número da execução do workflow.

**Secrets do repositório** (*Settings → Secrets and variables → Actions*):

| Secret | Obrigatório | Uso |
|---|---|---|
| `TMDB_TOKEN` | Sim (release) | Token de leitura da API do TMDB (`--dart-define=TOKEN`). |
| `TMDB_API_KEY` | Sim (release) | Chave da API do TMDB (`--dart-define=API_KEY`). |
| `ANDROID_KEYSTORE_BASE64` | Recomendado | Keystore de upload em base64 (`base64 -w0 upload-keystore.jks`). Sem ele, a release é assinada com a chave de debug. |
| `ANDROID_KEYSTORE_PASSWORD` | Com o keystore | Senha do keystore. |
| `ANDROID_KEY_ALIAS` | Com o keystore | Alias da chave. |
| `ANDROID_KEY_PASSWORD` | Com o keystore | Senha da chave. |

Localmente, a assinatura de release usa `android/key.properties` (ignorado pelo Git) quando ele existe.
