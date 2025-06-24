#!/usr/bin/env node

const fs = require("fs").promises
const path = require("path")

/**
 * Script to convert existing Markdown files to MDX format
 * This helps migrate content from the original repository structure
 */

async function convertMarkdownToMdx(filePath) {
  try {
    const content = await fs.readFile(filePath, "utf-8")

    // Basic conversions for MDX compatibility
    const mdxContent = content
      // Convert code blocks to CodeBlock components where appropriate
      .replace(/```(\w+)\n([\s\S]*?)```/g, (match, lang, code) => {
        if (lang === "javascript" || lang === "js" || lang === "jsx" || lang === "tsx") {
          return `<CodeBlock language="${lang}">\n${code.trim()}\n</CodeBlock>`
        }
        return match
      })
      // Convert info/warning blocks to Alert components
      .replace(/> \*\*Info:\*\* (.*)/g, '<Alert type="info">$1</Alert>')
      .replace(/> \*\*Warning:\*\* (.*)/g, '<Alert type="warning">$1</Alert>')
      .replace(/> \*\*Error:\*\* (.*)/g, '<Alert type="error">$1</Alert>')

    return mdxContent
  } catch (error) {
    console.error(`Error converting ${filePath}:`, error.message)
    return null
  }
}

async function syncMdxFiles() {
  const contentDir = path.join(__dirname, "..", "content", "courses")

  try {
    const courses = await fs.readdir(contentDir)

    for (const courseDir of courses) {
      const coursePath = path.join(contentDir, courseDir)
      const stat = await fs.stat(coursePath)

      if (stat.isDirectory()) {
        console.log(`Processing course: ${courseDir}`)

        try {
          const files = await fs.readdir(coursePath)

          for (const file of files) {
            if (file.endsWith(".md") && !file.endsWith(".mdx")) {
              const mdPath = path.join(coursePath, file)
              const mdxPath = path.join(coursePath, file.replace(".md", ".mdx"))

              console.log(`Converting ${file} to MDX...`)

              const mdxContent = await convertMarkdownToMdx(mdPath)
              if (mdxContent) {
                await fs.writeFile(mdxPath, mdxContent)
                console.log(`✓ Created ${file.replace(".md", ".mdx")}`)

                // Optionally remove the original .md file
                // await fs.unlink(mdPath);
              }
            }
          }
        } catch (error) {
          console.error(`Error processing course ${courseDir}:`, error.message)
        }
      }
    }

    console.log("\n✅ MDX sync completed!")
  } catch (error) {
    console.error("Error syncing MDX files:", error.message)
    process.exit(1)
  }
}

// Run the script
if (require.main === module) {
  syncMdxFiles()
}

module.exports = { convertMarkdownToMdx, syncMdxFiles }
