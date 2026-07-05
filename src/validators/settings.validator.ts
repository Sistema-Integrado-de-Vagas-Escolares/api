import { z } from 'zod'

export const updateSettingsSchema = z.object({
  supportEmail: z.string().email(),
  systemVersion: z.string().min(1),
})
