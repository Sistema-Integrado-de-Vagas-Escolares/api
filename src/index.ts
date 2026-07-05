import { Hono } from 'hono'
import type { AppEnv } from './types/context'
import { registerErrorHandlers } from './middlewares/error.middleware'
import { registerRoutes } from './routes'

const app = new Hono<AppEnv>()

app.get('/', (c) => {
  return c.json({
    success: true,
    data: {
      service: 'SIVE API',
      status: 'ok',
    },
  })
})

registerErrorHandlers(app)
registerRoutes(app)

export default app
