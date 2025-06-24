import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { FlaskConical, Zap, Cpu, Database, Globe, Smartphone } from "lucide-react"

const labs = [
  {
    id: "1",
    title: "React Performance Lab",
    description: "Experiment with React optimization techniques, profiling tools, and performance monitoring.",
    category: "Frontend",
    difficulty: "intermediate",
    duration: "45 min",
    icon: Zap,
    technologies: ["React", "Profiler", "DevTools"],
    status: "available",
  },
  {
    id: "2",
    title: "Database Query Optimization",
    description: "Learn advanced SQL techniques and database performance tuning in a sandbox environment.",
    category: "Backend",
    difficulty: "advanced",
    duration: "60 min",
    icon: Database,
    technologies: ["PostgreSQL", "Indexing", "Query Plans"],
    status: "available",
  },
  {
    id: "3",
    title: "API Rate Limiting",
    description: "Implement and test different rate limiting strategies for REST and GraphQL APIs.",
    category: "Backend",
    difficulty: "intermediate",
    duration: "30 min",
    icon: Globe,
    technologies: ["Node.js", "Redis", "Express"],
    status: "available",
  },
  {
    id: "4",
    title: "Mobile App Testing",
    description: "Explore automated testing strategies for React Native applications.",
    category: "Mobile",
    difficulty: "intermediate",
    duration: "50 min",
    icon: Smartphone,
    technologies: ["React Native", "Jest", "Detox"],
    status: "coming-soon",
  },
  {
    id: "5",
    title: "Microservices Communication",
    description: "Experiment with different communication patterns between microservices.",
    category: "Architecture",
    difficulty: "advanced",
    duration: "75 min",
    icon: Cpu,
    technologies: ["Docker", "gRPC", "Message Queues"],
    status: "available",
  },
  {
    id: "6",
    title: "WebAssembly Performance",
    description: "Compare JavaScript vs WebAssembly performance for compute-intensive tasks.",
    category: "Performance",
    difficulty: "advanced",
    duration: "40 min",
    icon: Zap,
    technologies: ["WebAssembly", "Rust", "Benchmarking"],
    status: "coming-soon",
  },
]

const categories = ["All", "Frontend", "Backend", "Mobile", "Architecture", "Performance"]

export default function LabsPage() {
  return (
    <div className="container py-8">
      {/* Hero Section */}
      <div className="text-center mb-12">
        <FlaskConical className="h-16 w-16 text-syntropy-600 mx-auto mb-4" />
        <h1 className="text-4xl md:text-5xl font-bold mb-4">Experimental Labs</h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Dive deep into advanced topics with hands-on experiments. Test theories, explore edge cases, and push the
          boundaries of your knowledge.
        </p>
      </div>

      {/* Stats */}
      <div className="grid md:grid-cols-4 gap-6 mb-12">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Labs</CardTitle>
            <FlaskConical className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{labs.filter((lab) => lab.status === "available").length}</div>
            <p className="text-xs text-muted-foreground">Ready to explore</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Coming Soon</CardTitle>
            <Zap className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{labs.filter((lab) => lab.status === "coming-soon").length}</div>
            <p className="text-xs text-muted-foreground">In development</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Categories</CardTitle>
            <Cpu className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{categories.length - 1}</div>
            <p className="text-xs text-muted-foreground">Different focus areas</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Avg Duration</CardTitle>
            <Globe className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">50m</div>
            <p className="text-xs text-muted-foreground">Per lab session</p>
          </CardContent>
        </Card>
      </div>

      {/* Category Filter */}
      <div className="flex flex-wrap gap-2 mb-8">
        {categories.map((category) => (
          <Button key={category} variant={category === "All" ? "default" : "outline"} size="sm">
            {category}
          </Button>
        ))}
      </div>

      {/* Labs Grid */}
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {labs.map((lab) => {
          const Icon = lab.icon
          return (
            <Card key={lab.id} className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-syntropy-100 dark:bg-syntropy-900 rounded-lg">
                      <Icon className="h-5 w-5 text-syntropy-600" />
                    </div>
                    <div>
                      <Badge variant="secondary" className="mb-1">
                        {lab.category}
                      </Badge>
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <span>{lab.difficulty}</span>
                        <span>•</span>
                        <span>{lab.duration}</span>
                      </div>
                    </div>
                  </div>
                  {lab.status === "coming-soon" && <Badge variant="outline">Coming Soon</Badge>}
                </div>
                <CardTitle className="line-clamp-2">{lab.title}</CardTitle>
                <CardDescription className="line-clamp-3">{lab.description}</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex flex-wrap gap-1">
                    {lab.technologies.map((tech) => (
                      <Badge key={tech} variant="outline" className="text-xs">
                        {tech}
                      </Badge>
                    ))}
                  </div>

                  <Button className="w-full" disabled={lab.status === "coming-soon"}>
                    {lab.status === "coming-soon" ? "Coming Soon" : "Start Lab"}
                  </Button>
                </div>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Info Section */}
      <div className="mt-16 bg-muted/50 rounded-lg p-8">
        <div className="text-center mb-8">
          <h2 className="text-2xl font-bold mb-4">How Labs Work</h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            Labs provide isolated environments where you can experiment with advanced concepts without affecting your
            main projects.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          <div className="text-center">
            <div className="w-12 h-12 bg-syntropy-100 dark:bg-syntropy-900 rounded-lg flex items-center justify-center mx-auto mb-4">
              <FlaskConical className="h-6 w-6 text-syntropy-600" />
            </div>
            <h3 className="font-semibold mb-2">Isolated Environment</h3>
            <p className="text-sm text-muted-foreground">
              Each lab runs in a sandboxed environment with pre-configured tools and dependencies.
            </p>
          </div>
          <div className="text-center">
            <div className="w-12 h-12 bg-syntropy-100 dark:bg-syntropy-900 rounded-lg flex items-center justify-center mx-auto mb-4">
              <Zap className="h-6 w-6 text-syntropy-600" />
            </div>
            <h3 className="font-semibold mb-2">Real-time Results</h3>
            <p className="text-sm text-muted-foreground">
              See immediate feedback and results as you experiment with different approaches.
            </p>
          </div>
          <div className="text-center">
            <div className="w-12 h-12 bg-syntropy-100 dark:bg-syntropy-900 rounded-lg flex items-center justify-center mx-auto mb-4">
              <Cpu className="h-6 w-6 text-syntropy-600" />
            </div>
            <h3 className="font-semibold mb-2">Advanced Topics</h3>
            <p className="text-sm text-muted-foreground">
              Explore cutting-edge technologies and advanced concepts in a guided environment.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
