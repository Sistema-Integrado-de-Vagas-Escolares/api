import type { ContentfulStatusCode } from 'hono/utils/http-status'
import type { ApiErrorItem } from '../types/api'

export class AppError extends Error {
  readonly statusCode: ContentfulStatusCode
  readonly errors: ApiErrorItem[]

  constructor(
    message: string,
    statusCode: ContentfulStatusCode = 400,
    errors: ApiErrorItem[] = [],
  ) {
    super(message)
    this.name = 'AppError'
    this.statusCode = statusCode
    this.errors = errors
  }
}