# Contributing to Entralinked Docker Server

Thank you for your interest in contributing! Here are some guidelines.

## Reporting Issues

- Check existing issues first
- Use the bug report template
- Include Docker version, OS, and error logs
- Include steps to reproduce

## Suggesting Improvements

- Use the feature request template
- Explain the use case
- Describe the expected behavior

## Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test your changes:
   ```bash
   docker compose build
   docker compose up -d
   docker compose logs
   ```
5. Commit with clear messages:
   ```bash
   git commit -m "Add feature: description"
   ```
6. Push to your fork
7. Submit a pull request

## Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing code style
- Test before submitting

## Testing

Before submitting:
- Test on Debian 13 or Ubuntu 24.04
- Verify all ports are exposed
- Check logs for errors
- Test Nintendo DS connection if possible

## Documentation

- Update README.md if adding features
- Update DEPLOY.md if changing deployment process
- Update relevant .md files in docs/

## Questions?

Open an issue with the question tag or check existing documentation.

Thank you for contributing!
