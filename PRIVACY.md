# Keeping Your Code Private

This guide explains how to keep your Diet App code private and secure.

## Making Your Repository Private

### On GitHub

If your repository is currently public, you can make it private:

1. Go to your repository on GitHub: `https://github.com/Jakeplc/diet-app`
2. Click on **Settings** (tab at the top of the repository page)
3. Scroll down to the **Danger Zone** section at the bottom
4. Click **Change visibility**
5. Select **Make private**
6. Confirm by typing the repository name

**Note**: Private repositories are free on GitHub for unlimited collaborators.

### Repository Visibility Options

- **Public**: Anyone can see your repository. Good for open-source projects.
- **Private**: Only you and people you explicitly share with can access. Good for personal projects or proprietary code.

## Protecting Sensitive Information

### 1. Use .gitignore Properly

The `.gitignore` file is already configured to exclude common build artifacts and system files. **Never commit**:

- API keys or credentials
- Environment variables with sensitive data
- Database files containing user data
- Private keys or certificates

### 2. Environment Variables

For sensitive configuration (API keys, secrets), use environment variables instead of hardcoding:

**DON'T DO THIS:**
```dart
const apiKey = 'your-secret-api-key-here'; // Never hardcode!
```

**DO THIS:**
```dart
// Use environment variables at build time
const apiKey = String.fromEnvironment('API_KEY');
```

Then pass them during build:
```bash
flutter build apk --dart-define=API_KEY=your-secret-key
```

### 3. Secrets in GitHub Actions

If you use GitHub Actions (CI/CD), store secrets properly:

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add your secrets (API keys, tokens, etc.)
4. Reference them in workflows as `${{ secrets.SECRET_NAME }}`

### 4. Check for Accidentally Committed Secrets

Before making your repository public or sharing it, scan for secrets:

```bash
# Check your git history for potential secrets
git log --all --full-history --source -S "password"
git log --all --full-history --source -S "api_key"
```

If you find accidentally committed secrets:
1. **Immediately revoke/rotate** those credentials
2. Remove them from git history (contact GitHub support or use tools like BFG Repo-Cleaner)
3. **Never** just delete them in a new commit - they remain in git history!

## Best Practices for Private Code

### 1. Limit Access

If you need to share your private repository:
- Go to repository **Settings** → **Collaborators**
- Add people by GitHub username
- Grant appropriate permissions (Read, Write, or Admin)

### 2. Use .gitignore for Local Files

Add local-only files to `.gitignore`:

```gitignore
# Personal notes
notes.txt
TODO.md

# Local configuration
.env.local
config.local.dart

# IDE-specific settings (optional)
.vscode/
.idea/
```

### 3. Protect Sensitive Branches

For critical branches (main, production):
1. Go to **Settings** → **Branches**
2. Add branch protection rules
3. Require pull request reviews before merging
4. Prevent force pushes and deletions

### 4. Regular Security Audits

Periodically review:
- Who has access to your repository
- What secrets are stored in GitHub Actions
- Dependencies for known vulnerabilities (`flutter pub outdated`)

## Data Privacy in the Diet App

This app stores data **locally** using Hive:

- All data (food logs, entries, goals) is stored on the user's device only
- No data is sent to external servers
- No analytics or tracking is implemented
- Hive database files are in the app's local storage

**Location of local data:**
- Android: `/data/data/com.example.diet_app/`
- iOS: App's Documents directory
- Desktop: User's application data directory

## Forking vs Cloning

If you want to work on this project:

- **Fork**: Creates your own copy on GitHub (can be made private)
  - Click "Fork" button on the repository page
  - Make your fork private in its Settings
  
- **Clone**: Downloads code to your computer
  ```bash
  git clone https://github.com/Jakeplc/diet-app.git
  ```
  - Your local copy is always private
  - Just don't push to a public repository

## Additional Security Tips

1. **Enable Two-Factor Authentication (2FA)** on your GitHub account
2. **Use SSH keys** instead of HTTPS for git operations
3. **Review permissions** of any third-party GitHub Apps or OAuth apps
4. **Keep dependencies updated** to get security patches
5. **Use branch protection** rules to prevent accidental force pushes

## Summary Checklist

- [ ] Make repository private on GitHub (Settings → Danger Zone → Change visibility)
- [ ] Never commit API keys, passwords, or secrets
- [ ] Use environment variables for configuration
- [ ] Keep `.gitignore` up to date
- [ ] Enable 2FA on GitHub account
- [ ] Limit collaborator access to only necessary people
- [ ] Regularly audit secrets and dependencies
- [ ] Use branch protection for important branches

## Need Help?

- [GitHub Docs: Setting repository visibility](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility)
- [GitHub Docs: Managing access to repositories](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-teams-and-people-with-access-to-your-repository)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security/getting-started/securing-your-repository)
