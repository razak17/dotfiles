static const char norm_fg[] = "#99a0ae";
static const char norm_bg[] = "#0c0c13";
static const char norm_border[] = "#6b7079";

static const char sel_fg[] = "#99a0ae";
static const char sel_bg[] = "#43425E";
static const char sel_border[] = "#99a0ae";

static const char urg_fg[] = "#99a0ae";
static const char urg_bg[] = "#3D4E64";
static const char urg_border[] = "#3D4E64";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};
