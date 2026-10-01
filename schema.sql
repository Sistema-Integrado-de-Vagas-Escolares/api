-- ============================================================================
-- SIVE (Sistema Integrado de Vagas Escolares)
-- Script DDL de Referência para Banco de Dados Relacional (PostgreSQL 14+)
-- Versão: 2.2 (Multi-tenant Desacoplado · 100% Relacional · Status Apenas com Code em Inglês)
-- ============================================================================

-- Extensões úteis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. TABELAS DE DOMÍNIO E CATÁLOGOS (APENAS ID E CODE EM INGLÊS)
-- As informações de exibição, cores e labels são gerenciadas pelo front-end.
-- ============================================================================

-- Tipos de Organização
CREATE TABLE IF NOT EXISTS organization_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE organization_types IS 'Tipos de organizações atendidas pelo SIVE';
COMMENT ON COLUMN organization_types.code IS 'Código do tipo em inglês: city_hall (Prefeitura), private_network (Rede Privada), ngo (ONG/Filantrópica), cooperative (Cooperativa)';

-- Status de Organizações
CREATE TABLE IF NOT EXISTS organization_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE organization_statuses IS 'Status da organização no SIVE';
COMMENT ON COLUMN organization_statuses.code IS 'Código do status em inglês: active (Ativo), inactive (Inativo), pending (Aguardando ativação), suspended (Suspenso)';

-- Status de Usuários
CREATE TABLE IF NOT EXISTS user_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE user_statuses IS 'Status de contas de usuários operadores';
COMMENT ON COLUMN user_statuses.code IS 'Código do status em inglês: active (Ativo), inactive (Inativo), blocked (Bloqueado), pending (Pendente de ativação)';

-- Papéis de Acesso e Permissões (RBAC)
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE roles IS 'Papéis de acesso no sistema';
COMMENT ON COLUMN roles.code IS 'Código do papel em inglês: sive_super_admin, sive_admin, org_admin, org_operator, school_admin, school_staff';

-- Status de Escolas
CREATE TABLE IF NOT EXISTS school_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE school_statuses IS 'Status operacional de unidades escolares';
COMMENT ON COLUMN school_statuses.code IS 'Código do status em inglês: active (Em operação), inactive (Desativada), under_renovation (Em reforma/obras)';

-- Etapas de Ensino / Modalidades
CREATE TABLE IF NOT EXISTS educational_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE educational_stages IS 'Etapas e modalidades de ensino';
COMMENT ON COLUMN educational_stages.code IS 'Código da etapa em inglês: daycare (Creche), preschool (Educação Infantil/Pré-escola), elementary_early (Fundamental I), elementary_final (Fundamental II), high_school (Ensino Médio)';

-- Turnos Escolares
CREATE TABLE IF NOT EXISTS shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE shifts IS 'Turnos de funcionamento das turmas';
COMMENT ON COLUMN shifts.code IS 'Código do turno em inglês: full_time (Integral), morning (Manhã), afternoon (Tarde), night (Noite)';

-- Status das Turmas/Ofertas de Vagas
CREATE TABLE IF NOT EXISTS class_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE class_statuses IS 'Status de ofertas de vagas e turmas';
COMMENT ON COLUMN class_statuses.code IS 'Código do status em inglês: open (Aberta/Em atendimento), closed (Encerrada), planned (Planejada/Ano seguinte)';

-- Tipos de Parentesco / Vínculo Familiar
CREATE TABLE IF NOT EXISTS kinship_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE kinship_types IS 'Graus de parentesco do responsável';
COMMENT ON COLUMN kinship_types.code IS 'Código do parentesco em inglês: mother (Mãe), father (Pai), legal_guardian (Responsável legal/Guarda), grandparent (Avô/Avó), other (Outro)';

-- Tipos de Cálculo dos Critérios da Fila
CREATE TABLE IF NOT EXISTS criteria_calculation_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE criteria_calculation_types IS 'Tipos de cálculo para pontuação dos critérios';
COMMENT ON COLUMN criteria_calculation_types.code IS 'Código do cálculo em inglês: weighted_percentage (Ponderação percentual/pesos), points_sum (Soma direta de pontos inteiros)';

-- Tipos de Valores Avaliados pelos Critérios
CREATE TABLE IF NOT EXISTS criteria_value_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE criteria_value_types IS 'Tipos de dados avaliados pelos critérios de fila';
COMMENT ON COLUMN criteria_value_types.code IS 'Código do tipo de valor em inglês: boolean (Sim/Não), range (Faixas de valores/renda), distance (Distância geodésica)';

