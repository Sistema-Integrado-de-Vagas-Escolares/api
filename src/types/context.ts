import type { AdminTokenPayload } from './auth'

export interface AppVariables {
  admin: AdminTokenPayload
}

export type AppBindings = CloudflareBindings & {
  JWT_SECRET: string
}

export interface AppEnv {
  Bindings: AppBindings
  Variables: AppVariables
}