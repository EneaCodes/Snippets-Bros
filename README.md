# Snippets Bros
- Professional **WordPress snippet manager** that lets you manage PHP, JavaScript, CSS and HTML from a clean, modern admin UI – without editing theme files.

## Screenshots

<p align="center">
  <img src="Screenshots/Screenshot-1.png" width="50%" />
</p>

![Screenshot 2](Screenshots/Screenshot-2.png)

![Screenshot 3](Screenshots/Screenshot-3.png)

![Screenshot 4](Screenshots/Screenshot-4.png)

## Features
- Manage snippets by type: **PHP, JS, CSS, HTML**.
- Enable/disable, clone, categorize and tag snippets.
- Global **Header** and **Footer** code blocks for site-wide injections.
- **Run-once** snippets that automatically disable after first execution.
- Execution priority control per snippet.
- Detailed **per-snippet error log** and status indicators.
- **Revision history** (up to 15 revisions per snippet).
- Powerful search, filters, categories and tags for organizing snippets.
- Modern, responsive dashboard UI (no custom post types).

### Conditional Loading & Locations
- Run snippets:
  - **Everywhere**
  - **Frontend only**
  - **Admin only**
  - **Shortcode only**
  - **Header** / **Footer**
- Advanced conditions:
  - URL rules: one rule per line `/`, `/blog`, `/contact`, `/games`, etc.).
  - Multiple locations per snippet (e.g. `/blog` **and** `/contact` **and** `/games`).
  - Basic user rules: logged-in / logged-out.
  - Device-style rules (e.g. desktop vs mobile targeting, depending on config).

---

## Security, Safe Mode & Sanitization
Snippets Bros is built with multiple safety layers:
- **Safe Mode toggle**: instantly stop all PHP snippets without deactivating the plugin.
- **Crash shield** logic to help keep the admin accessible if a snippet causes a fatal error.
- **Dangerous PHP protection**:
  - Detects and blocks or warns on functions commonly abused in exploits, such as:
    - `eval`, `assert`, `create_function`, `shell_exec`, `system`, `exec`,
      `passthru`, `popen`, `proc_open`, `base64_decode` patterns, etc.
- **Strict sanitization & escaping**:
  - All titles, descriptions, locations, settings and UI fields are sanitized.
  - Outputs are properly escaped following WordPress coding standards.
- **Capability checks**:
  - Only users with appropriate manage permissions (e.g. administrators) can add, edit or run snippets.

These protections reduce risk, but **cannot make unsafe code safe**. Always test carefully.

---

## Installation
1. Upload the `snippets-bros` plugin folder to `/wp-content/plugins/`.
2. Activate it from **Plugins → Installed Plugins**.
3. Go to **Snippets Bros** in the admin menu and start adding snippets.

> ✅ Tip: Make sure the folder inside `wp-content/plugins/` is named exactly `snippets-bros`.

## Support / Donate
If you find Snippets Bros useful, you can support development here:  
👉 https://ko-fi.com/W7W51P4XY6

## License
Released under the GPL v2 license.
