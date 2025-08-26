# Contributing to OpenStack Terraform Alteon

Thank you for your interest in contributing to the OpenStack Terraform Alteon project! This document provides guidelines for contributing to this project.

## 🎯 How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use the issue template** when creating new issues
3. **Provide detailed information** including:
   - OpenStack environment details
   - Terraform version
   - Error messages and logs
   - Steps to reproduce

### Submitting Pull Requests

1. **Fork the repository** and create a feature branch
2. **Follow coding standards** and maintain consistency
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

## 🔧 Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/openstack-terraform-alteon.git
   cd openstack-terraform-alteon
   ```

2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Make your changes and test them

4. Commit your changes:
   ```bash
   git commit -m "Add: descriptive commit message"
   ```

5. Push to your fork and submit a pull request

## 📋 Code Standards

### Terraform Code Style

- Use consistent naming conventions
- Add comments for complex logic
- Use proper resource tags
- Follow security best practices
- Validate configurations with `terraform validate`

### Documentation

- Update README.md for significant changes
- Add inline comments for complex configurations
- Update variable descriptions
- Include examples where helpful

## 🧪 Testing

Before submitting a pull request:

1. **Validate Terraform syntax:**
   ```bash
   terraform validate
   ```

2. **Check formatting:**
   ```bash
   terraform fmt -check
   ```

3. **Test deployment** in a development environment

4. **Verify cleanup** works properly:
   ```bash
   terraform destroy
   ```

## 📝 Commit Message Guidelines

Use clear and descriptive commit messages:

- **Add:** for new features
- **Fix:** for bug fixes
- **Update:** for updates to existing features
- **Remove:** for removing features
- **Docs:** for documentation changes

Example: `Add: Support for custom security group rules`

## 🏷️ Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to docs
- `question` - Further information is requested
- `help wanted` - Extra attention is needed

## 💬 Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Share knowledge and experiences
- Focus on constructive feedback
- Follow the code of conduct

## 🆘 Getting Help

If you need help:

1. Check the documentation and FAQ
2. Search existing issues
3. Ask questions in discussions
4. Contact the maintainers

Thank you for contributing! 🎉
