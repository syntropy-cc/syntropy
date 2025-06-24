import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Github, ExternalLink, Star, GitFork } from "lucide-react"

const projects = [
  {
    id: "1",
    title: "E-commerce Dashboard",
    description:
      "A modern admin dashboard for managing online stores with real-time analytics and inventory management.",
    tags: ["React", "Next.js", "TypeScript", "Tailwind"],
    difficulty: "intermediate",
    duration: "4-6 hours",
    stars: 124,
    forks: 32,
    image: "/placeholder.svg?height=200&width=400",
  },
  {
    id: "2",
    title: "Task Management App",
    description: "A collaborative task management application with real-time updates and team collaboration features.",
    tags: ["React", "Node.js", "Socket.io", "MongoDB"],
    difficulty: "beginner",
    duration: "2-3 hours",
    stars: 89,
    forks: 21,
    image: "/placeholder.svg?height=200&width=400",
  },
  {
    id: "3",
    title: "AI Chat Interface",
    description:
      "Build a modern chat interface with AI integration, featuring real-time messaging and smart responses.",
    tags: ["Next.js", "OpenAI", "WebSocket", "Prisma"],
    difficulty: "advanced",
    duration: "6-8 hours",
    stars: 256,
    forks: 67,
    image: "/placeholder.svg?height=200&width=400",
  },
  {
    id: "4",
    title: "Weather App",
    description: "A beautiful weather application with location-based forecasts and interactive maps.",
    tags: ["React", "API Integration", "Charts", "PWA"],
    difficulty: "beginner",
    duration: "3-4 hours",
    stars: 78,
    forks: 19,
    image: "/placeholder.svg?height=200&width=400",
  },
  {
    id: "5",
    title: "Social Media Dashboard",
    description: "Analytics dashboard for social media management with data visualization and scheduling features.",
    tags: ["Vue.js", "D3.js", "Express", "PostgreSQL"],
    difficulty: "intermediate",
    duration: "5-7 hours",
    stars: 143,
    forks: 38,
    image: "/placeholder.svg?height=200&width=400",
  },
  {
    id: "6",
    title: "Blockchain Wallet",
    description: "A secure cryptocurrency wallet with transaction history and multi-currency support.",
    tags: ["React", "Web3", "Ethereum", "Solidity"],
    difficulty: "advanced",
    duration: "8-10 hours",
    stars: 312,
    forks: 89,
    image: "/placeholder.svg?height=200&width=400",
  },
]

export default function ProjectsPage() {
  return (
    <div className="container py-8">
      {/* Hero Section */}
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">Build Real Projects</h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Apply your skills by building real-world projects. Each project includes step-by-step guidance and complete
          source code.
        </p>
      </div>

      {/* Stats */}
      <div className="grid md:grid-cols-3 gap-6 mb-12">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Projects</CardTitle>
            <Github className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{projects.length}</div>
            <p className="text-xs text-muted-foreground">Ready to build</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Difficulty Levels</CardTitle>
            <Star className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">3</div>
            <p className="text-xs text-muted-foreground">Beginner to Advanced</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Technologies</CardTitle>
            <GitFork className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">15+</div>
            <p className="text-xs text-muted-foreground">Modern tech stack</p>
          </CardContent>
        </Card>
      </div>

      {/* Projects Grid */}
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {projects.map((project) => (
          <Card key={project.id} className="hover:shadow-lg transition-shadow">
            <CardHeader className="p-0">
              <div className="aspect-video bg-muted rounded-t-lg flex items-center justify-center">
                <img
                  src={project.image || "/placeholder.svg"}
                  alt={project.title}
                  className="w-full h-full object-cover rounded-t-lg"
                />
              </div>
            </CardHeader>
            <CardContent className="p-6">
              <div className="space-y-4">
                <div className="flex justify-between items-start">
                  <Badge variant="secondary">{project.difficulty}</Badge>
                  <span className="text-sm text-muted-foreground">{project.duration}</span>
                </div>

                <div>
                  <CardTitle className="line-clamp-1 mb-2">{project.title}</CardTitle>
                  <CardDescription className="line-clamp-3">{project.description}</CardDescription>
                </div>

                <div className="flex flex-wrap gap-1">
                  {project.tags.slice(0, 3).map((tag) => (
                    <Badge key={tag} variant="outline" className="text-xs">
                      {tag}
                    </Badge>
                  ))}
                  {project.tags.length > 3 && (
                    <Badge variant="outline" className="text-xs">
                      +{project.tags.length - 3}
                    </Badge>
                  )}
                </div>

                <div className="flex items-center justify-between pt-2">
                  <div className="flex items-center gap-4 text-sm text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Star className="h-3 w-3" />
                      {project.stars}
                    </div>
                    <div className="flex items-center gap-1">
                      <GitFork className="h-3 w-3" />
                      {project.forks}
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Button variant="outline" size="sm">
                      <Github className="h-3 w-3 mr-1" />
                      Code
                    </Button>
                    <Button size="sm">
                      <ExternalLink className="h-3 w-3 mr-1" />
                      Build
                    </Button>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* CTA Section */}
      <div className="mt-16 bg-muted/50 rounded-lg p-8 text-center">
        <h2 className="text-2xl font-bold mb-4">Have a Project Idea?</h2>
        <p className="text-muted-foreground mb-6 max-w-2xl mx-auto">
          We're always looking for new project ideas. Submit your suggestion and help the community learn by building.
        </p>
        <Button>Submit Project Idea</Button>
      </div>
    </div>
  )
}
