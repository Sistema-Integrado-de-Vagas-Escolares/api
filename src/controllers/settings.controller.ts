import type { Context } from 'hono'
import type { AppEnv } from '../types/context'
import { updateSettingsSchema } from '../validators/settings.validator'
import { flattenZodIssues } from '../utils/validation'
import { AppError } from '../utils/app-error'
import { ok } from '../utils/response'
import { getGlobalSettings, updateGlobalSettings } from '../services/settings.service'

export const show = async (c: Context<AppEnv>): Promise<Response> => {
  return ok(c, await getGlobalSettings(c.env))
}

export const update = async (c: Context<AppEnv>): Promise<Response> => {
  const payload = await c.req.json().catch(() => {
    throw new AppError('Payload invalido', 400)
  })

  const parsed = updateSettingsSchema.safeParse(payload)

  if (!parsed.success) {
    throw new AppError('Dados invalidos', 400, flattenZodIssues(parsed.error))
  }

  return ok(c, await updateGlobalSettings(c.env, parsed.data))
}