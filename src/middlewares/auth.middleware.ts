import { createMiddleware } from 'hono/factory'
import type { AppEnv } from '../types/context'
import { AppError } from '../utils/app-error'
import { verifyAdminToken } from '../lib/jwt'

const readBearerToken = (authorizationHeader: string | undefined): string => {
  if (!authorizationHeader?.startsWith('Bearer ')) {
    throw new AppError('Token nao informado', 401)
  }

  return authorizationHeader.slice(7).trim()
}

export const requireAdminAuth = createMiddleware<AppEnv>(async (c, next) => {
  const token = readBearerToken(c.req.header('Authorization'))
  const payload = await verifyAdminToken(token, c.env.JWT_SECRET)

  if (!payload.sub) {
    throw new AppError('Token invalido', 401)
  }

  c.set('admin', payload)
  await next()
})