# restore-killed

Restore killed buffers and files in Emacs.

## Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Requirements](#requirements)

## Description

This small Emacs package provides commands to undo killing buffers by
maintaining lists of recently killed files and non-file buffers.

For **file buffers**, the package stores the file path so you can reopen
killed files.

For **non-file buffers** (e.g., scratch buffers, temporary buffers), the
package stores both the buffer name and contents (up to a configurable size
limit) so you can restore them with their content intact.

You can restore either the most recently killed buffer/file, or select from
a list using completion.

## Installation

```elisp
(use-package restore-killed
  ;; Load from a local copy
  :load-path "/path/to/restore-killed.el"
  ;; ... or clone from GitHub
  ;; :vc (:url "https://github.com/sonofjon/restore-killed.el"
  ;;          :rev :newest)
  :commands (restore-killed-file
             restore-killed-file-select
             restore-killed-buffer
             restore-killed-buffer-select)
  :config
  ;; Add hooks to track killed buffers
  (add-hook 'kill-buffer-hook #'restore-killed--file-save)
  (add-hook 'kill-buffer-hook #'restore-killed--buffer-save))
```

## Usage

### File buffers

- `M-x restore-killed-file` — Reopen the most recently killed file.
- `M-x restore-killed-file-select` — Choose which killed file to reopen
  from a list.

### Non-file buffers

- `M-x restore-killed-buffer` — Restore the most recently killed non-file
  buffer.
- `M-x restore-killed-buffer-select` — Choose which killed buffer to
  restore from a list.

## Configuration

The package provides several customizable variables:

- `restore-killed-file-max` (default: 10)
  Maximum number of killed files to store.

- `restore-killed-buffer-max` (default: 10)
  Maximum number of killed non-file buffers to store.

- `restore-killed-buffer-max-size` (default: 10000)
  Maximum size of non-file buffer (in characters) to store.  Buffers
  larger than this will not be saved.

Example:

```elisp
(setq restore-killed-file-max 5
      restore-killed-buffer-max 15
      restore-killed-buffer-max-size 20000)
```

## Requirements

- Emacs 26.1 or newer
