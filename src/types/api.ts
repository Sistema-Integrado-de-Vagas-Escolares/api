export interface ApiErrorItem {
  field?: string
  message: string
}

export interface ApiSuccessResponse<T> {
  success: true
  data: T
}

export interface ApiErrorResponse {
  success: false
  message: string
  errors: ApiErrorItem[]
}

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse