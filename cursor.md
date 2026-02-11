# Cursor project instructions

## Versioning & new features (do this by default)

When creating or adding a **new feature**, always use this Git workflow so the current version stays safe and you can return to it.

### Before starting a new feature

1. **Ensure the baseline is saved** (if not already done):
   ```bash
   git status   # ensure working tree is clean
   git tag -a v1.0-baseline -m "Stable version before new features"   # only if you haven't tagged yet
   ```

2. **Create a feature branch** (do this at the start of every new feature):
   ```bash
   git checkout -b feature/short-feature-name
   ```
   Use a clear branch name, e.g. `feature/dark-mode`, `feature/export-azkar`, `feature/notifications`.

3. **Do all work for that feature on the branch** — edit files, commit often:
   ```bash
   git add .
   git commit -m "Describe what you did"
   ```

### When the feature is done

- Merge to main when ready: `git checkout main && git merge feature/short-feature-name`
- Or keep experimenting on the branch; `main` (or your previous tag) stays unchanged.

### Going back to the version before the feature

- Switch back to main: `git checkout main`
- Or restore from a tag: `git checkout v1.0-baseline` or `git checkout -b recovery v1.0-baseline`

### One-time setup (if the repo is new)

```bash
git init
git add .
git commit -m "Initial version - baseline before new features"
git tag -a v1.0 -m "Baseline"
```

---

**Summary:** When the user asks to create or add a new feature, first create/use a feature branch (e.g. `feature/…`) and do the work there, so the current version on `main` (or the last tag) is never lost.
