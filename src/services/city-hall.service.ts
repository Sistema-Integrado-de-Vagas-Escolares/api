import type { AppBindings } from '../types/context'
import { AppError } from '../utils/app-error'
import { hashPassword } from '../utils/password'
import {
  createCityHall,
  deleteCityHall,
  findCityHallById,
  listCityHalls,
  updateCityHall,
  updateCityHallPassword,
} from '../repositories/city-hall.repository'
import type {
  CityHallCreateInput,
  CityHallUpdateInput,
  CityHallPasswordInput,
  PublicCityHall,
  CityHallRecord,
} from '../models/city-hall'

const toPublicCityHall = (row: CityHallRecord): PublicCityHall => ({
  id: row.id,
  nome: row.nome,
  cidade: row.cidade,
  estado: row.estado,
  cnpj: row.cnpj,
  email: row.email,
  status: row.status,
  primaryColor: row.primary_color,
  systemName: row.system_name,
  contactEmail: row.contact_email,
  schools: row.schools,
  createdAt: row.created_at.toISOString(),
  ...(row.last_access ? { lastAccess: row.last_access.toISOString() } : {}),
  modules: row.modules,
})

export const getCityHalls = async (env: AppBindings): Promise<PublicCityHall[]> => {
  const rows = await listCityHalls(env)
  return rows.map(toPublicCityHall)
}

export const getCityHall = async (env: AppBindings, id: number): Promise<PublicCityHall> => {
  const cityHall = await findCityHallById(env, id)

  if (!cityHall) {
    throw new AppError('Prefeitura nao encontrada', 404)
  }

  return toPublicCityHall(cityHall)
}

export const createCityHallService = async (
  env: AppBindings,
  input: CityHallCreateInput,
): Promise<PublicCityHall> => {
  const passwordHash = await hashPassword(input.password)
  const row = await createCityHall(env, {
    nome: input.nome,
    cidade: input.cidade,
    estado: input.estado,
    cnpj: input.cnpj,
    email: input.email,
    passwordHash,
    status: input.status,
    primaryColor: input.primaryColor,
    systemName: input.systemName,
    contactEmail: input.contactEmail,
    schools: input.schools,
    modules: input.modules,
  })

  return toPublicCityHall(row)
}

export const updateCityHallService = async (
  env: AppBindings,
  id: number,
  input: CityHallUpdateInput,
): Promise<PublicCityHall> => {
  const row = await updateCityHall(env, id, input)

  if (!row) {
    throw new AppError('Prefeitura nao encontrada', 404)
  }

  return toPublicCityHall(row)
}

export const updateCityHallPasswordService = async (
  env: AppBindings,
  id: number,
  input: CityHallPasswordInput,
): Promise<void> => {
  const cityHall = await findCityHallById(env, id)

  if (!cityHall) {
    throw new AppError('Prefeitura nao encontrada', 404)
  }

  const passwordHash = await hashPassword(input.password)
  await updateCityHallPassword(env, id, passwordHash)
}

export const removeCityHallService = async (env: AppBindings, id: number): Promise<void> => {
  const cityHall = await findCityHallById(env, id)

  if (!cityHall) {
    throw new AppError('Prefeitura nao encontrada', 404)
  }

  await deleteCityHall(env, id)
}