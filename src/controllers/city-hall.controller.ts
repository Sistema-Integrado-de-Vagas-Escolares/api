import type { Context } from 'hono'
import type { AppEnv } from '../types/context'
import { createCityHallSchema, updateCityHallPasswordSchema, updateCityHallSchema } from '../validators/city-hall.validator'
import { idParamSchema } from '../validators/common.validator'
import { flattenZodIssues } from '../utils/validation'
import { AppError } from '../utils/app-error'
import { ok } from '../utils/response'
import {
  createCityHallService,
  getCityHall,
  getCityHalls,
  removeCityHallService,
  updateCityHallPasswordService,
  updateCityHallService,
} from '../services/city-hall.service'

export const list = async (c: Context<AppEnv>): Promise<Response> => {
  return ok(c, await getCityHalls(c.env))
}

export const show = async (c: Context<AppEnv>): Promise<Response> => {
  const parsed = idParamSchema.safeParse(c.req.param())

  if (!parsed.success) {
    throw new AppError('Identificador invalido', 400, flattenZodIssues(parsed.error))
  }

  return ok(c, await getCityHall(c.env, parsed.data.id))
}

export const create = async (c: Context<AppEnv>): Promise<Response> => {
  const payload = await c.req.json().catch(() => {
    throw new AppError('Payload invalido', 400)
  })

  const parsed = createCityHallSchema.safeParse(payload)

  if (!parsed.success) {
    throw new AppError('Dados invalidos', 400, flattenZodIssues(parsed.error))
  }

  return ok(c, await createCityHallService(c.env, parsed.data), 201)
}

export const update = async (c: Context<AppEnv>): Promise<Response> => {
  const params = idParamSchema.safeParse(c.req.param())
  if (!params.success) {
    throw new AppError('Identificador invalido', 400, flattenZodIssues(params.error))
  }

  const payload = await c.req.json().catch(() => {
    throw new AppError('Payload invalido', 400)
  })

  const parsed = updateCityHallSchema.safeParse(payload)
  if (!parsed.success) {
    throw new AppError('Dados invalidos', 400, flattenZodIssues(parsed.error))
  }

  return ok(c, await updateCityHallService(c.env, params.data.id, parsed.data))
}

export const updatePassword = async (c: Context<AppEnv>): Promise<Response> => {
  const params = idParamSchema.safeParse(c.req.param())
  if (!params.success) {
    throw new AppError('Identificador invalido', 400, flattenZodIssues(params.error))
  }

  const payload = await c.req.json().catch(() => {
    throw new AppError('Payload invalido', 400)
  })

  const parsed = updateCityHallPasswordSchema.safeParse(payload)
  if (!parsed.success) {
    throw new AppError('Dados invalidos', 400, flattenZodIssues(parsed.error))
  }

  await updateCityHallPasswordService(c.env, params.data.id, parsed.data)
  return ok(c, { message: 'Senha atualizada com sucesso' })
}

export const remove = async (c: Context<AppEnv>): Promise<Response> => {
  const parsed = idParamSchema.safeParse(c.req.param())
  if (!parsed.success) {
    throw new AppError('Identificador invalido', 400, flattenZodIssues(parsed.error))
  }

  await removeCityHallService(c.env, parsed.data.id)
  return ok(c, { message: 'Prefeitura removida com sucesso' })
}