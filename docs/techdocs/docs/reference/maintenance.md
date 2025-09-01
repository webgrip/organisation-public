# Maintenance

This guide explains how to maintain and update the TechDocs site for the WebGrip Organisation Public repository.

## TechDocs Architecture

### Site Structure

The TechDocs site follows a **platform-centric information architecture** that reflects the repository's primary purpose as an organizational infrastructure foundation:

```
docs/techdocs/
├── mkdocs.yml           # Site configuration and navigation
├── docs/                # Documentation pages
│   ├── index.md        # Landing page
│   ├── overview/       # Project overview and getting started
│   ├── platform/       # Infrastructure and architecture
│   ├── operations/     # CI/CD, deployment, and tools
│   ├── catalog/        # Backstage catalog structure
│   ├── development/    # Local setup and contributing
│   ├── adrs/          # ADR integration and overview
│   └── reference/     # Glossary, troubleshooting, maintenance
└── overrides/          # Theme customizations
```

### Navigation Mapping

The navigation structure maps directly to repository seams and operational boundaries:

| Section | Repository Mapping | Purpose |
|---------|-------------------|---------|
| **Overview** | Root files, README | Project introduction and getting started |
| **Platform Architecture** | `ops/helm/`, cluster configs | Infrastructure components and dependencies |
| **Operations** | `.github/workflows/`, `Makefile` | CI/CD workflows and operational procedures |
| **Catalog Structure** | `catalog/` directory | Backstage entities and service discovery |
| **Development** | Contributing workflows | Local setup and contribution guidelines |
| **ADRs** | `docs/adrs/` | Architectural decisions and rationale |
| **Reference** | Cross-cutting concerns | Glossary, troubleshooting, and maintenance |

## Content Maintenance

### Adding New Pages

**Within Existing Sections**:
1. Create the new `.md` file in the appropriate directory
2. Add the page to `nav:` section in `mkdocs.yml`
3. Update cross-references from related pages
4. Test the build locally

**New Sections**:
1. Create new directory under `docs/`
2. Add section to `nav:` in `mkdocs.yml`  
3. Create index page for the section
4. Update landing page with section reference

### Updating Existing Content

**Regular Updates**:
- **Links**: Verify all relative links still work after repository changes
- **Versions**: Update version numbers for platform components
- **Commands**: Validate operational commands and examples
- **Diagrams**: Update Mermaid diagrams to reflect current architecture

**Triggered Updates**:
- **Infrastructure Changes**: Update platform architecture pages
- **New Components**: Add to catalog structure documentation
- **Workflow Changes**: Update operations and CI/CD documentation
- **ADR Additions**: Update ADR index and cross-references

### Content Guidelines

**Linking Strategy**:
- Use relative links to repository files: `[file](../../path/to/file)`
- Cross-reference related documentation pages
- Link to line numbers for specific code references
- Include anchors for long pages: `[section](page.md#section)`

**Assumption Handling**:
- Mark inferences with `> Assumption:` blocks
- Propose validation steps for uncertain statements
- Update assumptions based on validation results
- Document assumption resolution in revision notes

**Source Citations**:
- Link every non-trivial claim to source files
- Use relative paths for repository references
- Include line numbers for specific code examples
- Cite external sources with full URLs

## Diagram Management

### Mermaid Diagrams

All diagrams are text-based using Mermaid syntax for easy maintenance:

**Architecture Diagrams**:
- Keep diagrams focused on specific architectural views
- Update component names to match repository changes
- Validate diagram syntax with Mermaid Live Editor

**Flow Diagrams**:
- Document operational workflows and processes
- Update process flows when procedures change
- Include decision points and error handling

**Relationship Diagrams**:
- Show dependencies between components and systems
- Update when new services or dependencies are added
- Maintain consistency with Backstage catalog structure

### Diagram Update Process

1. **Identify Changes**: Monitor repository for architectural changes
2. **Update Diagrams**: Modify Mermaid syntax to reflect changes
3. **Validate Rendering**: Test diagram rendering in MkDocs
4. **Review Accuracy**: Ensure diagrams match current state
5. **Update References**: Update any documentation referencing the diagrams

## Build and Deployment

### Local Testing

**Prerequisites**:
```bash
pip install mkdocs-material
pip install mkdocs-techdocs-core
```

**Build Commands**:
```bash
# Navigate to TechDocs directory
cd docs/techdocs

# Serve locally (auto-reload)
mkdocs serve

# Build static site
mkdocs build

# Validate links and structure
mkdocs build --strict
```

### Automated Deployment

**GitHub Actions Workflow**: [on_docs_change.yml](../../.github/workflows/on_docs_change.yml)

**Trigger Conditions**:
- Push to `main` branch with changes in `docs/techdocs/**`
- Manual workflow dispatch
- Changes to the workflow file itself

**Deployment Process**:
1. **Generate**: Uses `webgrip/workflows/.github/workflows/techdocs-generate.yml@main`
2. **Deploy**: Uses `webgrip/workflows/.github/workflows/techdocs-deploy-gh-pages.yml@main`
3. **Publish**: Site published to GitHub Pages

### Backstage Integration

