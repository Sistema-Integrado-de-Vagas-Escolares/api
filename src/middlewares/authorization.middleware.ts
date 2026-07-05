import { createMiddleware } from 'hono/factory'
import type { AppEnv } from '../types/context'
import { AppError } from '../utils/app-error'

export const requireRole = (...roles: Array<'admin' | 'super_admin'>) =>
  createMiddleware<AppEnv>(async (c, next) => {
    const admin = c.get('admin')

    if (!roles.includes(admin.role)) {
      throw new AppError('Acesso negado', 403)
    }

    await next()
  })