// HOMEPAGE
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);

/*** [SECTION 9000]: PERSONAL
   Non-project related but useful. If any interest you, add them to your overrides
***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // [FF68+] allow userChrome/userContent

/*** [SECTION 0700]: DNS / DoH / PROXY / SOCKS / IPv6 ***/
user_pref("network.trr.mode", 2);
user_pref("network.trr.custom_uri", "https://doh.libredns.gr/dns-query");
user_pref("network.trr.uri", "https://doh.libredns.gr/dns-query");

// Hardware acceleration
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);
user_pref("layers.acceleration.disabled", true);

user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("extensions.pocket.enabled", false); // Pocket Account [FF46+]

user_pref("full-screen-api.warning.delay", 0);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("sidebar.position_start", false);

/* 1212: set OCSP fetch failures (non-stapled, see 1211) to hard-fail [SETUP-WEB]
 * When a CA cannot be reached to validate a cert, Firefox just continues the connection (=soft-fail)
 * Setting this pref to true tells Firefox to instead terminate the connection (=hard-fail)
 * It is pointless to soft-fail when an OCSP fetch fails: you cannot confirm a cert is still valid (it
 * could have been revoked) and/or you could be under attack (e.g. malicious blocking of OCSP servers)
 ***/
user_pref("security.OCSP.require", false);