-- Status de Comprovação Documental de Critérios
CREATE TABLE IF NOT EXISTS criteria_verification_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE criteria_verification_statuses IS 'Status de validação dos documentos comprobatórios dos critérios';
COMMENT ON COLUMN criteria_verification_statuses.code IS 'Código do status em inglês: pending (Pendente de análise), verified (Documento comprovado), rejected (Documento rejeitado), waived (Dispensado)';

-- Status da Solicitação na Fila de Espera (Incluindo fase do chamado)
CREATE TABLE IF NOT EXISTS application_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE application_statuses IS 'Status do ciclo de vida da solicitação de vaga na fila de espera';
COMMENT ON COLUMN application_statuses.code IS 'Código do status em inglês: waiting (Em espera na fila), called (Chamado/Convocado para vaga), enrolled (Matriculado com sucesso), rejected (Vaga recusada), withdrawn (Desistente formal), expired (Prazo expirado/Não compareceu), cancelled (Cancelado administrativamente)';

-- Tipos de Eventos da Fila de Espera (Linha do Tempo)
CREATE TABLE IF NOT EXISTS queue_event_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE queue_event_types IS 'Tipos de eventos registrados no histórico de movimentações da fila';
COMMENT ON COLUMN queue_event_types.code IS 'Código do evento em inglês: application_created (Inscrição inicial), score_recalculated (Recálculo de posição), student_called (Convocação do aluno), seat_accepted (Aceite da vaga), seat_rejected (Recusa da vaga), queue_withdrawn (Desistência da fila), seat_passed_forward (Vaga repassada por prazo), returned_to_queue (Retornado à fila)';

-- Status de Matrículas Efetivadas
CREATE TABLE IF NOT EXISTS enrollment_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE enrollment_statuses IS 'Status de matrículas oficiais';
COMMENT ON COLUMN enrollment_statuses.code IS 'Código do status em inglês: active (Matrícula ativa), completed (Concluída), transferred (Transferido), cancelled (Cancelada), dropped_out (Evasão/Desligado)';

-- Canais de Disparo de Notificações
CREATE TABLE IF NOT EXISTS notification_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE notification_channels IS 'Canais de disparo de notificações aos responsáveis';
COMMENT ON COLUMN notification_channels.code IS 'Código do canal em inglês: app (Portal/App SIVE), email (E-mail), sms (SMS), whatsapp (WhatsApp)';

-- Tipos de Notificações
CREATE TABLE IF NOT EXISTS notification_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE notification_types IS 'Tipos de eventos disparados para os pais';
COMMENT ON COLUMN notification_types.code IS 'Código do tipo em inglês: position_changed (Mudança de posição), seat_called (Convocado para vaga aberta), deadline_alert (Lembrete de término de prazo), enrollment_confirmed (Matrícula confirmada)';

-- Status de Entrega de Notificações
CREATE TABLE IF NOT EXISTS notification_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE notification_statuses IS 'Situação do disparo da notificação';
COMMENT ON COLUMN notification_statuses.code IS 'Código do status em inglês: pending (Pendente de envio), sent (Enviado com sucesso), failed (Falha no disparo), read (Visualizado pelo responsável)';

-- ============================================================================
-- 2. CARGA INICIAL DE DADOS DE DOMÍNIO (SEEDS COM CÓDIGOS EM INGLÊS)
-- ============================================================================

INSERT INTO organization_types (code) VALUES
    ('city_hall'),       -- Prefeitura / Secretaria Municipal de Educação
    ('private_network'), -- Rede Privada de Ensino (Anglo, Objetivo, etc.)
    ('ngo'),             -- Instituição Filantrópica / Creche Comunitária
    ('cooperative')      -- Cooperativa Educacional
ON CONFLICT (code) DO NOTHING;

INSERT INTO organization_statuses (code) VALUES
    ('active'),    -- Ativo
    ('inactive'),  -- Inativo
    ('pending'),   -- Aguardando ativação
    ('suspended')  -- Suspenso
ON CONFLICT (code) DO NOTHING;

INSERT INTO user_statuses (code) VALUES
    ('active'),   -- Ativo
    ('inactive'), -- Inativo
    ('blocked'),  -- Bloqueado
    ('pending')   -- Pendente de ativação
ON CONFLICT (code) DO NOTHING;

