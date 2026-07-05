## SIVE API

API do Sistema Integrado de Vagas Escolares (SIVE), desenvolvida em TypeScript com [Hono](https://hono.dev/), pensada para rodar como Cloudflare Worker.

### Requisitos

- Node.js 18 ou superior
- npm 9+ ou pnpm 9+
- Conta Cloudflare com Wrangler configurado (`npx wrangler login`)
- Banco de dados PostgreSQL acessível pelo Worker

### Instalacao

Clone o repositorio e acesse a pasta `api`:

```bash
git clone https://github.com/Sistema-Integrado-de-Vagas-Escolares/api.git
cd api
```

Instale as dependencias do projeto:

```bash
npm install
```

### Variaveis de ambiente

A API depende de variaveis/segredos configurados no Cloudflare Worker (veja `wrangler.jsonc` e `worker-configuration.d.ts`). As principais sao:

| Variavel | Descricao |
| --- | --- |
| `JWT_SECRET` | Segredo usado para assinar e validar os tokens de autenticacao dos administradores |
| Conexao com o Postgres | String/credenciais usadas pela camada de acesso a dados (`src/lib/db`) |

Para desenvolvimento local, crie um arquivo `.dev.vars` na raiz do projeto com esses valores, seguindo o formato aceito pelo Wrangler:

```bash
JWT_SECRET="sua-chave-secreta"
```

Apos alterar bindings ou variaveis, regenere os tipos com:

```bash
npm run cf-typegen
```

### Executar em desenvolvimento

Inicie o Worker localmente com:

```bash
npm run dev
```

O Wrangler vai disponibilizar a API em `http://localhost:8787` por padrao.

### Verificar tipos

Para validar a tipagem do projeto sem gerar build:

```bash
npm run typecheck
```

### Publicar na Cloudflare Workers

Para publicar a API:

```bash
npm run deploy
```

O comando executa `wrangler deploy --minify`, gerando um build otimizado antes do envio.

### Estrutura do projeto

O projeto segue uma organizacao inspirada no padrao MVC, adaptada para Workers com Hono:

```plaintext
src/
 ├── controllers/     # Recebem a requisicao, validam entrada e chamam os services
 ├── services/        # Regras de negocio e orquestracao entre repositories
 ├── repositories/     # Acesso a dados (queries ao Postgres)
 ├── models/          # Tipos e contratos de dados (records de banco, DTOs publicos)
 ├── routes/          # Definicao das rotas Hono e agrupamento por dominio
 ├── middlewares/      # Autenticacao, autorizacao e tratamento de erros
 ├── validators/       # Schemas Zod para validacao de payloads e parametros
 ├── lib/             # Integracoes de baixo nivel (jwt, banco de dados)
 ├── utils/           # Helpers (respostas padronizadas, erros de aplicacao, hashing)
 ├── types/           # Tipos globais (contexto do Hono, payloads de auth)
 └── index.ts         # Ponto de entrada do Worker

migrations/
 └── *.sql            # Scripts de migracao do banco de dados

wrangler.jsonc
worker-configuration.d.ts
```

### Fluxo de uma requisicao

1. **Route**: define o path/metodo HTTP e os middlewares aplicados (`src/routes`).
2. **Middleware**: valida autenticacao (`auth.middleware`) e autorizacao por papel (`authorization.middleware`) antes de chegar ao controller.
3. **Controller**: extrai parametros/payload, valida com Zod (`validators`) e delega para o service.
4. **Service**: aplica regras de negocio e converte entre o formato do banco e o formato publico da API.
5. **Repository**: executa as queries no Postgres e retorna os registros brutos.
6. Erros de negocio sao lancados como `AppError` e tratados de forma centralizada pelo `error.middleware`, garantindo respostas padronizadas.

### Autenticacao

A autenticacao de administradores e feita via JWT:

- `POST /admin/login` valida credenciais e retorna um token assinado com `jose`.
- O middleware `requireAdminAuth` exige o header `Authorization: Bearer <token>` nas rotas protegidas e injeta o admin autenticado no contexto.
- O middleware `requireRole` permite restringir rotas por papel (`admin` ou `super_admin`).

### Rotas disponiveis

| Metodo | Rota | Descricao | Protegida |
| --- | --- | --- | --- |
| POST | `/admin/login` | Autentica um administrador | Nao |
| GET | `/admin/city-halls` | Lista prefeituras cadastradas | Sim |
| GET | `/admin/city-halls/:id` | Detalha uma prefeitura | Sim |
| POST | `/admin/city-halls` | Cria uma nova prefeitura | Sim |
| PUT | `/admin/city-halls/:id` | Atualiza dados de uma prefeitura | Sim |
| PATCH | `/admin/city-halls/:id/password` | Atualiza a senha de acesso da prefeitura | Sim |
| DELETE | `/admin/city-halls/:id` | Remove uma prefeitura | Sim |
| GET | `/admin/settings` | Obtem as configuracoes globais do sistema | Sim |
| PUT | `/admin/settings` | Atualiza as configuracoes globais do sistema | Sim |

Todas as respostas seguem um formato padronizado (`ok`/`fail`, definidos em `utils/response`), incluindo mensagens de erro com lista de problemas de validacao quando aplicavel.

### Principais dependencias

- [`hono`](https://hono.dev/) — framework web leve, compativel com Cloudflare Workers
- [`jose`](https://github.com/panva/jose) — geracao e verificacao de JWT
- [`zod`](https://zod.dev/) — validacao de schemas de entrada
- [`bcryptjs`](https://github.com/dcodeIO/bcrypt.js) — hashing de senhas
- [`pg`](https://node-postgres.com/) — cliente PostgreSQL
- [`wrangler`](https://developers.cloudflare.com/workers/wrangler/) — CLI de desenvolvimento e deploy de Cloudflare Workers

### Roadmap - proximas implementacoes

Os modulos abaixo ainda nao estao implementados e representam os proximos passos da API:

#### Painel da Prefeitura

Rotas para a prefeitura gerenciar suas proprias escolas, vagas e usuarios, dentro do escopo da propria rede.

| Metodo | Rota (sugestao) | Descricao |
| --- | --- | --- |
| POST | `/city-hall/login` | Autentica uma prefeitura |
| GET | `/city-hall/schools` | Lista escolas da rede |
| POST | `/city-hall/schools` | Cadastra uma nova escola |
| GET | `/city-hall/schools/:id` | Detalha uma escola |
| PUT | `/city-hall/schools/:id` | Atualiza dados de uma escola |
| DELETE | `/city-hall/schools/:id` | Remove uma escola |
| GET | `/city-hall/vacancies` | Consolida vagas disponiveis por escola/serie |

#### Painel do Aluno

Rotas para consulta de matricula, status de vaga e historico escolar pelo proprio aluno.

| Metodo | Rota (sugestao) | Descricao |
| --- | --- | --- |
| POST | `/student/login` | Autentica um aluno |
| GET | `/student/me` | Dados do aluno autenticado |
| GET | `/student/enrollment` | Situacao da matricula atual |
| GET | `/student/enrollment/history` | Historico de matriculas/transferencias |

#### Painel do Responsavel

Rotas para o responsavel acompanhar e solicitar matriculas de um ou mais alunos vinculados.

| Metodo | Rota (sugestao) | Descricao |
| --- | --- | --- |
| POST | `/guardian/login` | Autentica um responsavel |
| GET | `/guardian/students` | Lista alunos vinculados ao responsavel |
| POST | `/guardian/enrollment-requests` | Solicita matricula/transferencia para um aluno |
| GET | `/guardian/enrollment-requests/:id` | Acompanha status de uma solicitacao |

#### Mapa de Vagas

Rotas publicas/autenticadas para exibir a distribuicao geografica de vagas disponiveis por escola, usadas pelo modulo "Mapa Inteligente".

| Metodo | Rota (sugestao) | Descricao |
| --- | --- | --- |
| GET | `/vacancy-map/schools` | Lista escolas com geolocalizacao e vagas disponiveis |
| GET | `/vacancy-map/schools/:id` | Detalha vagas disponiveis por serie/turno em uma escola |
| GET | `/vacancy-map/regions` | Agrega disponibilidade de vagas por regiao/bairro |

#### API de Eventos (Webhooks)

Pontos de entrada para eventos externos que devem atualizar o numero de vagas disponiveis em tempo real. Cada webhook recebe o evento, valida o payload e aciona o service responsavel por recalcular a ocupacao da escola/turma afetada.

| Metodo | Rota (sugestao) | Evento | Descricao |
| --- | --- | --- | --- |
| POST | `/events/enrollment-completed` | Matricula realizada | Decrementa a vaga disponivel na turma/serie da escola |
| POST | `/events/enrollment-cancelled` | Cancelamento de matricula | Devolve a vaga a turma/serie da escola |
| POST | `/events/student-dismissed` | Desligamento de aluno | Devolve a vaga e atualiza o status do aluno |
| POST | `/events/student-transferred` | Transferencia entre escolas | Devolve a vaga na escola de origem e decrementa na escola de destino |
| POST | `/events/capacity-changed` | Alteracao da capacidade de atendimento | Recalcula o total de vagas disponiveis da turma/serie a partir da nova capacidade |

Pontos em aberto para a implementacao dessa API:

- Definir mecanismo de autenticacao/assinatura dos webhooks (ex.: chave secreta compartilhada ou assinatura HMAC no header)
- Garantir idempotencia (o mesmo evento nao pode ser processado duas vezes)
- Registrar log/auditoria de cada evento recebido e do impacto no saldo de vagas
- Tratar eventos fora de ordem ou duplicados (ex.: cancelamento antes da confirmacao da matricula)

### Observacoes para a banca

A API pode ser executada localmente com `npm run dev`, desde que as variaveis de ambiente (`.dev.vars`) estejam configuradas com acesso a um banco Postgres.
O deploy esta preparado para Cloudflare Workers via Wrangler.
Para testar o frontend integrado, execute esta API em paralelo ao projeto `frontend`.