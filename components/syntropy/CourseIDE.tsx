"use client"

import { useState, useRef } from "react"
import { Editor } from "@monaco-editor/react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Play, RotateCcw, Download } from "lucide-react"
import { cn } from "@/lib/utils"

interface CourseIDEProps {
  initialCode?: string
  language?: string
  theme?: "vs-dark" | "light"
  readOnly?: boolean
  className?: string
}

export function CourseIDE({
  initialCode = '// Start coding here...\nconsole.log("Hello, Syntropy!");',
  language = "javascript",
  theme = "vs-dark",
  readOnly = false,
  className,
}: CourseIDEProps) {
  const [code, setCode] = useState(initialCode)
  const [output, setOutput] = useState("")
  const [isRunning, setIsRunning] = useState(false)
  const editorRef = useRef<any>(null)

  const handleEditorDidMount = (editor: any) => {
    editorRef.current = editor
  }

  const runCode = async () => {
    setIsRunning(true)
    setOutput("Running...")

    try {
      // Simulate code execution
      await new Promise((resolve) => setTimeout(resolve, 1000))

      // In a real implementation, this would send code to a backend service
      // For demo purposes, we'll just show the code
      setOutput(`Output:\n${code}\n\n// Code executed successfully!`)
    } catch (error) {
      setOutput(`Error: ${error}`)
    } finally {
      setIsRunning(false)
    }
  }

  const resetCode = () => {
    setCode(initialCode)
    setOutput("")
  }

  const downloadCode = () => {
    const blob = new Blob([code], { type: "text/plain" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `code.${language === "javascript" ? "js" : language}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  return (
    <Card className={cn("h-full flex flex-col", className)}>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">Code Editor</CardTitle>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" onClick={resetCode} disabled={isRunning}>
              <RotateCcw className="h-4 w-4 mr-1" />
              Reset
            </Button>
            <Button variant="outline" size="sm" onClick={downloadCode}>
              <Download className="h-4 w-4 mr-1" />
              Download
            </Button>
            <Button size="sm" onClick={runCode} disabled={isRunning || readOnly}>
              <Play className="h-4 w-4 mr-1" />
              {isRunning ? "Running..." : "Run"}
            </Button>
          </div>
        </div>
      </CardHeader>
      <CardContent className="flex-1 p-0">
        <Tabs defaultValue="editor" className="h-full flex flex-col">
          <TabsList className="mx-6 mb-4">
            <TabsTrigger value="editor">Editor</TabsTrigger>
            <TabsTrigger value="output">Output</TabsTrigger>
          </TabsList>

          <TabsContent value="editor" className="flex-1 mx-6 mb-6">
            <div className="h-full border rounded-lg overflow-hidden">
              <Editor
                height="100%"
                language={language}
                theme={theme}
                value={code}
                onChange={(value) => setCode(value || "")}
                onMount={handleEditorDidMount}
                options={{
                  readOnly,
                  minimap: { enabled: false },
                  fontSize: 14,
                  lineNumbers: "on",
                  roundedSelection: false,
                  scrollBeyondLastLine: false,
                  automaticLayout: true,
                  tabSize: 2,
                  wordWrap: "on",
                }}
              />
            </div>
          </TabsContent>

          <TabsContent value="output" className="flex-1 mx-6 mb-6">
            <div className="h-full border rounded-lg p-4 bg-muted/50 font-mono text-sm overflow-auto">
              <pre className="whitespace-pre-wrap">{output || 'Click "Run" to see output here...'}</pre>
            </div>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
}
