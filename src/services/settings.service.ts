import type { AppBindings } from '../types/context'
import { getSettingsRecord, updateSettingsRecord } from '../repositories/settings.repository'
import type { Settings } from '../models/settings'

const toSettings = (settings: { support_email: string; system_version: string }): Settings => ({
  supportEmail: settings.support_email,
  systemVersion: settings.system_version,
})

export const getGlobalSettings = async (env: AppBindings): Promise<Settings> => {
  return toSettings(await getSettingsRecord(env))
}

export const updateGlobalSettings = async (
  env: AppBindings,
  input: Settings,
): Promise<Settings> => {
  return toSettings(
    await updateSettingsRecord(env, input.supportEmail, input.systemVersion),
  )
}