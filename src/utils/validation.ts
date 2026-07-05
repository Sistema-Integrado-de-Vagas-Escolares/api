import type { ZodError, ZodIssue } from 'zod'
import type { ApiErrorItem } from '../types/api'

export const flattenZodIssues = (error: ZodError): ApiErrorItem[] => {
  return error.issues.map((issue: ZodIssue) => ({
    ...(issue.path.length > 0 ? { field: issue.path.join('.') } : {}),
    message: issue.message,
  }))
}