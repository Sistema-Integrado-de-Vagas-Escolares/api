export type CityHallStatus = 'ativo' | 'inativo' | 'pendente'
export type CityHallModule = 'prefeitura' | 'escola' | 'responsavel' | 'mapa'

export interface CityHall {
  id: number
  nome: string
  cidade: string
  estado: string
  cnpj: string
  email: string
  password: string
  status: CityHallStatus
  primaryColor: string
  systemName: string
  contactEmail: string
  schools: number
  createdAt: string
  lastAccess?: string
  modules: CityHallModule[]
}

export interface CityHallRecord {
  id: number
  nome: string
  cidade: string
  estado: string
  cnpj: string
  email: string
  password_hash: string
  status: CityHallStatus
  primary_color: string
  system_name: string
  contact_email: string
  schools: number
  created_at: Date
  last_access: Date | null
  modules: CityHallModule[]
}

export type PublicCityHall = Omit<CityHall, 'password'>

export interface CityHallCreateInput {
  nome: string
  cidade: string
  estado: string
  cnpj: string
  email: string
  password: string
  status: CityHallStatus
  primaryColor: string
  systemName: string
  contactEmail: string
  schools: number
  modules: CityHallModule[]
}

export interface CityHallUpdateInput {
  nome: string
  cidade: string
  estado: string
  cnpj: string
  email: string
  status: CityHallStatus
  primaryColor: string
  systemName: string
  contactEmail: string
  schools: number
  modules: CityHallModule[]
}

export interface CityHallPasswordInput {
  password: string
}