INSERT INTO roles (code) VALUES
    ('sive_super_admin'), -- Superadministrador global da plataforma SIVE
    ('sive_admin'),       -- Administrador/suporte SIVE
    ('org_admin'),        -- Administrador da organização (Secretário de Educação/Diretor Geral da Rede)
    ('org_operator'),     -- Operador da organização (Equipe da Central de Vagas)
    ('school_admin'),     -- Diretor de unidade escolar
    ('school_staff')      -- Secretário escolar
ON CONFLICT (code) DO NOTHING;

INSERT INTO school_statuses (code) VALUES
    ('active'),           -- Em operação regular
    ('inactive'),         -- Desativada
    ('under_renovation')  -- Em reforma ou obras
ON CONFLICT (code) DO NOTHING;

INSERT INTO educational_stages (code) VALUES
    ('daycare'),           -- Creche (0 a 3 anos: Berçário e Maternal)
    ('preschool'),         -- Pré-escola / Educação Infantil (4 e 5 anos)
    ('elementary_early'),  -- Ensino Fundamental I (1º ao 5º ano)
    ('elementary_final'),  -- Ensino Fundamental II (6º ao 9º ano)
    ('high_school')        -- Ensino Médio
ON CONFLICT (code) DO NOTHING;

INSERT INTO shifts (code) VALUES
    ('full_time'), -- Integral
    ('morning'),   -- Manhã
    ('afternoon'), -- Tarde
    ('night')      -- Noite
ON CONFLICT (code) DO NOTHING;

INSERT INTO class_statuses (code) VALUES
    ('open'),    -- Aberta / Em atendimento
    ('closed'),  -- Encerrada
    ('planned')  -- Planejada / Próximo ano letivo
ON CONFLICT (code) DO NOTHING;

INSERT INTO kinship_types (code) VALUES
    ('mother'),         -- Mãe
    ('father'),         -- Pai
    ('legal_guardian'), -- Responsável legal com guarda judicial
    ('grandparent'),    -- Avô ou Avó
    ('other')           -- Outro grau de parentesco
ON CONFLICT (code) DO NOTHING;

INSERT INTO criteria_calculation_types (code) VALUES
    ('weighted_percentage'), -- Ponderação percentual (pesos somando 100%)
    ('points_sum')           -- Soma direta de pontos inteiros
ON CONFLICT (code) DO NOTHING;

INSERT INTO criteria_value_types (code) VALUES
    ('boolean'),  -- Sim ou Não (Booleano)
    ('range'),    -- Faixa numérica (Escala de renda)
    ('distance')  -- Distância geodésica (Metros até a escola)
ON CONFLICT (code) DO NOTHING;

INSERT INTO criteria_verification_statuses (code) VALUES
    ('pending'),  -- Comprovação documental pendente
    ('verified'), -- Documento comprovado e aprovado
    ('rejected'), -- Documento rejeitado
    ('waived')    -- Dispensado de comprovação
ON CONFLICT (code) DO NOTHING;

INSERT INTO application_statuses (code) VALUES
    ('waiting'),   -- Em Espera: Aguardando abertura de vaga e convocação
    ('called'),    -- Chamado: Convocado para apresentar documentos e confirmar vaga
    ('enrolled'),  -- Matriculado: Matrícula formalizada na escola
    ('rejected'),  -- Vaga Recusada: Responsável recusou expressamente a vaga
    ('withdrawn'), -- Desistente: Responsável solicitou cancelamento formal da inscrição
    ('expired'),   -- Prazo Expirado: Não compareceu no prazo limite estabelecido
    ('cancelled')  -- Cancelado: Inscrição cancelada administrativamente
ON CONFLICT (code) DO NOTHING;

INSERT INTO queue_event_types (code) VALUES
    ('application_created'),  -- Inscrição inicial realizada
    ('score_recalculated'),   -- Recálculo de posição na fila
    ('student_called'),       -- Convocação do aluno para ocupar vaga aberta
    ('seat_accepted'),        -- Aceite da vaga pelo responsável
    ('seat_rejected'),        -- Recusa formal da vaga
    ('queue_withdrawn'),      -- Desistência formal da fila
    ('seat_passed_forward'),  -- Vaga repassada para o próximo por expiração de prazo
    ('returned_to_queue')     -- Retorno do aluno para a fila (desfazer chamado)
ON CONFLICT (code) DO NOTHING;

