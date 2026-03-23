\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ntuabeamer}[2026/03/23 NTUA Beamer class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax

\LoadClass{beamer}
\RequirePackage{ntuabeamer}
