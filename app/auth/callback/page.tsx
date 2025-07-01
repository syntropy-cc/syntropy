'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function AuthCallback() {
  const router = useRouter();

  useEffect(() => {
    // O Supabase já trata o callback, só redireciona
    router.replace('/');
  }, [router]);

  return (
    <div className="flex items-center justify-center min-h-screen">
      <span className="text-lg text-gray-400">Autenticando...</span>
    </div>
  );
}
