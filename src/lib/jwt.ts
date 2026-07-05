import { SignJWT, jwtVerify } from 'jose'
import type { AdminTokenPayload } from '../types/auth'

const encodeSecret = (secret: string): Uint8Array => new TextEncoder().encode(secret)

export const signAdminToken = async (
  payload: AdminTokenPayload,
  secret: string,
): Promise<string> => {
  return new SignJWT({ email: payload.email, role: payload.role })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(payload.sub)
    .setIssuedAt()
    .setExpirationTime('8h')
    .sign(encodeSecret(secret))
}

export const verifyAdminToken = async (token: string, secret: string): Promise<AdminTokenPayload> => {
  const result = await jwtVerify(token, encodeSecret(secret))

  return {
    sub: result.payload.sub ?? '',
    email: typeof result.payload.email === 'string' ? result.payload.email : '',
    role: result.payload.role === 'super_admin' ? 'super_admin' : 'admin',
  }
}