import type { Context } from 'hono'
import type { ContentfulStatusCode } from 'hono/utils/http-status'
import type { ApiErrorItem } from '../types/api'
import type { AppEnv } from '../types/context'

export const ok = <T>(
  c: Context<AppEnv>,
  data: T,
  status: ContentfulStatusCode = 200,
): Response => {
  return c.json({ success: true, data }, status)
}

export const fail = (
  c: Context<AppEnv>,
  message: string,
  errors: ApiErrorItem[] = [],
  status: ContentfulStatusCode = 400,
): Response => {
  return c.json({ success: false, message, errors }, status)
}