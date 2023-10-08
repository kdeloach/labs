package main

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"log"

	"github.com/gomarkdown/markdown"
	"gopkg.in/yaml.v2"
)

type Site struct {
	Pages      []*Page
	PagesByTag map[string][]*Page
}

type Page struct {
	*Frontmatter
	Path     string
	Dir      string
	Markdown string
	Content  template.HTML

	// To access Site object on page template conveniently
	Site *Site
}

type Frontmatter struct {
	Title     string    `yaml:"title"`
	Date      time.Time `yaml:"date"`
	Templates []string  `yaml:"templates"`
	Tags      []string  `yaml:"tags"`
}

func main() {
	rootDir := "."

	if len(os.Args) > 1 {
		rootDir = os.Args[1]
	}

	site := &Site{}
	site.Pages = []*Page{}
	site.PagesByTag = map[string][]*Page{}

	processMarkdownFile := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("Error accessing file %s: %w", path, err)
		}

		if !info.IsDir() && strings.HasSuffix(path, ".md") {
			content, err := ioutil.ReadFile(path)
			if err != nil {
				return fmt.Errorf("Error reading file %s: %w", path, err)
			}

			parts := strings.SplitN(string(content), "---", 3)
			if len(parts) < 3 {
				log.Printf("Warning: Skipping file %s: No valid frontmatter found", path)
				return nil
			}

			var frontmatter Frontmatter
			if err := yaml.Unmarshal([]byte(parts[1]), &frontmatter); err != nil {
				log.Printf("Warning: Error parsing YAML in file %s: %v", path, err)
				return nil
			}

			page := &Page{
				Frontmatter: &frontmatter,
				Path:        path,
				Dir:         filepath.Dir(path),
				Site:        site,
				Markdown:    parts[2],
			}
			site.Pages = append(site.Pages, page)

			for _, tag := range frontmatter.Tags {
				site.PagesByTag[tag] = append(site.PagesByTag[tag], page)
			}
		}
		return nil
	}

	renderPage := func(page *Page) error {
		if len(page.Frontmatter.Templates) == 0 {
			return fmt.Errorf("Templates field is missing in frontmatter in file %s", page.Path)
		}

		// First template in frontmatter should be the base template.
		baseTemplate := filepath.Base(page.Frontmatter.Templates[0])

		tmpl, err := template.New("").Funcs(template.FuncMap{
			"Now":     now,
			"Include": makeIncludeFunc(page.Path, page),
		}).ParseFiles(page.Frontmatter.Templates...)
		if err != nil {
			return fmt.Errorf("Error parsing templates in file %s: %w", page.Path, err)
		}

		htmlContent := markdown.ToHTML([]byte(page.Markdown), nil, nil)
		page.Content = template.HTML(htmlContent)

		var htmlBuffer strings.Builder
		if err := tmpl.ExecuteTemplate(&htmlBuffer, baseTemplate, page); err != nil {
			return fmt.Errorf("Error rendering Markdown in file %s: %w", page.Path, err)
		}

		htmlFileName := strings.TrimSuffix(page.Path, ".md") + ".html"
		err = ioutil.WriteFile(htmlFileName, []byte(htmlBuffer.String()), 0644)
		if err != nil {
			return fmt.Errorf("Error writing HTML file %s: %w", htmlFileName, err)
		}

		fmt.Printf("Converted %s to %s\n", page.Path, htmlFileName)

		return nil
	}

	// Process markdown files and populate Site object
	err := filepath.Walk(rootDir, processMarkdownFile)
	if err != nil {
		log.Fatalf("Error processing markdown files: %v", err)
	}

	// Sort PagesByTag by Date
	for _, pages := range site.PagesByTag {
		p := pages
		sort.Slice(p, func(i, j int) bool {
			return p[i].Date.After(p[j].Date)
		})
	}

	// Render markdown files to HTML
	for _, page := range site.Pages {
		err := renderPage(page)
		if err != nil {
			log.Fatalf("Error rendering page: %v", err)
		}
	}
}

func now() time.Time {
	return time.Now()
}

func makeIncludeFunc(path string, page *Page) func(string) (string, error) {
	return func(filename string) (string, error) {
		currentDir := filepath.Dir(path)
		includeFilePath := filepath.Join(currentDir, filename)

		includeContent, err := ioutil.ReadFile(includeFilePath)
		if err != nil {
			return "", fmt.Errorf("Error reading included file %s: %w", includeFilePath, err)
		}

		tmpl, err := template.New("include").Funcs(template.FuncMap{
			"Now":     now,
			"Include": makeIncludeFunc(includeFilePath, page),
		}).Parse(string(includeContent))
		if err != nil {
			return "", fmt.Errorf("Error parsing included file %s: %w", includeFilePath, err)
		}

		var includeBuffer strings.Builder
		if err := tmpl.Execute(&includeBuffer, page); err != nil {
			return "", fmt.Errorf("Error rendering included file %s: %w", includeFilePath, err)
		}

		return includeBuffer.String(), nil
	}
}
