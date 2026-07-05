import { z } from 'zod'

const cityHallModuleSchema = z.enum(['prefeitura', 'escola', 'responsavel', 'mapa'])

const cityHallBaseSchema = {
  nome: z.string().min(2),
  cidade: z.string().min(2),
  estado: z.string().min(2).max(2),
  cnpj: z.string().min(14),
  email: z.string().email(),
  status: z.enum(['ativo', 'inativo', 'pendente']),
  primaryColor: z.string().min(3),
  systemName: z.string().min(2),
  contactEmail: z.string().email(),
  schools: z.coerce.number().int().nonnegative(),
  modules: z.array(cityHallModuleSchema).min(1),
}

export const createCityHallSchema = z.object({
  ...cityHallBaseSchema,
  password: z.string().min(8),
})

export const updateCityHallSchema = z.object(cityHallBaseSchema)

export const updateCityHallPasswordSchema = z.object({
  password: z.string().min(8),
})
