=== Snippets Bros ===
Contributors: enos1
Author: Enea
Donate link: https://ko-fi.com/W7W51P4XY6
Author URI: https://github.com/EneaCodes/
Tags: snippet manager, php, javascript, css, html, code snippets
Requires at least: 5.6
Tested up to: 6.9
Requires PHP: 7.4
Stable tag: 1.0.0
License: GPL-2.0-or-later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Professional snippet manager for PHP, HTML, CSS, JS, HEADER, FOOTER with conditions, safe mode, error log, import/export, revisions and more.

== Description ==

Snippets Bros is a professional code-snippet manager for WordPress that lets you safely run PHP, JavaScript, CSS, HTML, HEADER, and FOOTER snippets anywhere on your site without touching theme files.

It is designed to be both powerful and safe: every snippet is validated and sanitized, there is a global Safe Mode switch, an error log with visual indicators, conflict detection, and import/export protections so a broken snippet cannot take down your site.

The interface is a custom dashboard (no custom post types) with filters, search, bulk tools and clear status badges, so you can manage a large number of snippets comfortably.

Made with ❤️ by Enea.

= Key Features =

* PHP, JS, CSS, HTML, HEADER, and FOOTER snippets with separate editors
* Run snippets everywhere, frontend only, admin only, shortcode only, or header/footer
* Smart conditions: URL contains / multiple URL patterns, user status, device type, AND logic
* Safe Mode switch to instantly stop all snippets
* Run once: execute a snippet a single time then auto-disable
* Execution priority (1–100) for fine-grained control
* Visual error indicators and an error log per snippet
* Revision history (up to 15 revisions per snippet)
* Categories and tags for organization
* Clone snippets for quick duplication
* Bulk actions: enable, disable, delete, export
* Import/export with safety checks and size limits (max 10MB)
* Conflict detection for functions, classes, interfaces, traits, and constants
* Keyboard shortcuts for quick editing (Ctrl/Cmd + E) and cloning (Ctrl/Cmd + D)
* Modern, responsive UI with dark-friendly styling
* Ko-fi support box built into the dashboard

= Conditional Loading & Locations =

Run snippets:
* Everywhere
* Frontend only
* Admin only
* Shortcode only (`[snippets_bros id="xOxX52x.XXxXx12"]`)

Advanced conditions:
* URL rules: Multiple URL patterns (one per line), supports contains/exact matching
* Multiple locations per snippet with AND logic (e.g. `/blog` and `/contact` and `/games`)
* Basic user rules: logged-in / logged-out
* Device-style rules (desktop vs mobile targeting)

= Security, Safe Mode & Sanitization =

Snippets Bros is built with multiple safety layers:
* Safe Mode toggle: instantly stop all PHP snippets without deactivating the plugin
* Crash shield logic to help keep the admin accessible if a snippet causes a fatal error
* Conflict detection: Prevents duplicate function, class, interface, trait, and constant declarations
* Automatically disables conflicting snippets before they cause fatal errors
* Dangerous PHP protection: Detects and blocks or warns on functions commonly abused in exploits, such as: eval, assert, create_function, shell_exec, system, exec, passthru, popen, proc_open, base64_decode patterns, etc.
* Strict sanitization & escaping: All titles, descriptions, locations, settings and UI fields are sanitized
* Outputs are properly escaped following WordPress coding standards
* Capability checks: Only users with appropriate manage permissions (e.g. administrators) can add, edit or run snippets

These protections reduce risk, but **cannot make unsafe code safe**. Always test carefully.

== Installation ==

1. Upload the plugin files to the `/wp-content/plugins/snippets-bros` directory, or install it through the WordPress Plugins screen.
2. Activate the plugin through the **Plugins** screen in WordPress.
3. Go to **Snippets Bros** in the admin menu.
4. Click **Add New Snippet**, choose the type (PHP, JS, CSS, HTML, HEADER, FOOTER), set the scope/conditions and save.
5. Use the shortcode, header/footer placement or automatic scope to run your code.

== Usage ==

= Basic Snippet Creation =
1. Navigate to **Snippets Bros** in your WordPress admin menu
2. Click **Add New Snippet**
3. Choose your snippet type (PHP, JS, CSS, HTML, HEADER, or FOOTER)
4. Add your code in the editor
5. Configure scope and conditions
6. Save and enable

= Using Shortcodes =
Add snippets anywhere using shortcodes:
`[snippets_bros id="xOxX52x.XXxXx12"]`

= Keyboard Shortcuts =
* Ctrl/Cmd + E: Quick edit selected snippet
* Ctrl/Cmd + D: Clone selected snippet

= Import/Export =
* Export: Select snippets and use bulk action to export as JSON
* Import: Upload JSON files (max 10MB) to import snippets

== Frequently Asked Questions ==

= Will this conflict with other snippet plugins? =

You should not use two PHP snippet plugins to run the same code. It is safe to keep other plugins installed, but avoid enabling duplicate snippets in more than one plugin at the same time.

= Can I break my site with a PHP snippet? =

Snippets Bros validates code and has a Safe Mode toggle plus an error log, but it is still possible to create fatal errors. Always test new snippets carefully and enable Safe Mode if you need to quickly stop all execution.

= Does it work with block themes and page builders? =

Yes. Snippets run at WordPress level and work with classic themes, block themes and page builders.

= Can I export snippets from one site and import into another? =

Yes, use the built-in export tool to generate a JSON file and import it on another site. The plugin checks the file type, size and content before importing.

= What happens when I deactivate the plugin? =

Safe Mode is automatically enabled and all snippets are disabled to prevent any issues when the plugin is deactivated.

= How do I use the Emergency Recovery mode? =

If a snippet crashes your site, add `?snippets_bros_emergency=1` to your admin URL. This will enable Safe Mode and disable all snippets, allowing you to safely edit or delete the problematic snippet.

== Screenshots ==

1. Main snippet management interface with filters, search, and bulk actions.
2. Snippet editor with code highlighting, scope options, and condition settings.
3. Advanced condition settings with URL patterns, user and device rules.
4. Import/Export tools with safety checks and revision history.

== Changelog ==

= 1.0.0 =
* Initial public release.
* Multiple URL patterns per snippet (one per line).
* Enhanced validation and sanitization for PHP, JS, CSS, HTML, HEADER, and FOOTER snippets.
* Safe Mode switch and visual error indicators.
* Import/export with size limits and security checks (max 10MB).
* Revision history (15 revisions per snippet), bulk actions and shortcode support.
* Conflict detection for functions, classes, interfaces, traits, and constants.
* Automatically disables conflicting snippets before fatal errors.
* Clone feature for quick snippet duplication.
* Keyboard shortcuts (Ctrl/Cmd + E for edit, Ctrl/Cmd + D for clone).
* Modern admin interface with Ko-fi support panel.
* Emergency recovery mode.

== Upgrade Notice ==

= 1.0.0 =
First release of Snippets Bros. Professional snippet manager with advanced safety features, conflict detection, and modern UI.


== Screenshots == 
https://github.com/EneaCodes/Snippets-Bros/tree/main/Screenshots
