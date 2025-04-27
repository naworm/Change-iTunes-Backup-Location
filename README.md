# 📦 Switch Apple Devices Backup Location (Windows)

This PowerShell script automates moving the Apple Devices app (from Microsoft Store) backup folder to a custom location using a symbolic link, while optimizing system performance.

---

## ✨ Features

- Compatible with the official [Apple Devices app](https://apps.microsoft.com/detail/9NP83LWLPZ9K) from Microsoft Store.
- Detects if the symbolic link already exists and is correct — no redundant actions.
- Creates the symbolic link (junction) if needed.
- Adds Windows Search exclusions to avoid unnecessary indexing of backup folders.
- Fallback to Windows Search GUI with clear instructions if automatic exclusion fails.
- Safe handling of existing folders, symlinks, or backups (prompts only when necessary).
- Backups created with iTunes Classic are fully compatible with Apple Devices.

---

## 📂 Default Apple Apps Backup Path

| Application                     | Default Path                                 |
| ------------------------------- | -------------------------------------------- |
| iTunes (Classic Installer)      | `%APPDATA%\Apple Computer\MobileSync\Backup` |
| iTunes (Microsoft Store)        | `%USERPROFILE%\Apple\MobileSync\Backup`      |
| Apple Devices (Microsoft Store) | `%USERPROFILE%\Apple\MobileSync\Backup`      |

---

## 🛠 How the script works

- Reads your desired new backup path from a `config.ini` file.
- Checks if the existing Backup folder:
  - Is already a correct symbolic link → skips re-creation.
  - Is a wrong link → removes and recreates correctly.
  - Is a real folder → asks for confirmation before deleting it.
- Creates a junction from the original backup location to your new location.
- Attempts to add the old and new backup paths to Windows Search exclusions:
  - If exclusions cannot be set automatically, it opens Windows Search settings and provides manual instructions.

---

## ⚡ Requirements

- Run the script as Administrator (required to create symbolic links and modify indexing settings).
- Your new backup path must already exist before running the script.
- PowerShell 5.1 or later is recommended.

---

## 📝 Example `config.ini`

```ini
[Settings]
NewBackupPath=E:\Backups\iPhone Backups
```

Edit the `config.ini` file to set your new preferred backup location.

---

## 🚀 Quick Start

1. Edit `config.ini` to specify your new backup destination.
2. Right-click `switch-apple-devices-to-symlink.ps1` → **Run with PowerShell as Administrator**.
3. If prompted, confirm deletion of old folders (only if necessary).
4. Follow instructions if Windows Search settings are opened manually.
5. Enjoy better organized and safer backups!

---

## 📋 Important Notes

- Deleting the symbolic link will **not delete** your actual backup data.
- **Never delete files** through the symbolic link — only remove the symlink if needed.
- If the Windows Search GUI opens, **manually exclude** both the old and new backup paths.

---


## 🎉 Following

And now you can uninstall iTunes forever!

Enjoy making backups ;)