**Configuration**: [catalog-info.yaml](../../catalog-info.yaml)
```yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:./docs/techdocs
```

**Build Process**:
- Backstage automatically builds TechDocs from repository
- Updates appear in Backstage after repository changes
- No manual intervention required for Backstage deployment

## Quality Assurance

### Link Validation

**Automated Checks**:
- MkDocs build process validates internal links
- Strict mode fails build on broken links
- GitHub Actions workflow includes link validation

**Manual Validation**:
```bash
# Check all links in documentation
find docs/techdocs/docs -name "*.md" -exec grep -l "](../../" {} \;

# Validate specific links
cat docs/techdocs/docs/path/to/page.md | grep -o "](../../[^)]*"
```

### Content Review

**Regular Reviews** (Quarterly):
- Verify accuracy of all technical content
- Update version numbers and configuration examples
- Validate command examples and procedures
- Review and update diagrams

**Change-Triggered Reviews**:
- Infrastructure changes require platform documentation updates
- New workflows require operations documentation updates
- Catalog changes require catalog structure updates
- ADR additions require ADR section updates

### Build Validation

**Local Validation**:
```bash
# Strict build (fail on warnings)
mkdocs build --strict

# Check for common issues
grep -r "TODO\|FIXME\|XXX" docs/techdocs/docs/

# Validate Mermaid syntax
grep -A 10 -B 2 "```mermaid" docs/techdocs/docs/
```

**CI Validation**:
- Automated build testing in GitHub Actions
- Link checking and validation
- Mermaid diagram syntax validation
- TechDocs compatibility testing

## Troubleshooting

### Common Issues

**Build Failures**:
```bash
# Check MkDocs configuration
mkdocs config

# Validate YAML syntax
python -c "import yaml; yaml.safe_load(open('mkdocs.yml'))"

# Test individual pages
mkdocs serve --dev-addr 127.0.0.1:8001
```

**Broken Links**:
```bash
# Find broken repository links
find . -name "*.md" -exec grep -l "](../../" {} \; | \
  xargs grep -o "](../../[^)]*" | \
  cut -d']' -f2 | \
  tr -d '()' | \
  while read link; do
    if [ ! -e "$link" ]; then
      echo "Broken link: $link"
    fi
  done
```

**Mermaid Rendering Issues**:
- Validate syntax with [Mermaid Live Editor](https://mermaid.live/)
- Check for unsupported Mermaid features
- Verify Mermaid plugin configuration in `mkdocs.yml`

**Backstage Integration Issues**:
- Verify `backstage.io/techdocs-ref` annotation
- Check TechDocs plugin configuration
- Validate MkDocs compatibility with TechDocs

### Performance Issues

**Large Site Build Times**:
- Review and optimize large diagrams
- Consider splitting large pages into smaller sections
- Optimize image sizes and formats
- Use lazy loading for heavy content

**Slow Page Load**:
- Minimize large code blocks
- Optimize Mermaid diagram complexity
- Review and optimize theme customizations
- Consider content caching strategies

## Maintenance Schedule

### Weekly Tasks
- [ ] Review recent repository changes for documentation impact
- [ ] Update version numbers if platform components updated
- [ ] Validate that new repository files are properly referenced

### Monthly Tasks  
- [ ] Run full link validation across all documentation
- [ ] Review and update Getting Started guide for accuracy
- [ ] Validate operational commands and examples
- [ ] Update any outdated screenshots or examples

### Quarterly Tasks
- [ ] Comprehensive content review and accuracy validation
- [ ] Update architecture diagrams for any infrastructure changes
- [ ] Review and update ADR index and cross-references
- [ ] Validate all assumptions and update based on experience
- [ ] Performance review and optimization

### Annual Tasks
- [ ] Complete information architecture review
- [ ] Technology stack updates (MkDocs, plugins, theme)
- [ ] User feedback collection and analysis
- [ ] Documentation metrics review and improvement planning

## Contributing Updates

### Pull Request Checklist

When updating TechDocs content:

- [ ] **Content Accuracy**: All claims are linked to source files
- [ ] **Link Validation**: All relative links work correctly
- [ ] **Cross-References**: Related pages are properly linked
- [ ] **Assumptions**: Any assumptions are marked and validation proposed
- [ ] **Build Test**: Local build succeeds without errors
- [ ] **Diagram Updates**: Mermaid diagrams render correctly
- [ ] **Navigation**: New pages added to `mkdocs.yml` navigation
- [ ] **Style**: Content follows established conventions

### Maintenance Team Responsibilities

**Primary Maintainers**: Infrastructure Team
- Review and approve documentation updates
- Coordinate with domain experts for technical accuracy
- Manage TechDocs build and deployment issues
- Maintain documentation standards and guidelines

**Content Contributors**: All Team Members
- Update documentation when making repository changes
- Provide domain expertise for technical content
- Report documentation issues and gaps
- Suggest improvements and optimizations

## Next Steps

- **Update Content**: Review and update documentation for recent changes
- **Validate Links**: Run link validation and fix any broken references
- **Review Assumptions**: Validate marked assumptions with domain experts
- **Optimize Performance**: Review build times and page load performance
- **Gather Feedback**: Collect user feedback on documentation effectiveness