INSERT INTO enrollment_statuses (code) VALUES
    ('active'),      -- Matrícula ativa regular
    ('completed'),   -- Matrícula concluída / Ciclo finalizado
    ('transferred'), -- Aluno transferido para outra escola
    ('cancelled'),   -- Matrícula cancelada
    ('dropped_out')  -- Desligado / Evasão escolar
ON CONFLICT (code) DO NOTHING;

INSERT INTO notification_channels (code) VALUES
    ('app'),      -- Notificação no portal/aplicativo SIVE
    ('email'),    -- Disparo por e-mail
    ('sms'),      -- Disparo por SMS
    ('whatsapp')  -- Mensagem automática via WhatsApp
ON CONFLICT (code) DO NOTHING;

INSERT INTO notification_types (code) VALUES
    ('position_changed'),     -- Atualização de posição na fila de espera
    ('seat_called'),          -- Convocação urgente para comparecimento e matrícula
    ('deadline_alert'),       -- Lembrete de término de prazo para aceite
    ('enrollment_confirmed')  -- Confirmação da efetivação da matrícula
ON CONFLICT (code) DO NOTHING;

INSERT INTO notification_statuses (code) VALUES
    ('pending'), -- Pendente de envio
    ('sent'),    -- Enviado com sucesso
    ('failed'),  -- Falha no envio
    ('read')     -- Visualizado pelo responsável
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- 3. TABELAS DE NEGÓCIO: ORGANIZAÇÕES, ESCOLAS E USUÁRIOS
-- ============================================================================

-- Organizações (Prefeituras, Redes Particulares como Anglo/Objetivo)
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    legal_name VARCHAR(255) NOT NULL,
    trade_name VARCHAR(255) NOT NULL,
    document_cnpj VARCHAR(18) NOT NULL UNIQUE,
    organization_type_id UUID NOT NULL REFERENCES organization_types(id),
    status_id UUID NOT NULL REFERENCES organization_statuses(id),
    system_subdomain VARCHAR(100) UNIQUE,
    custom_domain VARCHAR(255) UNIQUE,
    settings JSONB NOT NULL DEFAULT '{
        "contact_days_deadline": 3,
        "enrollment_days_deadline": 5,
        "total_days_deadline": 8,
        "primary_color": "#0f766e"
    }'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Escolas vinculadas a uma organização
CREATE TABLE IF NOT EXISTS schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    inep_code VARCHAR(20) UNIQUE,
    name VARCHAR(255) NOT NULL,
    address_street VARCHAR(255) NOT NULL,
    address_number VARCHAR(50) NOT NULL,
    neighborhood VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    phone VARCHAR(20),
    email VARCHAR(255),
    total_capacity INT NOT NULL DEFAULT 0 CHECK (total_capacity >= 0),
    total_classrooms INT NOT NULL DEFAULT 0 CHECK (total_classrooms >= 0),
    status_id UUID NOT NULL REFERENCES school_statuses(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Usuários do sistema (Administradores, Gestores de Rede e Equipe Escolar)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    cpf VARCHAR(14) UNIQUE,
    phone VARCHAR(20),
    password_hash TEXT NOT NULL,
    status_id UUID NOT NULL REFERENCES user_statuses(id),
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membresias e Papéis de Acesso (RBAC com escopo por organização e escola)
CREATE TABLE IF NOT EXISTS users_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id),
    status_id UUID NOT NULL REFERENCES user_statuses(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_membership UNIQUE (user_id, organization_id, school_id, role_id)
);

-- Ofertas de Vagas / Turmas
CREATE TABLE IF NOT EXISTS school_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    educational_stage_id UUID NOT NULL REFERENCES educational_stages(id),
    grade_name VARCHAR(100) NOT NULL,
    shift_id UUID NOT NULL REFERENCES shifts(id),
    school_year SMALLINT NOT NULL,
    total_capacity INT NOT NULL CHECK (total_capacity >= 0),
    available_vacancies INT NOT NULL DEFAULT 0 CHECK (available_vacancies >= 0),
    status_id UUID NOT NULL REFERENCES class_statuses(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_school_class UNIQUE (school_id, grade_name, shift_id, school_year)
);

-- Histórico de Ajuste de Vagas (justificativa obrigatória para auditoria)
CREATE TABLE IF NOT EXISTS vacancy_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_class_id UUID NOT NULL REFERENCES school_classes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    previous_vacancies INT NOT NULL,
    new_vacancies INT NOT NULL,
    variation INT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 4. TABELAS: COMUNIDADE ESCOLAR (ALUNOS E RESPONSÁVEIS)
