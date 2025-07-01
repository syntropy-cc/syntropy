import SocialAuthButtons from '@/components/auth/social-buttons';

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-900 to-slate-800">
      <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-10 shadow-2xl border border-white/20 max-w-md w-full">
        <h1 className="text-2xl font-bold text-center mb-6 text-white">Entrar na plataforma</h1>
        <SocialAuthButtons />
      </div>
    </main>
  );
}
