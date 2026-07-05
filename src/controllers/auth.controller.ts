import type { Context } from 'hono'
import type { AppEnv } from '../types/context'
import { loginSchema } from '../validators/auth.validator'
import { flattenZodIssues } from '../utils/validation'
import { AppError } from '../utils/app-error'
import { ok } from '../utils/response'
import { loginAdmin } from '../services/auth.service'

export const login = async (c: Context<AppEnv>): Promise<Response> => {
  const payload = await c.req.json().catch(() => {
    throw new AppError('Payload invalido', 400)
  })

  const parsed = loginSchema.safeParse(payload)

  if (!parsed.success) {
    throw new AppError('Dados invalidos', 400, flattenZodIssues(parsed.error))
  }

  const result = await loginAdmin(c.env, parsed.data)
  return ok(c, result)
}