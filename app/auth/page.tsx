import { AuthForm } from "@/components/auth/AuthForm"
import { Suspense } from "react"

interface AuthPageProps {
  searchParams: {
    mode?: "signin" | "signup"
    error?: string
  }
}

function AuthPageContent({ searchParams }: AuthPageProps) {
  return <AuthForm mode={searchParams.mode} />
}

export default function AuthPage({ searchParams }: AuthPageProps) {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <AuthPageContent searchParams={searchParams} />
    </Suspense>
  )
}
