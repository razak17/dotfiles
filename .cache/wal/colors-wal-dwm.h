static const char norm_fg[] = "#c3c5c4";
static const char norm_bg[] = "#0E1616";
static const char norm_border[] = "#888989";

static const char sel_fg[] = "#c3c5c4";
static const char sel_bg[] = "#556B70";
static const char sel_border[] = "#556B70";

static const char urg_fg[] = "#c3c5c4";
static const char urg_bg[] = "#495458";
static const char urg_border[] = "#495458";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};
