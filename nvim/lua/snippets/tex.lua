local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
return {
  s("im", {
    t("$"), i(1), t("$"), i(0)
  }),
  s("dm", {
    t("\\["), i(1), t("\\]"), i(0)
  }),
  s("frac", {
    t("\\frac{"), i(1), t("}{"), i(2), t("}"), i(0)
  }),
  s("eq", {
    t({ "\\begin{equation}", "\t" }), i(1), t({ "", "\\end{equation}" }), i(0)
  }),
  s("align", {
    t({ "\\begin{align}", "\t" }), i(1), t({ "", "\\end{align}" }), i(0)
  }),
  s("case", {
    t({ "\\begin{cases}", "\t" }), i(1), t(" & "), i(2), t(" \\\\"), i(0), t({ "", "\\end{cases}" })
  }),

  s("document", {
    t({ "\\documentclass{article}",
      "\\usepackage[utf8]{inputenc}",
      "\\usepackage[T1]{fontenc}",
      "\\usepackage{amsmath}",
      "\\usepackage{amsfonts}",
      "\\usepackage{amssymb}",
      "\\usepackage{graphicx}",
      "\\usepackage{hyperref}",
      "",
      "\\title{" }), i(1, "Title"), t({ "}",
    "\\author{" }), i(2, "Author"), t({ "}",
    "\\date{" }), i(3, "\\today"), t({ "}",
    "",
    "\\begin{document}",
    "",
    "\\maketitle",
    "" }), i(4, "Content goes here"), t({ "",
    "\\end{document}" })
  }),
  s("sec", {
    t("\\section{"), i(1, "section name"), t("}"), i(0)
  }),
  s("ssec", {
    t("\\subsection{"), i(1, "subsection name"), t("}"), i(0)
  }),
  s("sssec", {
    t("\\subsubsection{"), i(1, "subsubsection name"), t("}"), i(0)
  }),

  s("beg", {
    t("\\begin{"), i(1, "environment"), t({ "}", "\t" }), i(2), t({ "", "\\end{" }),
    f(function(args) return args[1][1] end, { 1 }), t("}"), i(0)
  }),
  s("bullet", {
    t({ "\\begin{itemize}", "\t\\item " }), i(1), t({ "", "\\end{itemize}" }), i(0)
  }),
  s("number", {
    t({ "\\begin{enumerate}", "\t\\item " }), i(1), t({ "", "\\end{enumerate}" }), i(0)
  }),
  s("tab", {
    t({ "\\begin{table}[htbp]",
      "  \\centering",
      "  \\begin{tabular}{" }), i(1, "c c c"), t({ "}",
    "    " }), i(2, "content"), t({ "",
    "  \\end{tabular}",
    "  \\caption{" }), i(3, "caption"), t({ "}",
    "  \\label{tab:" }), i(4, "label"), t({ "}",
    "\\end{table}" }), i(0)
  }),

  s("sum", {
    t("\\sum_{"), i(1, "i=1"), t("}^{"), i(2, "n"), t("}"), i(0)
  }),
  s("prod", {
    t("\\prod_{"), i(1, "i=1"), t("}^{"), i(2, "n"), t("}"), i(0)
  }),
  s("lim", {
    t("\\lim_{"), i(1, "n \\to \\infty"), t("}"), i(0)
  }),
  s("int", {
    t("\\int_{"), i(1, "a"), t("}^{"), i(2, "b"), t("}"), i(3), t("\\,d"), i(4, "x"), i(0)
  }),
  s("matrix", {
    t({ "\\begin{pmatrix}",
      "  " }), i(1, "a_{11}"), t(" & "), i(2, "a_{12}"), t({ " \\",
    "  " }), i(3, "a_{21}"), t(" & "), i(4, "a_{22}"), t({ "",
    "\\end{pmatrix}" }), i(0)
  }),
}
