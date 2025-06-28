/* app/learn/courses/loading.tsx (ou equivalente) */
import { Skeleton } from "@/components/ui/skeleton"

export default function Loading() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white pb-16">
      <div className="container pt-16">
        {/* mesma grade responsiva adoptada na página principal */}
        <div className="grid grid-cols-[repeat(auto-fill,minmax(250px,1fr))] gap-6 md:gap-8">
          {Array.from({ length: 6 }).map((_, i) => (
            <div
              key={i}
              className="flex flex-col overflow-hidden rounded-2xl bg-slate-800/80 shadow-md"
            >
              {/* Capa 3:4 */}
              <div className="relative aspect-[3/4] w-full overflow-hidden">
                <Skeleton className="absolute inset-0 h-full w-full" />
              </div>

              {/* Corpo */}
              <div className="flex flex-col gap-3 p-4 grow">
                {/* Título */}
                <Skeleton className="h-6 w-3/4" />

                {/* Descrição */}
                <Skeleton className="h-4 w-full" />

                {/* Metadados */}
                <div className="flex items-center gap-2">
                  <Skeleton className="h-4 w-16 rounded-full" />
                  <Skeleton className="h-4 w-12" />
                </div>

                {/* Autor */}
                <div className="mt-auto flex items-center gap-2">
                  <Skeleton className="h-7 w-7 rounded-full" />
                  <Skeleton className="h-4 w-20" />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}