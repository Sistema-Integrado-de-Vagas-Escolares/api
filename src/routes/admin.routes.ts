import { Hono } from 'hono'
import type { AppEnv } from '../types/context'
import { login } from '../controllers/auth.controller'
import {
  create,
  list,
  remove,
  show,
  update,
  updatePassword,
} from '../controllers/city-hall.controller'
import { show as showSettings, update as updateSettings } from '../controllers/settings.controller'
import { requireAdminAuth } from '../middlewares/auth.middleware'

export const adminRoutes = new Hono<AppEnv>()
const protectedAdminRoutes = new Hono<AppEnv>()

adminRoutes.post('/login', login)

protectedAdminRoutes.use('*', requireAdminAuth)

protectedAdminRoutes.get('/city-halls', list)
protectedAdminRoutes.get('/city-halls/:id', show)
protectedAdminRoutes.post('/city-halls', create)
protectedAdminRoutes.put('/city-halls/:id', update)
protectedAdminRoutes.patch('/city-halls/:id/password', updatePassword)
protectedAdminRoutes.delete('/city-halls/:id', remove)

protectedAdminRoutes.get('/settings', showSettings)
protectedAdminRoutes.put('/settings', updateSettings)

adminRoutes.route('/', protectedAdminRoutes)