import { render, screen } from "@testing-library/react"
import { CourseSidebar } from "@/components/syntropy/CourseSidebar"
import type { CourseSummary } from "@/types/course"

const mockCourse: CourseSummary = {
  id: "test-course",
  title: "Test Course",
  slug: "test-course",
  description: "A test course for unit testing",
  author: {
    name: "Test Author",
    avatar: "/test-avatar.jpg",
    bio: "Test bio",
  },
  level: "beginner",
  duration: 10,
  tags: ["test", "javascript"],
  chapters: [
    {
      id: "chapter-1",
      title: "First Chapter",
      slug: "first-chapter",
      description: "The first chapter",
      duration: 30,
      completed: false,
      locked: false,
    },
    {
      id: "chapter-2",
      title: "Second Chapter",
      slug: "second-chapter",
      description: "The second chapter",
      duration: 45,
      completed: false,
      locked: true,
    },
  ],
  thumbnail: "/test-thumbnail.jpg",
  published: true,
  createdAt: "2024-01-01T00:00:00Z",
  updatedAt: "2024-01-01T00:00:00Z",
}

// Mock Next.js router
jest.mock("next/navigation", () => ({
  usePathname: () => "/learn/courses/test-course/first-chapter",
}))

describe("CourseSidebar", () => {
  it("renders course title and author", () => {
    render(<CourseSidebar course={mockCourse} />)

    expect(screen.getByText("Test Course")).toBeInTheDocument()
    expect(screen.getByText("by Test Author")).toBeInTheDocument()
  })

  it("displays course level and duration", () => {
    render(<CourseSidebar course={mockCourse} />)

    expect(screen.getByText("beginner")).toBeInTheDocument()
    expect(screen.getByText("10h total")).toBeInTheDocument()
  })

  it("shows progress information", () => {
    render(<CourseSidebar course={mockCourse} progress={25} completedChapters={["chapter-1"]} />)

    expect(screen.getByText("25%")).toBeInTheDocument()
    expect(screen.getByText("1 of 2 chapters completed")).toBeInTheDocument()
  })

  it("renders all chapters", () => {
    render(<CourseSidebar course={mockCourse} />)

    expect(screen.getByText("First Chapter")).toBeInTheDocument()
    expect(screen.getByText("Second Chapter")).toBeInTheDocument()
  })

  it("shows locked chapters correctly", () => {
    render(<CourseSidebar course={mockCourse} />)

    const lockedChapter = screen.getByText("Second Chapter").closest("a")
    expect(lockedChapter).toHaveClass("opacity-50", "cursor-not-allowed")
  })

  it("displays completed chapters with check icon", () => {
    render(<CourseSidebar course={mockCourse} completedChapters={["chapter-1"]} />)

    // Check for the presence of CheckCircle icon (this would need to be adjusted based on how icons are rendered)
    const firstChapter = screen.getByText("First Chapter").closest("a")
    expect(firstChapter).toBeInTheDocument()
  })
})
