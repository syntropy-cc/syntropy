import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // Verificar se as variáveis de ambiente estão disponíveis
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    
    if (!supabaseUrl || !supabaseKey) {
      return NextResponse.json(
        { 
          status: 'unhealthy', 
          error: 'Missing environment variables',
          timestamp: new Date().toISOString()
        }, 
        { status: 503 }
      );
    }

    // Teste básico de conectividade (opcional)
    // Você pode adicionar mais verificações aqui se necessário

    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      environment: {
        supabaseUrl: !!supabaseUrl,
        supabaseKey: !!supabaseKey,
        nodeEnv: process.env.NODE_ENV
      }
    });
  } catch (error) {
    return NextResponse.json(
      { 
        status: 'unhealthy', 
        error: 'Internal server error',
        timestamp: new Date().toISOString()
      }, 
      { status: 500 }
    );
  }
}