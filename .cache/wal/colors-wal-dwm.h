static const char norm_fg[] = "#c3c5c4";
static const char norm_bg[] = "#292e42";
static const char norm_border[] = "#1e2127";

static const char sel_fg[] = "#0e1616";
static const char sel_bg[] = "#1d7c78";
static const char sel_border[] = "#1d7c78";

static const char urg_fg[] = "#c3c5c4";
static const char urg_bg[] = "#ff0000";
static const char urg_border[] = "#ffff00";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};

