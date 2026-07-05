import type { AppBindings } from '../types/context'
import type { CityHallRecord, CityHallStatus, CityHallModule } from '../models/city-hall'
import { query, queryOne } from '../lib/db'

export const listCityHalls = async (env: AppBindings): Promise<CityHallRecord[]> => {
  return query<CityHallRecord>(
    env,
    `SELECT
      id,
      nome,
      cidade,
      estado,
      cnpj,
      email,
      password_hash,
      status,
      primary_color,
      system_name,
      contact_email,
      schools,
      created_at,
      last_access,
      modules
    FROM city_halls
    ORDER BY id ASC`,
  )
}

export const findCityHallById = async (
  env: AppBindings,
  id: number,
): Promise<CityHallRecord | null> => {
  return queryOne<CityHallRecord>(
    env,
    `SELECT
      id,
      nome,
      cidade,
      estado,
      cnpj,
      email,
      password_hash,
      status,
      primary_color,
      system_name,
      contact_email,
      schools,
      created_at,
      last_access,
      modules
    FROM city_halls
    WHERE id = $1
    LIMIT 1`,
    [id],
  )
}

export const createCityHall = async (
  env: AppBindings,
  input: {
    nome: string
    cidade: string
    estado: string
    cnpj: string
    email: string
    passwordHash: string
    status: CityHallStatus
    primaryColor: string
    systemName: string
    contactEmail: string
    schools: number
    modules: CityHallModule[]
  },
): Promise<CityHallRecord> => {
  const row = await queryOne<CityHallRecord>(
    env,
    `INSERT INTO city_halls (
      nome,
      cidade,
      estado,
      cnpj,
      email,
      password_hash,
      status,
      primary_color,
      system_name,
      contact_email,
      schools,
      modules
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    RETURNING
      id,
      nome,
      cidade,
      estado,
      cnpj,
      email,
      password_hash,
      status,
      primary_color,
      system_name,
      contact_email,
      schools,
      created_at,
      last_access,
      modules`,
    [
      input.nome,
      input.cidade,
      input.estado,
      input.cnpj,
      input.email,
      input.passwordHash,
      input.status,
      input.primaryColor,
      input.systemName,
      input.contactEmail,
      input.schools,
      input.modules,
    ],
  )

  if (!row) {
    throw new Error('Failed to create city hall')
  }

  return row
}

export const updateCityHall = async (
  env: AppBindings,
  id: number,
  input: {
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
  },
): Promise<CityHallRecord | null> => {
  return queryOne<CityHallRecord>(
    env,
    `UPDATE city_halls
     SET
       nome = $2,
       cidade = $3,
       estado = $4,
       cnpj = $5,
       email = $6,
       status = $7,
       primary_color = $8,
       system_name = $9,
       contact_email = $10,
       schools = $11,
       modules = $12,
       updated_at = NOW()
     WHERE id = $1
     RETURNING
       id,
       nome,
       cidade,
       estado,
       cnpj,
       email,
       password_hash,
       status,
       primary_color,
       system_name,
       contact_email,
       schools,
       created_at,
       last_access,
       modules`,
    [
      id,
      input.nome,
      input.cidade,
      input.estado,
      input.cnpj,
      input.email,
      input.status,
      input.primaryColor,
      input.systemName,
      input.contactEmail,
      input.schools,
      input.modules,
    ],
  )
}

export const updateCityHallPassword = async (
  env: AppBindings,
  id: number,
  passwordHash: string,
): Promise<void> => {
  await query(
    env,
    `UPDATE city_halls
     SET password_hash = $2, updated_at = NOW()
     WHERE id = $1`,
    [id, passwordHash],
  )
}

export const deleteCityHall = async (env: AppBindings, id: number): Promise<void> => {
  await query(env, 'DELETE FROM city_halls WHERE id = $1', [id])
}