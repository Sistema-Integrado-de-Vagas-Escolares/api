import type { AppBindings } from '../types/context'
import type { SettingsRecord } from '../models/settings'
import { queryOne } from '../lib/db'

export const getSettingsRecord = async (env: AppBindings): Promise<SettingsRecord> => {
  const row = await queryOne<SettingsRecord>(
    env,
    `SELECT
      id,
      support_email,
      system_version,
      updated_at
    FROM settings
    WHERE id = 1`,
  )

  if (!row) {
    throw new Error('Settings row not found')
  }

  return row
}

export const updateSettingsRecord = async (
  env: AppBindings,
  supportEmail: string,
  systemVersion: string,
): Promise<SettingsRecord> => {
  const row = await queryOne<SettingsRecord>(
    env,
    `UPDATE settings
     SET support_email = $1,
         system_version = $2,
         updated_at = NOW()
     WHERE id = 1
     RETURNING id, support_email, system_version, updated_at`,
    [supportEmail, systemVersion],
  )

  if (!row) {
    throw new Error('Failed to update settings')
  }

  return row
}