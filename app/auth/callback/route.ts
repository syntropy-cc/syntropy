import { createServerSupabaseClient } from "@/lib/supabase"
import { type NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get("code")

  if (code) {
    const supabase = await createServerSupabaseClient()

    const { error } = await supabase.auth.exchangeCodeForSession(code)

    if (error) {
      console.error("Auth callback error:", error)
      return NextResponse.redirect(`${requestUrl.origin}/auth?error=callback_error`)
    }
  }

  // Redirect to dashboard or intended page
  const next = requestUrl.searchParams.get("next") || "/learn"
  return NextResponse.redirect(`${requestUrl.origin}${next}`)
}
