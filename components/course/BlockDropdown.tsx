"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { ChevronDown, ChevronRight, Clock, Play, CheckCircle } from "lucide-react"
import Link from "next/link"

interface Unit {
  id: string
  title: string
  description?: string
  duration?: number | string
  artifact?: string
  fragments?: string[]
  slug: string
}

interface Block {
  id: string
  title: string
  description: string
  units: Unit[]
}

interface BlockDropdownProps {
  block: Block
  blockIndex: number
  courseSlug: string
}

export function BlockDropdown({ block, blockIndex, courseSlug }: BlockDropdownProps) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <Card className="border border-border/50 hover:border-syntropy-600/30 transition-all duration-200">
      <CardContent className="p-0">
        {/* Block Header - Clickable para expandir/colapsar */}
        <button
          onClick={() => setIsExpanded(!isExpanded)}
          className="w-full p-4 text-left hover:bg-muted/30 transition-colors"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div>
                <h3 className="font-semibold text-lg text-syntropy-600">{block.title}</h3>
                <p className="text-sm text-muted-foreground">{block.description}</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="text-xs">
                {block.units.length} unidades
              </Badge>
              {isExpanded ? (
                <ChevronDown className="h-4 w-4 text-muted-foreground" />
              ) : (
                <ChevronRight className="h-4 w-4 text-muted-foreground" />
              )}
            </div>
          </div>
        </button>

        {/* Units List - Expandable */}
        {isExpanded && (
          <div className="border-t border-border/50 bg-muted/20">
            <div className="p-4 space-y-3">
              {block.units.map((unit, unitIndex) => (
                <UnitCard
                  key={unit.id}
                  unit={unit}
                  unitIndex={unitIndex}
                  blockIndex={blockIndex}
                  courseSlug={courseSlug}
                />
              ))}
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

interface UnitCardProps {
  unit: Unit
  unitIndex: number
  blockIndex: number
  courseSlug: string
}

function UnitCard({ unit, unitIndex, blockIndex, courseSlug }: UnitCardProps) {
  const [showDetails, setShowDetails] = useState(false)

  return (
    <div className="group bg-background border border-border/30 rounded-lg hover:border-syntropy-600/40 transition-all duration-200">
      {/* Main Unit Content */}
      <div className="p-4">
        <div className="flex items-center gap-3 mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-3">
              <h4 className="font-medium text-base group-hover:text-syntropy-600 transition-colors">
                {unit.title}
              </h4>
              {unit.duration && (
                <div className="flex items-center gap-1 text-xs text-muted-foreground bg-muted/50 px-2 py-1 rounded-md">
                  <Clock className="h-3 w-3" />
                  {unit.duration} min
                </div>
              )}
            </div>
            {unit.description && (
              <p className="text-sm text-muted-foreground mt-1 line-clamp-2">
                {unit.description}
              </p>
            )}
          </div>
          <Button
            asChild
            size="sm"
            className="bg-syntropy-600 hover:bg-syntropy-700 text-white opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <Link href={`/learn/courses/${courseSlug}/${unit.slug}`}>
              <Play className="h-3 w-3 mr-1" />
              Iniciar
            </Link>
          </Button>
        </div>

        {/* Details Toggle Button */}
        <button
          onClick={() => setShowDetails(!showDetails)}
          className="w-full mt-3 py-2 px-3 bg-muted/50 hover:bg-muted/70 rounded-md transition-colors text-xs font-medium text-muted-foreground hover:text-foreground flex items-center justify-center gap-2"
        >
          {showDetails ? (
            <>
              <ChevronDown className="h-3 w-3" />
              Ocultar detalhes
            </>
          ) : (
            <>
              <ChevronRight className="h-3 w-3" />
              Ver fragmentos e conteúdo detalhado
            </>
          )}
        </button>
      </div>

      {/* Expandable Details */}
      {showDetails && (
        <div className="border-t border-border/30 bg-muted/30 p-4">
          <h5 className="font-medium text-sm mb-3 text-muted-foreground uppercase tracking-wide">
            Fragmentos da Unidade
          </h5>
          <div className="space-y-2">
            {unit.fragments?.map((fragment, fragmentIndex) => (
              <div key={fragmentIndex} className="flex items-center gap-3 py-2 px-3 bg-background rounded-md border border-border/20">
                <div className="w-2 h-2 rounded-full bg-blue-500 flex-shrink-0" />
                <span className="text-sm">{fragment}</span>
              </div>
            ))}
            {unit.artifact && (
              <div className="mt-3 p-3 bg-syntropy-50 border border-syntropy-200 rounded-md">
                <div className="flex items-start gap-3">
                  <CheckCircle className="h-4 w-4 text-syntropy-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <span className="text-sm font-medium text-syntropy-800">Artefato Prático:</span>
                    <p className="text-sm text-syntropy-700 mt-1">{unit.artifact}</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
