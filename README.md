## SIVE API

API do Sistema Integrado de Vagas Escolares (SIVE), desenvolvida em TypeScript com [Hono](https://hono.dev/), pensada para rodar como Cloudflare Worker.

### Requisitos

- Node.js 18 ou superior
- npm 9+ ou pnpm 9+
- Conta Cloudflare com Wrangler configurado (`npx wrangler login`)
- Banco de dados PostgreSQL acessível pelo Worker

### Instalação

Clone o repositório e acesse a pasta `api`:

```bash
git clone https://github.com/Sistema-Integrado-de-Vagas-Escolares/api.git
cd api
```

Instale as dependências do projeto:

```bash
npm install
```

### Variáveis de ambiente

A API depende de variáveis/segredos configurados no Cloudflare Worker (veja `wrangler.jsonc` e `worker-configuration.d.ts`). As principais são:

| Variável | Descrição |
| --- | --- |
| `JWT_SECRET` | Segredo usado para assinar e validar os tokens de autenticação dos administradores |
| Conexão com o Postgres | String/credenciais usadas pela camada de acesso a dados (`src/lib/db`) |

Para desenvolvimento local, crie um arquivo `.dev.vars` na raiz do projeto com esses valores, seguindo o formato aceito pelo Wrangler:

```bash
JWT_SECRET="sua-chave-secreta"
```

### Executar em desenvolvimento

Inicie o Worker localmente com:

```bash
npm run dev
```

O Wrangler vai disponibilizar a API em `http://localhost:8787` por padrão.

### Estrutura do projeto

O projeto segue uma organização inspirada no padrão MVC, adaptada para Workers com Hono:

```plaintext
src/
 ├── controllers/     # Recebem a requisição, validam entrada e chamam os services
 ├── services/        # Regras de negócio e orquestração entre repositories
 ├── repositories/     # Acesso a dados (queries ao Postgres)
 ├── models/          # Tipos e contratos de dados (records de banco, DTOs públicos)
 ├── routes/          # Definição das rotas Hono e agrupamento por domínio
 ├── middlewares/      # Autenticação, autorização e tratamento de erros
 ├── validators/       # Schemas Zod para validação de payloads e parâmetros
 ├── lib/             # Integrações de baixo nível (jwt, banco de dados)
 ├── utils/           # Helpers (respostas padronizadas, erros de aplicação, hashing)
 ├── types/           # Tipos globais (contexto do Hono, payloads de auth)
 └── index.ts         # Ponto de entrada do Worker

migrations/
 └── *.sql            # Scripts de migração do banco de dados

wrangler.jsonc
worker-configuration.d.ts
```

### Fluxo de uma requisicao

1. **Route**: define o path/método HTTP e os middlewares aplicados (`src/routes`).
2. **Middleware**: valida autenticação (`auth.middleware`) e autorizacão por papel (`authorization.middleware`) antes de chegar ao controller.
3. **Controller**: extrai parâmetros/payload, valida com Zod (`validators`) e delega para o service.
4. **Service**: aplica regras de negócio e converte entre o formato do banco e o formato publico da API.
5. **Repository**: executa as queries no Postgres e retorna os registros brutos.
6. Erros de negócio são lançados como `AppError` e tratados de forma centralizada pelo `error.middleware`, garantindo respostas padronizadas.

### Autenticação

A autenticação de administradores e feita via JWT:

- `POST /admin/login` valida credenciais e retorna um token assinado com `jose`.
- O middleware `requireAdminAuth` exige o header `Authorization: Bearer <token>` nas rotas protegidas e injeta o admin autenticado no contexto.
- O middleware `requireRole` permite restringir rotas por papel (`admin` ou `super_admin`).

### Rotas disponíveis

| Método | Rota | Descrição | Protegida |
| --- | --- | --- | --- |
| POST | `/admin/login` | Autentica um administrador | Não |
| GET | `/admin/city-halls` | Lista prefeituras cadastradas | Sim |
| GET | `/admin/city-halls/:id` | Detalha uma prefeitura | Sim |
| POST | `/admin/city-halls` | Cria uma nova prefeitura | Sim |
| PUT | `/admin/city-halls/:id` | Atualiza dados de uma prefeitura | Sim |
| PATCH | `/admin/city-halls/:id/password` | Atualiza a senha de acesso da prefeitura | Sim |
| DELETE | `/admin/city-halls/:id` | Remove uma prefeitura | Sim |
| GET | `/admin/settings` | Obtém as configurações globais do sistema | Sim |
| PUT | `/admin/settings` | Atualiza as configurações globais do sistema | Sim |

Todas as respostas seguem um formato padronizado (`ok`/`fail`, definidos em `utils/response`), incluindo mensagens de erro com lista de problemas de validação quando aplicável.

### Principais dependências

- [`hono`](https://hono.dev/) — framework web leve, compatível com Cloudflare Workers
- [`jose`](https://github.com/panva/jose) — geração e verificação de JWT
- [`zod`](https://zod.dev/) — validação de schemas de entrada
- [`bcryptjs`](https://github.com/dcodeIO/bcrypt.js) — hashing de senhas
- [`pg`](https://node-postgres.com/) — cliente PostgreSQL
- [`wrangler`](https://developers.cloudflare.com/workers/wrangler/) — CLI de desenvolvimento e deploy de Cloudflare Workers

### Roadmap - próximas implementações

Os módulos abaixo ainda não estão implementados e representam os proximos passos da API:

#### Painel da Prefeitura

Rotas para a prefeitura gerenciar suas próprias escolas, vagas e usuários, dentro do escopo da própria rede.

| Método | Rota (sugestao) | Descrição |
| --- | --- | --- |
| POST | `/city-hall/login` | Autentica uma prefeitura |
| GET | `/city-hall/schools` | Lista escolas da rede |
| POST | `/city-hall/schools` | Cadastra uma nova escola |
| GET | `/city-hall/schools/:id` | Detalha uma escola |
| PUT | `/city-hall/schools/:id` | Atualiza dados de uma escola |
| DELETE | `/city-hall/schools/:id` | Remove uma escola |
| GET | `/city-hall/vacancies` | Consolida vagas disponíveis por escola/série |

#### Painel do Aluno

Rotas para consulta de matrícula, status de vaga e histórico escolar pelo próprio aluno.

| Método | Rota (sugestão) | Descrição |
| --- | --- | --- |
| POST | `/student/login` | Autentica um aluno |
| GET | `/student/me` | Dados do aluno autenticado |
| GET | `/student/enrollment` | Situação da matrícula atual |
| GET | `/student/enrollment/history` | Histórico de matrículas/transferências |

#### Painel do Responsável

Rotas para o responsável acompanhar e solicitar matrículas de um ou mais alunos vinculados.

| Método | Rota (sugestão) | Descrição |
| --- | --- | --- |
| POST | `/guardian/login` | Autentica um responsável |
| GET | `/guardian/students` | Lista alunos vinculados ao responsável |
| POST | `/guardian/enrollment-requests` | Solicita matrícula/transferência para um aluno |
| GET | `/guardian/enrollment-requests/:id` | Acompanha status de uma solicitação |

#### Mapa de Vagas

Rotas publicas/autenticadas para exibir a distribuição geografica de vagas disponíveis por escola, usadas pelo módulo "Mapa Inteligente".

| Método | Rota (sugestão) | Descrição |
| --- | --- | --- |
| GET | `/vacancy-map/schools` | Lista escolas com geolocalização e vagas disponíveis |
| GET | `/vacancy-map/schools/:id` | Detalha vagas disponíveis por série/turno em uma escola |
| GET | `/vacancy-map/regions` | Agrega disponibilidade de vagas por região/bairro |

#### API de Eventos (Webhooks)

Pontos de entrada para eventos externos que devem atualizar o numero de vagas disponíveis em tempo real. Cada webhook recebe o evento, valida o payload e aciona o service responsável por recalcular a ocupação da escola/turma afetada.

| Método | Rota (sugestão) | Evento | Descrição |
| --- | --- | --- | --- |
| POST | `/events/enrollment-completed` | Matrícula realizada | Decrementa a vaga disponível na turma/serie da escola |
| POST | `/events/enrollment-cancelled` | Cancelamento de matrícula | Devolve a vaga a turma/série da escola |
| POST | `/events/student-dismissed` | Desligamento de aluno | Devolve a vaga e atualiza o status do aluno |
| POST | `/events/student-transferred` | Transferência entre escolas | Devolve a vaga na escola de origem e decrementa na escola de destino |
| POST | `/events/capacity-changed` | Alteração da capacidade de atendimento | Recalcula o total de vagas disponíveis da turma/série a partir da nova capacidade |