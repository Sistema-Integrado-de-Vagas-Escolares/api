import type { Hono } from 'hono'
import type { AppEnv } from '../types/context'
import { AppError } from '../utils/app-error'
import { fail } from '../utils/response'

export const registerErrorHandlers = (app: Hono<AppEnv>): void => {
  app.notFound((c) => fail(c, 'Rota nao encontrada', [], 404))

  app.onError((error, c) => {
    if (error instanceof AppError) {
      return fail(c, error.message, error.errors, error.statusCode)
    }

    console.error(error)
    return fail(c, 'Erro interno do servidor', [], 500)
  })
}