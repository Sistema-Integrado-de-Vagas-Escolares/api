import type { AdminRole } from '../models/admin'

export interface AdminTokenPayload {
  sub: string
  email: string
  role: AdminRole
}

export interface AuthenticatedAdmin {
  id: number
  nome: string
  email: string
  role: AdminRole
  status: 'ativo' | 'inativo'
  lastAccess?: string
}