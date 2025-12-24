# Noctalia Shell Fork Update Guide

This guide documents the process for updating the Noctalia shell fork from upstream `noctalia-dev/noctalia-shell` to the latest version.

## Repository Structure

- **Fork**: `ahmet-cetinkaya/dotfiles-noctalia-shell`
- **Upstream**: `noctalia-dev/noctalia-shell`
- **Local Files**: `/home/ac/Configs/quickshell/noctalia-shell` (Btrfs subvolume mount)

## Update Process

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Git installed

### Step-by-Step Procedure

```bash
# 1. Clone fork to temporary location
cd /tmp
rm -rf dotfiles-noctalia-shell
gh repo clone ahmet-cetinkaya/dotfiles-noctalia-shell
cd dotfiles-noctalia-shell

# 2. Verify upstream remote is configured
git remote -v
# Should show:
# origin    git@github.com:ahmet-cetinkaya/dotfiles-noctalia-shell.git (fetch)
# origin    git@github.com:ahmet-cetinkaya/dotfiles-noctalia-shell.git (push)
# upstream  git@github.com:noctalia-dev/noctalia-shell.git (fetch)
# upstream  git@github.com:noctalia-dev/noctalia-shell.git (push)

# 3. Fetch latest from upstream
git fetch upstream --tags

# 4. Check current and target versions
git describe --tags --abbrev=0          # Current version
git describe --tags upstream/main       # Upstream version

# 5. Create backup branch (optional but recommended)
git checkout -b backup-before-vX.Y.Z-update
git checkout main

# 6. Merge upstream/main
git merge upstream/main --no-ff -m "Merge upstream vX.Y.Z into main

Updates from v{old} to v{new} including:
- Bug fixes and new features
- Performance improvements
- Turkish language support preserved
- Custom ahmet-cetinkaya color scheme preserved"

# 7. Resolve merge conflicts if any occur
git status

# Common conflict resolution patterns:
# - For translation files: keep our customizations
# - For README.md: keep fork description, accept upstream changes
# - For custom widgets: may be removed if upstream replaces them

# Mark conflicts as resolved:
git add <resolved-files>

# Complete the merge:
git commit
```

### Handling Common Merge Conflicts

#### 1. Translation Files (`Assets/Translations/en.json`)
```bash
# Keep our version to preserve custom taskbar-grouped settings
git checkout --ours Assets/Translations/en.json
git add Assets/Translations/en.json
```

#### 2. README.md
```bash
# Accept upstream version and re-add custom fork description
git checkout --theirs README.md
# Then manually prepend the custom fork description at the top
```

#### 3. Custom Widgets Removed Upstream
```bash
# If upstream removed our custom widget, accept the deletion
git rm Modules/Bar/Widgets/TaskbarGrouped.qml
git rm Modules/Panels/Settings/Bar/WidgetSettings/TaskbarGroupedSettings.qml
```

#### 4. Nix Files (if we deleted them previously)
```bash
# Accept upstream's Nix support
git add flake.nix nix/home-module.nix nix/nixos-module.nix nix/package.nix shell.nix
```

#### 5. Widget Conflicts (NContextMenu.qml, etc.)
```bash
# Merge both sides: keep our customizations + upstream fixes
# Manually edit to combine changes, then:
git add Widgets/NContextMenu.qml
```

### Step 8: Push to Fork

```bash
git push origin main
```

### Step 9: Sync to Local Directory

```bash
# Sync files from cloned repo to local directory
rsync -av --delete \
  /tmp/dotfiles-noctalia-shell/ \
  /home/ac/Configs/quickshell/noctalia-shell/ \
  --exclude='.git'

# Verify version
grep "baseVersion" /home/ac/Configs/quickshell/noctalia-shell/Services/Noctalia/UpdateService.qml
```

### Step 10: Restart QuickShell

```bash
# Kill existing QuickShell process
pkill quickshell

# Or restart your compositor
# For Hyprland:
hyprctl reload
```

## Verification Checklist

After updating, verify:

- [ ] Version number updated in `UpdateService.qml`
- [ ] QuickShell starts without errors
- [ ] UI renders correctly
- [ ] Turkish translations work
- [ ] Custom `ahmet-cetinkaya` color scheme is available
- [ ] Notification sounds work
- [ ] All bar widgets function properly
- [ ] Settings panel opens and works

## Rollback Procedure

If something goes wrong:

```bash
# From the cloned fork directory
cd /tmp/dotfiles-noctalia-shell
git checkout main
git reset --hard backup-before-vX.Y.Z-update
git push origin main --force

# Re-sync to local directory
rsync -av --delete /tmp/dotfiles-noctalia-shell/ /home/ac/Configs/quickshell/noctalia-shell/ --exclude='.git'
```

## Customizations to Preserve

When updating, ensure these customizations are preserved:

1. **Color Scheme**: `Assets/ColorScheme/ahmet-cetinkaya/ahmet-cetinkaya.json`
2. **Turkish Translations**: `Assets/Translations/tr.json`
3. **Custom Taskbar Settings**: In `Assets/Translations/en.json` (taskbar-grouped section)
4. **Fork Description**: Top section of `README.md`
5. **Shadow Improvements**: In `Widgets/NContextMenu.qml`

## Automated Update Script

Save this as `update-noctalia.sh`:

```bash
#!/bin/bash
set -e

TARGET_VERSION=${1:-"latest"}
WORK_DIR="/tmp/dotfiles-noctalia-shell"
LOCAL_DIR="/home/ac/Configs/quickshell/noctalia-shell"

echo "Updating Noctalia shell fork..."

# Clone or update
if [ -d "$WORK_DIR" ]; then
  cd "$WORK_DIR"
  git fetch origin main
  git checkout main
  git pull origin main
else
  cd /tmp
  gh repo clone ahmet-cetinkaya/dotfiles-noctalia-shell
  cd dotfiles-noctalia-shell
fi

# Fetch upstream
git fetch upstream --tags

# Create backup
git checkout -b "backup-before-$(date +%Y%m%d-%H%M%S)" || true
git checkout main

# Merge
git merge upstream/main --no-ff -m "Merge upstream $(git describe --tags upstream/main) into main"

# Push
git push origin main

# Sync to local
rsync -av --delete "$WORK_DIR/" "$LOCAL_DIR/" --exclude='.git'

# Verify version
VERSION=$(grep "baseVersion" "$LOCAL_DIR/Services/Noctalia/UpdateService.qml" | cut -d'"' -f2)
echo "Updated to version: $VERSION"
echo "Please restart QuickShell to apply changes."
```

Usage:
```bash
chmod +x update-noctalia.sh
./update-noctalia.sh
```

## References

- **Upstream Repository**: https://github.com/noctalia-dev/noctalia-shell
- **Fork Repository**: https://github.com/ahmet-cetinkaya/dotfiles-noctalia-shell
- **Releases**: https://github.com/noctalia-dev/noctalia-shell/releases
- **Documentation**: https://docs.noctalia.dev

## Version History

| Date | Version From | Version To | Notes |
|------|--------------|-------------|-------|
| 2025-12-24 | 3.6.2 | 3.7.5 | Added Labwc support, Desktop Widgets, Hungarian language |
