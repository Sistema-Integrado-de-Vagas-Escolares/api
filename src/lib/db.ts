import { Pool } from 'pg'
import type { QueryResultRow } from 'pg'
import type { AppBindings } from '../types/context'

const pools = new Map<string, Pool>()

const getConnectionString = (env: AppBindings): string => {
  if (!env.HYPERDRIVE.connectionString) {
    throw new Error('Hyperdrive connection string is not available')
  }

  return env.HYPERDRIVE.connectionString
}

export const getPool = (env: AppBindings): Pool => {
  const connectionString = getConnectionString(env)
  const existingPool = pools.get(connectionString)

  if (existingPool) {
    return existingPool
  }

  const pool = new Pool({
    connectionString,
    max: 5,
  })

  pools.set(connectionString, pool)
  return pool
}

export const query = async <T extends QueryResultRow>(
  env: AppBindings,
  text: string,
  values: unknown[] = [],
): Promise<T[]> => {
  const pool = getPool(env)
  const result = await pool.query<T>(text, values)
  return result.rows
}

export const queryOne = async <T extends QueryResultRow>(
  env: AppBindings,
  text: string,
  values: unknown[] = [],
): Promise<T | null> => {
  const rows = await query<T>(env, text, values)
  return rows[0] ?? null
}