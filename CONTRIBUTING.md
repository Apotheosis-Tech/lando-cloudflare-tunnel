# Contributing to Lando Cloudflare Tunnel Integration

Thank you for your interest in contributing! This package was born out of real development pain points, and we welcome contributions that help solve similar issues for the community.

## 🎯 How to Contribute

### Reporting Bugs
1. **Check existing issues** first to avoid duplicates
2. **Use the health-check script** to gather diagnostic info
3. **Include system information** (OS, Lando version, cloudflared version)
4. **Provide clear reproduction steps**
5. **Include logs** when possible

### Suggesting Features
1. **Check the roadmap** in CHANGELOG.md
2. **Describe the use case** - what problem does this solve?
3. **Consider implementation** - how might this work?
4. **Think about compatibility** - impact on existing setups

### Contributing Code
1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Test thoroughly** with multiple project types
4. **Update documentation** as needed
5. **Submit a pull request**

## 🧪 Testing Guidelines

### Manual Testing Checklist
Before submitting changes, please test with:

- [ ] Fresh Drupal 10 project
- [ ] Existing WordPress project  
- [ ] Laravel application
- [ ] Node.js/Express app
- [ ] Custom PHP project

### Test Scenarios
- [ ] Clean installation (no existing tunnel)
- [ ] Upgrade scenario (existing tunnel)
- [ ] Port conflict resolution
- [ ] Network connectivity issues
- [ ] OAuth callback functionality
- [ ] Multiple projects running simultaneously

### Automated Testing
```bash
# Run health check
./health-check.sh

# Test all scripts
for script in *.sh; do
    echo "Testing $script..."
    bash -n "$script" && echo "✅ Syntax OK" || echo "❌ Syntax Error"
done

# Test configuration generation
./setup-domain.sh
# (follow prompts with test data)
```

## 📝 Code Style Guidelines

### Shell Scripts
- Use `#!/bin/bash` (not `sh`)
- Always use `set -e` for error handling
- Quote variables: `"$VARIABLE"`
- Use meaningful variable names
- Add comments for complex logic
- Include configuration section at top
- Provide user feedback (echo statements)

### Documentation
- Use clear, concise language
- Include practical examples
- Test all documented commands
- Update README.md for new features
- Add troubleshooting entries for known issues

## 🗂️ Project Structure

```
lando-cloudflare-tunnel/
├── README.md                    # Main documentation
├── LICENSE                      # MIT license
├── CHANGELOG.md                 # Version history
├── CONTRIBUTING.md              # This file
├── TROUBLESHOOTING.md           # Common issues
├── LANDO_EXAMPLES.md            # .lando.yml examples
├── install.sh                   # Package overview
├── smart-start.sh               # Interactive starter
├── start-background.sh          # Background runner
├── stop-tunnel.sh               # Clean shutdown
├── tunnel-status.sh             # Status checking
├── health-check.sh              # Comprehensive testing
├── setup-domain.sh              # Interactive config
├── drupal-settings-example.php  # Drupal integration
└── config-example.yml           # Tunnel config template
```

## 🔄 Development Workflow

### Setting Up Development Environment
1. Clone the repository
2. Create a test Lando project
3. Copy scripts to the test project
4. Run `./setup-domain.sh` with test domain
5. Test functionality

### Making Changes
1. **Small changes**: Edit directly and test
2. **Large changes**: Create feature branch
3. **New features**: Update documentation
4. **Bug fixes**: Add test case to prevent regression

### Before Submitting
- [ ] Test with multiple project types
- [ ] Run health-check.sh successfully
- [ ] Update relevant documentation
- [ ] Check for breaking changes
- [ ] Verify all scripts are executable

## 📚 Documentation Standards

### README Updates
- Keep quick start section concise
- Add new features to feature list
- Update requirements if needed
- Include practical examples

### Code Comments
```bash
# Good: Explains why
# Check if tunnel exists because cloudflared create fails if it already exists

# Bad: Explains what (obvious from code)
# Set tunnel name variable
TUNNEL_NAME="my-tunnel"
```

### Troubleshooting Entries
Include for new features:
- Common error messages
- Step-by-step solutions
- Related commands
- When to use work-arounds

## 🌟 Feature Ideas We'd Love to See

### High Priority
- **Multi-domain support** - One tunnel, multiple domains
- **Docker Compose integration** - Beyond just Lando
- **Windows native support** - Without WSL requirement
- **Configuration validation** - Check setup before starting

### Medium Priority  
- **Monitoring dashboard** - Web UI for tunnel status
- **Team sync tools** - Share configurations easily
- **CI/CD examples** - GitHub Actions, GitLab CI
- **Performance optimization** - Faster startup times

### Nice to Have
- **Plugin system** - Extensible architecture
- **Auto-updates** - Keep scripts current
- **Usage analytics** - Anonymous usage stats
- **Integration guides** - More frameworks

## 🤝 Community Guidelines

### Be Helpful
- Assume good intentions
- Provide constructive feedback
- Share knowledge generously
- Help newcomers get started

### Be Respectful
- Use inclusive language
- Respect different perspectives
- Keep discussions professional
- Focus on technical merit

### Be Collaborative
- Credit others' contributions
- Build on existing work
- Share early and often
- Document decisions

## 🎉 Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Credited in release notes
- Added to GitHub contributors
- Mentioned in documentation where relevant

## 📧 Contact

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Security**: Email maintainers privately
- **General**: Lando Slack workspace

---

Thank you for helping make local development better for everyone! 🚀

*Remember: The best contribution is the one that solves a real problem you've experienced yourself.*