-- ============================================================================

-- Pais e Responsáveis
CREATE TABLE IF NOT EXISTS guardians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Vínculo opcional se tiver login no portal
    name VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    portal_access_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    is_solo_parent BOOLEAN NOT NULL DEFAULT FALSE,
    receives_social_benefit BOOLEAN NOT NULL DEFAULT FALSE,
    per_capita_income DECIMAL(10,2),
    is_rented_housing BOOLEAN NOT NULL DEFAULT FALSE,
    address_street VARCHAR(255),
    address_number VARCHAR(50),
    neighborhood VARCHAR(100),
    city VARCHAR(100),
    state CHAR(2),
    zip_code VARCHAR(10),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Alunos
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    birth_certificate_number VARCHAR(50),
    gender VARCHAR(20),
    has_special_needs BOOLEAN NOT NULL DEFAULT FALSE,
    special_needs_description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Relacionamento N:N entre Estudantes e Responsáveis
-- Permite que 1 Responsável tenha N Alunos e 1 Aluno tenha N Responsáveis (Pai, Mãe, Guardião Legal)
CREATE TABLE IF NOT EXISTS student_guardians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    guardian_id UUID NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
    kinship_type_id UUID NOT NULL REFERENCES kinship_types(id),
    is_primary_contact BOOLEAN NOT NULL DEFAULT TRUE,
    has_legal_custody BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_guardian UNIQUE (student_id, guardian_id)
);

-- ============================================================================
-- 5. TABELAS: MOTOR DE FILA, CRITÉRIOS DINÂMICOS E DESEMPATE
-- ============================================================================

-- Critérios definidos pela Organização (Prefeitura ou Rede Privada)
CREATE TABLE IF NOT EXISTS organization_criteria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    calculation_type_id UUID NOT NULL REFERENCES criteria_calculation_types(id),
    value_type_id UUID NOT NULL REFERENCES criteria_value_types(id),
    max_points DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    weight_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    is_tiebreaker BOOLEAN NOT NULL DEFAULT FALSE,
    tiebreaker_order INT NOT NULL DEFAULT 0,
    requires_document_proof BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- Habilitado / Desabilitado (toggle)
    rules_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_org_criterion_code UNIQUE (organization_id, code)
);

-- Inscrições na Fila de Espera / Solicitações de Vaga
CREATE TABLE IF NOT EXISTS enrollment_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    school_class_id UUID NOT NULL REFERENCES school_classes(id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    guardian_id UUID NOT NULL REFERENCES guardians(id) ON DELETE RESTRICT,
    status_id UUID NOT NULL REFERENCES application_statuses(id) ON DELETE RESTRICT,
    protocol_number VARCHAR(30) NOT NULL UNIQUE,
    queue_position INT,
    total_score DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    calculated_distance_meters DECIMAL(10,2),
    has_sibling_in_school BOOLEAN NOT NULL DEFAULT FALSE,
    called_at TIMESTAMPTZ,
    call_deadline_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_school_class UNIQUE (student_id, school_id, school_class_id)
);

-- Detalhamento dos Critérios para cada Solicitação (Transparência do Responsável)
CREATE TABLE IF NOT EXISTS application_criteria_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES enrollment_applications(id) ON DELETE CASCADE,
    criterion_id UUID NOT NULL REFERENCES organization_criteria(id) ON DELETE RESTRICT,
    raw_value_numeric DECIMAL(12,2),
    raw_value_string VARCHAR(255),
    calculated_score DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    applied_weight DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    is_qualified BOOLEAN NOT NULL DEFAULT FALSE,
    verification_status_id UUID NOT NULL REFERENCES criteria_verification_statuses(id),
    verification_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_app_criterion UNIQUE (application_id, criterion_id)
);

-- Histórico de Movimentações na Fila (Linha do Tempo e Transições de Status)
CREATE TABLE IF NOT EXISTS queue_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES enrollment_applications(id) ON DELETE CASCADE,
    event_type_id UUID NOT NULL REFERENCES queue_event_types(id),
    previous_status_id UUID REFERENCES application_statuses(id) ON DELETE SET NULL,
    new_status_id UUID REFERENCES application_statuses(id) ON DELETE SET NULL,
    actor_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    previous_position INT,
    new_position INT,
    description TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 6. TABELAS: MATRÍCULAS OFICIAIS, NOTIFICAÇÕES E AUDITORIA
-- ============================================================================

