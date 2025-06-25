import { Skeleton } from "@/components/ui/skeleton"

export default function Loading() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900/20 to-slate-900 text-white pb-16">
      <div className="container pt-10">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6 mb-8">
          <div className="flex-1">
            <div className="relative">
              <Skeleton className="h-12 w-full rounded-lg" />
            </div>
          </div>
          <Skeleton className="h-12 w-40 rounded-lg" />
        </div>
        <div className="flex flex-wrap items-center gap-3 mb-6">
          <Skeleton className="h-8 w-24 rounded-full" />
          <Skeleton className="h-8 w-24 rounded-full" />
          <Skeleton className="h-8 w-24 rounded-full" />
          <Skeleton className="h-8 w-32 rounded-full" />
          <Skeleton className="h-8 w-40 rounded-full" />
        </div>
        <div className="flex flex-wrap gap-3 mb-8">
          <Skeleton className="h-7 w-20 rounded-full" />
          <Skeleton className="h-7 w-28 rounded-full" />
          <Skeleton className="h-7 w-32 rounded-full" />
        </div>
        <div className="flex flex-col md:flex-row md:items-end md:justify-between mb-6 gap-2">
          <Skeleton className="h-10 w-64 rounded" />
          <Skeleton className="h-6 w-32 rounded" />
        </div>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="bg-slate-800/80 border-none shadow-lg rounded-lg p-6">
              <div className="flex justify-between items-center mb-4">
                <Skeleton className="h-6 w-20 rounded-full" />
                <Skeleton className="h-6 w-10 rounded-full" />
              </div>
              <Skeleton className="h-8 w-3/4 mb-2 rounded" />
              <Skeleton className="h-5 w-full mb-4 rounded" />
              <div className="flex gap-2 mb-3">
                <Skeleton className="h-5 w-16 rounded-full" />
                <Skeleton className="h-5 w-16 rounded-full" />
                <Skeleton className="h-5 w-16 rounded-full" />
              </div>
              <div className="flex items-center justify-between mb-2">
                <Skeleton className="h-4 w-20 rounded" />
                <Skeleton className="h-4 w-20 rounded" />
                <Skeleton className="h-4 w-20 rounded" />
              </div>
              <div className="flex items-center gap-2 mt-2">
                <Skeleton className="h-8 w-8 rounded-full" />
                <Skeleton className="h-5 w-32 rounded" />
              </div>
              <Skeleton className="h-10 w-full mt-4 rounded" />
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
