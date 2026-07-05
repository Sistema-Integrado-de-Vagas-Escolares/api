import type { AppBindings } from '../types/context'
import type { AdminRecord, AdminRole } from '../models/admin'
import { queryOne, query } from '../lib/db'

export const findAdminByEmail = async (
  env: AppBindings,
  email: string,
): Promise<AdminRecord | null> => {
  return queryOne<AdminRecord>(
    env,
    `SELECT
      id,
      nome,
      email,
      password_hash,
      role,
      status,
      created_at,
      last_access
    FROM admins
    WHERE email = $1
    LIMIT 1`,
    [email],
  )
}

export const updateAdminLastAccess = async (env: AppBindings, adminId: number): Promise<void> => {
  await query(
    env,
    `UPDATE admins
     SET last_access = NOW(), updated_at = NOW()
     WHERE id = $1`,
    [adminId],
  )
}

export const listAdmins = async (env: AppBindings): Promise<AdminRecord[]> => {
  return query<AdminRecord>(
    env,
    `SELECT
      id,
      nome,
      email,
      password_hash,
      role,
      status,
      created_at,
      last_access
    FROM admins
    ORDER BY id ASC`,
  )
}

export const createAdmin = async (
  env: AppBindings,
  admin: {
    nome: string
    email: string
    passwordHash: string
    role: AdminRole
    status: 'ativo' | 'inativo'
  },
): Promise<AdminRecord> => {
  const row = await queryOne<AdminRecord>(
    env,
    `INSERT INTO admins (nome, email, password_hash, role, status)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING
       id,
       nome,
       email,
       password_hash,
       role,
       status,
       created_at,
       last_access`,
    [admin.nome, admin.email, admin.passwordHash, admin.role, admin.status],
  )

  if (!row) {
    throw new Error('Failed to create admin')
  }

  return row
}