-- Matrículas regularizadas
CREATE TABLE IF NOT EXISTS enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES enrollment_applications(id) ON DELETE SET NULL,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE RESTRICT,
    school_class_id UUID NOT NULL REFERENCES school_classes(id) ON DELETE RESTRICT,
    enrollment_code VARCHAR(50) NOT NULL UNIQUE,
    status_id UUID NOT NULL REFERENCES enrollment_statuses(id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- Controle booleano da matrícula vigente
    enrolled_at DATE NOT NULL DEFAULT CURRENT_DATE,
    left_at DATE,
    leave_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Garante no máximo uma matrícula ativa por estudante simultaneamente
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_enrollment_per_student
    ON enrollments (student_id)
    WHERE (is_active = TRUE);

-- Notificações aos Pais e Responsáveis
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guardian_id UUID NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
    application_id UUID REFERENCES enrollment_applications(id) ON DELETE CASCADE,
    channel_id UUID NOT NULL REFERENCES notification_channels(id),
    notification_type_id UUID NOT NULL REFERENCES notification_types(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status_id UUID NOT NULL REFERENCES notification_statuses(id),
    read_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trilha de Auditoria (Governança e Ministério Público)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    diff_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 7. ÍNDICES DE PERFORMANCE E CONSULTAS FREQUENTES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_org_subdomain ON organizations(system_subdomain);
CREATE INDEX IF NOT EXISTS idx_org_custom_domain ON organizations(custom_domain);
CREATE INDEX IF NOT EXISTS idx_org_type ON organizations(organization_type_id);
CREATE INDEX IF NOT EXISTS idx_org_status ON organizations(status_id);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_cpf ON users(cpf);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status_id);

CREATE INDEX IF NOT EXISTS idx_memberships_user ON users_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_org ON users_memberships(organization_id);
CREATE INDEX IF NOT EXISTS idx_memberships_school ON users_memberships(school_id);
CREATE INDEX IF NOT EXISTS idx_memberships_role ON users_memberships(role_id);

CREATE INDEX IF NOT EXISTS idx_schools_org ON schools(organization_id);
CREATE INDEX IF NOT EXISTS idx_schools_status ON schools(status_id);
CREATE INDEX IF NOT EXISTS idx_schools_location ON schools(latitude, longitude);

CREATE INDEX IF NOT EXISTS idx_school_classes_school ON school_classes(school_id);
CREATE INDEX IF NOT EXISTS idx_school_classes_stage ON school_classes(educational_stage_id);
CREATE INDEX IF NOT EXISTS idx_school_classes_shift ON school_classes(shift_id);

CREATE INDEX IF NOT EXISTS idx_guardians_cpf ON guardians(cpf);
CREATE INDEX IF NOT EXISTS idx_guardians_user ON guardians(user_id);
CREATE INDEX IF NOT EXISTS idx_students_birth ON students(birth_date);
CREATE INDEX IF NOT EXISTS idx_student_guardians_student ON student_guardians(student_id);
CREATE INDEX IF NOT EXISTS idx_student_guardians_guardian ON student_guardians(guardian_id);
CREATE INDEX IF NOT EXISTS idx_student_guardians_kinship ON student_guardians(kinship_type_id);

CREATE INDEX IF NOT EXISTS idx_org_criteria_active ON organization_criteria(organization_id, is_active);
CREATE INDEX IF NOT EXISTS idx_statuses_code ON application_statuses(code);
CREATE INDEX IF NOT EXISTS idx_applications_status ON enrollment_applications(status_id);

-- Índice composto de altíssima relevância: Ordenação principal da fila de espera
CREATE INDEX IF NOT EXISTS idx_applications_queue_order 
    ON enrollment_applications(school_class_id, status_id, total_score DESC, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_applications_guardian ON enrollment_applications(guardian_id);
CREATE INDEX IF NOT EXISTS idx_applications_student ON enrollment_applications(student_id);

CREATE INDEX IF NOT EXISTS idx_app_criteria_scores ON application_criteria_scores(application_id);
CREATE INDEX IF NOT EXISTS idx_app_criteria_verification ON application_criteria_scores(verification_status_id);

CREATE INDEX IF NOT EXISTS idx_queue_movements_app ON queue_movements(application_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_queue_movements_event ON queue_movements(event_type_id);

CREATE INDEX IF NOT EXISTS idx_notifications_guardian ON notifications(guardian_id, status_id);
CREATE INDEX IF NOT EXISTS idx_audit_org_created ON audit_logs(organization_id, created_at DESC);
