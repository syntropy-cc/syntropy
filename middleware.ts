import { getSupabaseReqResClient } from "@/lib/supabase"
import { NextRequest } from "next/server"

export async function middleware(req: NextRequest) {
  const { supabase, response } = getSupabaseReqResClient(req)

  // … sua lógica (ex.: proteger rotas) usando supabase …

  return response          // devolve a mesma instância já com os cookies certos
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * Feel free to modify this pattern to include more paths.
     */
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
}
