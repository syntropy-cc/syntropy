"use client"

import { render, screen, fireEvent, waitFor } from "@testing-library/react"
import { CourseIDE } from "@/components/syntropy/CourseIDE"

// Mock Monaco Editor
jest.mock("@monaco-editor/react", () => ({
  Editor: ({ onChange, value }: any) => (
    <textarea data-testid="monaco-editor" value={value} onChange={(e) => onChange?.(e.target.value)} />
  ),
}))

describe("CourseIDE", () => {
  it("renders with default code", () => {
    render(<CourseIDE />)

    expect(screen.getByText("Code Editor")).toBeInTheDocument()
    expect(screen.getByTestId("monaco-editor")).toHaveValue('// Start coding here...\nconsole.log("Hello, Syntropy!");')
  })

  it("renders with custom initial code", () => {
    const customCode = 'console.log("Custom code");'
    render(<CourseIDE initialCode={customCode} />)

    expect(screen.getByTestId("monaco-editor")).toHaveValue(customCode)
  })

  it("has run button that executes code", async () => {
    render(<CourseIDE />)

    const runButton = screen.getByText("Run")
    expect(runButton).toBeInTheDocument()

    fireEvent.click(runButton)

    expect(screen.getByText("Running...")).toBeInTheDocument()

    await waitFor(
      () => {
        expect(screen.getByText("Run")).toBeInTheDocument()
      },
      { timeout: 2000 },
    )
  })

  it("has reset button that restores initial code", () => {
    const initialCode = 'console.log("initial");'
    render(<CourseIDE initialCode={initialCode} />)

    const editor = screen.getByTestId("monaco-editor")
    fireEvent.change(editor, { target: { value: 'console.log("changed");' } })

    const resetButton = screen.getByText("Reset")
    fireEvent.click(resetButton)

    expect(editor).toHaveValue(initialCode)
  })

  it("has download button", () => {
    render(<CourseIDE />)

    expect(screen.getByText("Download")).toBeInTheDocument()
  })

  it("shows editor and output tabs", () => {
    render(<CourseIDE />)

    expect(screen.getByText("Editor")).toBeInTheDocument()
    expect(screen.getByText("Output")).toBeInTheDocument()
  })

  it("disables run button when readOnly is true", () => {
    render(<CourseIDE readOnly />)

    const runButton = screen.getByText("Run")
    expect(runButton).toBeDisabled()
  })

  it("supports different programming languages", () => {
    render(<CourseIDE language="python" />)

    // The language prop should be passed to Monaco Editor
    // This test verifies the component accepts the prop
    expect(screen.getByTestId("monaco-editor")).toBeInTheDocument()
  })
})
