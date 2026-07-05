export interface Settings {
  supportEmail: string
  systemVersion: string
}

export interface SettingsRecord {
  id: number
  support_email: string
  system_version: string
  updated_at: Date
}

export interface SettingsUpdateInput {
  supportEmail: string
  systemVersion: string
}