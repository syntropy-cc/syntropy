import { createClient, isSupabaseConfigured } from "@/lib/supabase/supabase"
import type { Provider } from "@supabase/supabase-js"

export async function signInWithOAuth(provider: Provider) {
  if (!isSupabaseConfigured()) {
    throw new Error("Supabase not configured. Please set up your environment variables.")
  }

  const supabase = createClient()
  if (!supabase) {
    throw new Error("Failed to create Supabase client")
  }

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider,
    options: {
      redirectTo: `${window.location.origin}/auth/callback`,
    },
  })

  if (error) {
    throw error
  }

  return data
}

export async function signOut() {
  if (!isSupabaseConfigured()) {
    throw new Error("Supabase not configured")
  }

  const supabase = createClient()
  if (!supabase) {
    throw new Error("Failed to create Supabase client")
  }

  const { error } = await supabase.auth.signOut()

  if (error) {
    throw error
  }
}

export async function getCurrentUser() {
  if (!isSupabaseConfigured()) {
    return null
  }

  const supabase = createClient()
  if (!supabase) {
    return null
  }

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()

  if (error) {
    console.warn("Error getting user:", error)
    return null
  }

  return user
}

export async function getSession() {
  if (!isSupabaseConfigured()) {
    return null
  }

  const supabase = createClient()
  if (!supabase) {
    return null
  }

  const {
    data: { session },
    error,
  } = await supabase.auth.getSession()

  if (error) {
    console.warn("Error getting session:", error)
    return null
  }

  return session
}
