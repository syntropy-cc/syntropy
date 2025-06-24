import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Play, Clock, BookOpen, Award } from "lucide-react"
import Link from "next/link"
import { getCourseSummary } from "@/lib/courses"
import { notFound } from "next/navigation"

export default async function CoursePage({
  params,
}: {
  params: { courseSlug: string }
}) {
  try {
    const course = await getCourseSummary(params.courseSlug)

    return (
      <div className="p-8">
        <div className="max-w-4xl mx-auto">
          {/* Course Header */}
          <div className="mb-8">
            <div className="flex items-center gap-2 mb-4">
              <Badge variant="secondary">{course.level}</Badge>
              <span className="text-sm text-muted-foreground">
                {course.duration} hours • {course.chapters.length} chapters
              </span>
            </div>
            <h1 className="text-4xl font-bold mb-4">{course.title}</h1>
            <p className="text-xl text-muted-foreground mb-6">{course.description}</p>

            <div className="flex items-center gap-4 mb-6">
              <div className="flex items-center gap-2">
                <div className="w-10 h-10 bg-syntropy-600 rounded-full flex items-center justify-center text-white">
                  {course.author.name.charAt(0)}
                </div>
                <div>
                  <p className="font-medium">{course.author.name}</p>
                  <p className="text-sm text-muted-foreground">Course Instructor</p>
                </div>
              </div>
            </div>

            <div className="flex gap-4">
              <Button asChild size="lg">
                <Link href={`/learn/courses/${course.slug}/${course.chapters[0]?.slug}`}>
                  <Play className="mr-2 h-4 w-4" />
                  Start Course
                </Link>
              </Button>
              <Button variant="outline" size="lg">
                <BookOpen className="mr-2 h-4 w-4" />
                Preview
              </Button>
            </div>
          </div>

          {/* Course Stats */}
          <div className="grid md:grid-cols-3 gap-6 mb-8">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Duration</CardTitle>
                <Clock className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{course.duration}h</div>
                <p className="text-xs text-muted-foreground">Self-paced learning</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Chapters</CardTitle>
                <BookOpen className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{course.chapters.length}</div>
                <p className="text-xs text-muted-foreground">Interactive lessons</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Certificate</CardTitle>
                <Award className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">Yes</div>
                <p className="text-xs text-muted-foreground">Upon completion</p>
              </CardContent>
            </Card>
          </div>

          {/* Course Progress */}
          <Card className="mb-8">
            <CardHeader>
              <CardTitle>Your Progress</CardTitle>
              <CardDescription>Track your learning journey through this course</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex justify-between text-sm">
                  <span>Overall Progress</span>
                  <span>0%</span>
                </div>
                <Progress value={0} className="h-2" />
                <p className="text-sm text-muted-foreground">0 of {course.chapters.length} chapters completed</p>
              </div>
            </CardContent>
          </Card>

          {/* What You'll Learn */}
          <Card className="mb-8">
            <CardHeader>
              <CardTitle>What You'll Learn</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2">
                <li className="flex items-start gap-2">
                  <div className="w-2 h-2 bg-syntropy-600 rounded-full mt-2 flex-shrink-0" />
                  <span>Master the fundamentals and advanced concepts</span>
                </li>
                <li className="flex items-start gap-2">
                  <div className="w-2 h-2 bg-syntropy-600 rounded-full mt-2 flex-shrink-0" />
                  <span>Build real-world projects from scratch</span>
                </li>
                <li className="flex items-start gap-2">
                  <div className="w-2 h-2 bg-syntropy-600 rounded-full mt-2 flex-shrink-0" />
                  <span>Apply best practices and industry standards</span>
                </li>
                <li className="flex items-start gap-2">
                  <div className="w-2 h-2 bg-syntropy-600 rounded-full mt-2 flex-shrink-0" />
                  <span>Prepare for real-world development challenges</span>
                </li>
              </ul>
            </CardContent>
          </Card>

          {/* Course Content */}
          <Card>
            <CardHeader>
              <CardTitle>Course Content</CardTitle>
              <CardDescription>
                {course.chapters.length} chapters • {course.duration} hours total
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {course.chapters.map((chapter, index) => (
                  <div key={chapter.id} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center gap-4">
                      <div className="w-8 h-8 bg-muted rounded-full flex items-center justify-center text-sm font-medium">
                        {index + 1}
                      </div>
                      <div>
                        <h3 className="font-medium">{chapter.title}</h3>
                        {chapter.description && <p className="text-sm text-muted-foreground">{chapter.description}</p>}
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {chapter.duration && (
                        <span className="text-sm text-muted-foreground">{chapter.duration} min</span>
                      )}
                      <Button asChild variant="ghost" size="sm">
                        <Link href={`/learn/courses/${course.slug}/${chapter.slug}`}>Preview</Link>
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    )
  } catch (error) {
    notFound()
  }
}
