export type AdminRole = 'admin' | 'super_admin'
export type AdminStatus = 'ativo' | 'inativo'

export interface Admin {
  id: number
  nome: string
  email: string
  password: string
  role: AdminRole
  status: AdminStatus
  createdAt: string
  lastAccess?: string
}

export interface AdminRecord {
  id: number
  nome: string
  email: string
  password_hash: string
  role: AdminRole
  status: AdminStatus
  created_at: Date
  last_access: Date | null
}

export interface AdminPublic {
  id: number
  nome: string
  email: string
  role: AdminRole
  status: AdminStatus
  createdAt: string
  lastAccess?: string
}