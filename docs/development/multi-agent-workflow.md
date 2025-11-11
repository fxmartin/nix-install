# ABOUTME: Multi-agent development workflow documentation for nix-install project
# ABOUTME: Describes agent selection strategy, benefits, and usage patterns

## Multi-Agent Development Workflow

### Overview
Stories are implemented using specialized Claude Code agents for optimal results. Each agent brings domain expertise while maintaining code consistency through the senior-code-reviewer gate.

### Available Agents
- **bash-zsh-macos-engineer**: Shell scripting, automation, macOS system tasks
- **senior-code-reviewer**: Code quality, security, architecture review
- **python-backend-engineer**: Python services, data processing
- **ui-engineer**: Frontend components, user experience
- **backend-typescript-architect**: TypeScript APIs, system design
- **qa-expert**: Test strategy, quality assurance
- **podman-container-architect**: Containerization, orchestration

### Agent Selection Strategy
1. **Story Analysis**: Determine primary technology and complexity
2. **Primary Agent**: Select specialist matching story requirements
3. **Supporting Agents**: Add reviewers and cross-domain specialists
4. **Quality Gate**: senior-code-reviewer validates all implementations

### Workflow Example (Story 01.2-002)
```
1. bash-zsh-macos-engineer: Implementation (6 functions, 96 tests)
2. senior-code-reviewer: Code review (security, quality, architecture)
3. bash-zsh-macos-engineer: Bug fix (test syntax error)
4. FX: Manual VM testing and merge
```

### Agent Benefits
- **Specialized Expertise**: Each agent optimized for specific technologies
- **Code Quality**: Mandatory senior review before merge
- **Parallel Execution**: Multiple agents can work independently
- **Knowledge Continuity**: Agents share context across stories

### Using Multi-Agent Workflow
```bash
# Resume development with agent auto-selection
/resume-build-agents next

# Continue specific story
/resume-build-agents 01.2-003

# Specify agent manually (override auto-selection)
/resume-build-agents 01.2-003 --agent bash-zsh-macos-engineer
```

---

