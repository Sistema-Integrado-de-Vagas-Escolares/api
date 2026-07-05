import type { Hono } from 'hono'
import type { AppEnv } from '../types/context'
import { adminRoutes } from './admin.routes'

export const registerRoutes = (app: Hono<AppEnv>): void => {
  app.route('/admin', adminRoutes)
}