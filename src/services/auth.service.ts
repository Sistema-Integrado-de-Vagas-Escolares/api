import { findAdminByEmail, updateAdminLastAccess } from '../repositories/admin.repository'
import { signAdminToken } from '../lib/jwt'
import { verifyPassword } from '../utils/password'
import { AppError } from '../utils/app-error'
import type { AppBindings } from '../types/context'
import type { AdminPublic } from '../models/admin'
import type { AdminTokenPayload } from '../types/auth'

const toAdminPublic = (admin: {
  id: number
  nome: string
  email: string
  role: 'admin' | 'super_admin'
  status: 'ativo' | 'inativo'
  created_at: Date
  last_access: Date | null
}): AdminPublic => ({
  id: admin.id,
  nome: admin.nome,
  email: admin.email,
  role: admin.role,
  status: admin.status,
  createdAt: admin.created_at.toISOString(),
  ...(admin.last_access ? { lastAccess: admin.last_access.toISOString() } : {}),
})

export const loginAdmin = async (
  env: AppBindings,
  credentials: { email: string; password: string },
): Promise<{ token: string; admin: AdminPublic }> => {
  const admin = await findAdminByEmail(env, credentials.email)

  if (!admin || admin.status !== 'ativo') {
    throw new AppError('Credenciais invalidas', 401)
  }

  const passwordIsValid = await verifyPassword(credentials.password, admin.password_hash)

  if (!passwordIsValid) {
    throw new AppError('Credenciais invalidas', 401)
  }

  await updateAdminLastAccess(env, admin.id)

  const tokenPayload: AdminTokenPayload = {
    sub: String(admin.id),
    email: admin.email,
    role: admin.role,
  }

  const token = await signAdminToken(tokenPayload, env.JWT_SECRET)

  return {
    token,
    admin: toAdminPublic(admin),
  }
}