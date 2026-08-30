%%
%% sosa.cls -- article class for
%% Sosyal Bilimler ve Sağlık Bülteni (SoSa) / Bulletin of Social Sciences and Health
%%
%% Reverse-engineered from the typeset PDFs of SoSa 2026;BAHAR(18) and from the
%% journal's Word submission template.  Every metric in section 5 was measured
%% off the published PDFs; README.md carries the full measurement table.
%%
%% Engines: pdfLaTeX, XeLaTeX or LuaLaTeX.
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sosa}[2026/08/29 v1.0 SoSa journal article layout]

% ---------------------------------------------------------------------------
%  1. Class options
% ---------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sosa,prefix=sosa@}

\DeclareStringOption[alternate]{ornament}    % alternate | all | none
\DeclareStringOption[11]{fontsize}           % 11 | 12
\DeclareStringOption[turkish]{lang}          % turkish | english
\DeclareStringOption[cover]{ornamentfit}     % cover | stretch
\DeclareStringOption[auto]{headstyle}        % auto|sentence|uppercase|smallcaps
\DeclareStringOption[oldstyle]{figures}      % oldstyle | lining
\DeclareBoolOption{proof}                    % draw layout guides
\DeclareBoolOption{nofont}                   % skip the EB Garamond setup
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessKeyvalOptions*

\def\sosa@twelve{12}
\ifx\sosa@fontsize\sosa@twelve
  \LoadClass[a4paper,12pt,oneside,onecolumn]{article}
\else
  \LoadClass[a4paper,11pt,oneside,onecolumn]{article}
\fi

\RequirePackage{etoolbox}
\RequirePackage{calc}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{eso-pic}
\RequirePackage{ragged2e}
\RequirePackage{array}
\RequirePackage{booktabs}
\RequirePackage{multirow}
\RequirePackage{enumitem}
\RequirePackage{caption}
\RequirePackage{iftex}

% trimclip supplies the "cover" crop for the ornament strips.  It ships with
% the adjustbox bundle (present on Overleaf); degrade to a stretch if absent.
\newif\ifsosa@haveclip
\IfFileExists{trimclip.sty}{\RequirePackage{trimclip}\sosa@havecliptrue}{}

% ---------------------------------------------------------------------------
%  2. Palette  (sampled from the rendered PDFs)
% ---------------------------------------------------------------------------
\definecolor{sosaink}{HTML}{231F20}      % body text -- rich black, not pure black
\definecolor{sosaband}{HTML}{F1F9ED}     % running-head band on body pages
\definecolor{sosamasthead}{HTML}{E6E6E6} % masthead band on the first page
\definecolor{sosagreen}{HTML}{74C043}    % the band colour at full strength
\definecolor{sosaorcid}{HTML}{A6CE39}
\definecolor{sosaherofallback}{HTML}{4A5A46}

% ---------------------------------------------------------------------------
%  3. Fonts -- Garamond
% ---------------------------------------------------------------------------
% The journal is set in Adobe Garamond.  EB Garamond is the closest free
% equivalent: it carries the Turkish glyphs (ğ İ ı ş ç ö ü), has real small
% caps for the running head, and is installed on Overleaf.
\ifsosa@nofont\else
  \ifPDFTeX
    \RequirePackage[T1]{fontenc}
    \RequirePackage[utf8]{inputenc}
    \IfFileExists{ebgaramond.sty}
      {\ifdefstring{\sosa@figures}{lining}
         {\RequirePackage[lining]{ebgaramond}}
         {\RequirePackage{ebgaramond}}}
      {\ClassWarningNoLine{sosa}{EB Garamond not found -- falling back to the
        default roman.  Install it (`tlmgr install ebgaramond') or compile
        with XeLaTeX/LuaLaTeX}}
  \else
    \RequirePackage{fontspec}
    \IfFontExistsTF{EBGaramond-Regular.otf}
      {\setmainfont{EBGaramond}[
          Extension         = .otf,
          UprightFont       = *-Regular,
          ItalicFont        = *-Italic,
          BoldFont          = *-Bold,
          BoldItalicFont    = *-BoldItalic,
          SmallCapsFeatures = {Letters=SmallCaps},
          Language          = Turkish,
          Ligatures         = TeX ]%
       \ifdefstring{\sosa@figures}{lining}{\defaultfontfeatures{Numbers=Lining}}{}}
      {\IfFontExistsTF{EB Garamond}
        {\setmainfont{EB Garamond}[Ligatures=TeX,
           SmallCapsFeatures={Letters=SmallCaps}]}
        {\ClassWarningNoLine{sosa}{EB Garamond not found -- using the default
          roman font}}}
  \fi
\fi

% ---------------------------------------------------------------------------
%  4. Language
% ---------------------------------------------------------------------------
% babel's Turkish shorthands (`:' `=' `!') collide with maths and URLs, so only
% the hyphenation patterns are wanted here.
\newif\ifsosa@turkish
\def\sosa@tr{turkish}
\ifx\sosa@lang\sosa@tr \sosa@turkishtrue \fi
\IfFileExists{turkish.ldf}{}{%
  \ClassWarningNoLine{sosa}{babel-turkish not installed -- using English
    hyphenation.  Install `babel-turkish' for correct Turkish line breaks}%
  \sosa@turkishfalse}
\ifsosa@turkish
  \RequirePackage[shorthands=off,english,main=turkish]{babel}
\else
  \RequirePackage[shorthands=off,english]{babel}
\fi

% ---------------------------------------------------------------------------
%  5. Page geometry
% ---------------------------------------------------------------------------
%  Measured off the published PDFs (A4 = 595.276pt x 841.890pt):
%
%    header band                 0 .. 42.5pt              full bleed
%    left margin                 62.36pt (2.2cm)          Word template agrees
%    right margin, no ornament   62.36pt   -> measure 470.6pt
%    ornament strip              511.6pt .. past the right edge
%    text right edge with strip  470.5pt   -> measure ~408pt
%    bottom margin               70.87pt (2.5cm)
%    first body baseline         96.5pt from the paper top (11pt setting)
%                               103.2pt                   (12pt setting)
%    running-head baseline       24.5pt from the paper top, 45pt in from the left
%    folio baseline              32.3pt above the foot, 42.5pt in from the right
%
\newlength{\sosabandheight}     \setlength{\sosabandheight}{42.5pt}
\newlength{\sosaornamentwidth}  \setlength{\sosaornamentwidth}{84pt}
\newlength{\sosaornamentgutter} \setlength{\sosaornamentgutter}{40pt}
\newlength{\sosasidemargin}     \setlength{\sosasidemargin}{62.36pt}
\newlength{\sosafullwidth}      % measure when nothing is reserved on the right
\newlength{\sosaheadinset}      \setlength{\sosaheadinset}{45pt}
\newlength{\sosafolioinset}     \setlength{\sosafolioinset}{42.5pt}
\newlength{\sosaheadbaseline}   \setlength{\sosaheadbaseline}{24.5pt}
\newlength{\sosafoliobaseline}  \setlength{\sosafoliobaseline}{32.3pt}
\newlength{\sosatopbaseline}

\ifx\sosa@fontsize\sosa@twelve
  \setlength{\sosatopbaseline}{103.2pt}
\else
  \setlength{\sosatopbaseline}{96.5pt}
\fi

\setlength{\sosafullwidth}{\dimexpr\paperwidth-2\sosasidemargin\relax}

% Right-hand reserve: strip + gutter, minus the ordinary margin we already have.
\newlength{\sosa@reserve}
\def\sosa@none{none}
\ifx\sosa@ornament\sosa@none
  \setlength{\sosa@reserve}{0pt}
\else
  \setlength{\sosa@reserve}
    {\dimexpr\sosaornamentwidth+\sosaornamentgutter-\sosasidemargin\relax}
\fi

\newlength{\sosa@rightmargin}
\setlength{\sosa@rightmargin}{\dimexpr\sosasidemargin+\sosa@reserve\relax}
\newlength{\sosa@topmargin}
\setlength{\sosa@topmargin}{\dimexpr\sosatopbaseline-\sosa@fontsize pt\relax}

\RequirePackage{geometry}
\geometry{
  a4paper,
  left   = \sosasidemargin,
  right  = \sosa@rightmargin,
  top    = \sosa@topmargin,
  bottom = 70.87pt,
  nohead, nofoot,
}
\setlength{\topskip}{\sosa@fontsize pt}
\raggedbottom
\pagestyle{empty}

% ---------------------------------------------------------------------------
%  6. Body typography
% ---------------------------------------------------------------------------
%  11pt on 16.5pt -- Word's "1.5 lines" -- justified, no first-line indent,
%  8pt between paragraphs.
\newlength{\sosabodyleading}
\setlength{\sosabodyleading}{1.5\dimexpr\sosa@fontsize pt\relax}

\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\sosa@fontsize pt}{\sosabodyleading}%
  \abovedisplayskip 10\p@ \@plus2\p@ \@minus5\p@
  \abovedisplayshortskip \z@ \@plus3\p@
  \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
  \belowdisplayskip \abovedisplayskip}
\normalsize

\setlength{\parindent}{0pt}
% ragged2e captures its own copy of \parindent when it loads, which happens in
% the package block above -- while \parindent is still the article class's
% 17.5pt.  \justifying then restores that, and the abstract panes on page one
% came out first-line indented.  Zero all four.
\setlength{\JustifyingParindent}{\z@}
\setlength{\CenteringParindent}{\z@}
\setlength{\RaggedRightParindent}{\z@}
\setlength{\RaggedLeftParindent}{\z@}
\setlength{\parskip}{8pt}
\setlength{\emergencystretch}{2.5em}
\hyphenpenalty=250
\tolerance=2000
\AtBeginDocument{\color{sosaink}}

% ---------------------------------------------------------------------------
%  7. Headings
% ---------------------------------------------------------------------------
%  Bold, at body size, flush left.  Measured: 48.9pt from the last body
%  baseline to the heading baseline (= one 16.5pt line + 8pt \parskip + 24pt),
%  and 8pt from the heading to the text under it.
\setcounter{secnumdepth}{0}
\renewcommand\section{\@startsection{section}{1}{\z@}%
  {24pt \@plus 4pt \@minus 2pt}{8pt}%
  {\normalfont\normalsize\bfseries\raggedright}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
  {16pt \@plus 3pt \@minus 2pt}{6pt}%
  {\normalfont\normalsize\bfseries\raggedright}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
  {12pt \@plus 2pt \@minus 2pt}{4pt}%
  {\normalfont\normalsize\bfseries\itshape\raggedright}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
  {10pt \@plus 2pt}{-0.6em}%
  {\normalfont\normalsize\itshape}}

% ---------------------------------------------------------------------------
%  8. Block quotations
% ---------------------------------------------------------------------------
%  Interview excerpts: indented 1cm on the left only, body size, no extra
%  leading (measured on the qualitative article, pp. 26-33).
\renewenvironment{quote}
  {\list{}{\leftmargin28.35pt \rightmargin\z@ \listparindent\z@
           \parsep\z@ \topsep6pt \partopsep\z@}%
   \item\relax}
  {\endlist}
\let\quotation\quote
\let\endquotation\endquote

% ---------------------------------------------------------------------------
%  9. Captions
% ---------------------------------------------------------------------------
%  Tables:  "Tablo 1. Title"  bold, above the table, flush left.
%  Figures: "Görsel 1. Title" regular, below the figure, centred.
\DeclareCaptionLabelSeparator{sosasep}{. }
\captionsetup{labelsep=sosasep,skip=6pt}
\captionsetup[table]{position=above,justification=raggedright,
  singlelinecheck=false,font=bf}
\captionsetup[figure]{position=below,justification=centering,
  singlelinecheck=false}

\ifsosa@turkish
  \addto\captionsturkish{%
    \renewcommand{\tablename}{Tablo}%
    \renewcommand{\figurename}{Görsel}}%
\fi
\AtBeginDocument{%
  \ifsosa@turkish
    \renewcommand{\tablename}{Tablo}%
    \renewcommand{\figurename}{Görsel}%
  \fi}

\setlength{\textfloatsep}{18pt \@plus 4pt \@minus 4pt}
\setlength{\floatsep}{16pt \@plus 4pt \@minus 4pt}
\setlength{\intextsep}{16pt \@plus 4pt \@minus 4pt}
\renewcommand{\topfraction}{0.9}
\renewcommand{\bottomfraction}{0.8}
\renewcommand{\textfraction}{0.07}
\renewcommand{\floatpagefraction}{0.75}

% ---------------------------------------------------------------------------
% 10. Tables
% ---------------------------------------------------------------------------
%  Three horizontal rules only -- top, under the head, bottom -- all 0.5pt,
%  no verticals.  Dense tables drop to 9pt.
\setlength{\heavyrulewidth}{0.5pt}
\setlength{\lightrulewidth}{0.5pt}
\setlength{\cmidrulewidth}{0.5pt}
\setlength{\aboverulesep}{3pt}
\setlength{\belowrulesep}{3pt}
\renewcommand{\arraystretch}{1.15}

\newcommand{\sosatablesize}{\fontsize{10pt}{13pt}\selectfont}
\newcommand{\sosatablesmall}{\fontsize{9pt}{11.5pt}\selectfont}

% The journal's table body.  Supplies the \toprule and \bottomrule; you add the
% \midrule under the head row.  The optional argument is the type size --
% \sosatablesize (10 pt, the default) or \sosatablesmall (9 pt, for dense
% tables like Table 1 in the source article).
%
%   \begin{sosatabular}[\sosatablesmall]{@{}L{150pt}L{130pt}R{110pt}@{}}
%     \textbf{Değişkenler} & & \textbf{Sayı (\%)} \\
%     \midrule
%     Yaş & 50 yaş altı & 386 (\%54,0) \\
%   \end{sosatabular}
%
\newenvironment{sosatabular}[2][\sosatablesize]
  {#1\begin{tabular}{#2}\toprule}
  {\bottomrule\end{tabular}}

\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}}
\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}
\newcolumntype{R}[1]{>{\raggedleft\arraybackslash}p{#1}}

% ---------------------------------------------------------------------------
% 11. The ornament engine
% ---------------------------------------------------------------------------
%  What the journal does
%  ---------------------
%  A full-bleed illustration strip runs down the right edge from the bottom of
%  the header band to the foot of the sheet.  It appears on every *other* page:
%  never on the title page, always on the one after it, alternating from there.
%  The artwork changes page to page and its width wobbles between 64pt and 85pt
%  because each strip was placed by hand.
%
%  What this class does
%  --------------------
%  * The strip is painted into the shipout background, so it never touches the
%    galley and can bleed past the paper edge.
%  * The measure is CONSTANT: the right-hand reserve is kept free whether or
%    not a strip is painted there.  That is deliberate.  LaTeX breaks pages
%    only after the paragraphs are set, so a text width that depends on which
%    page a line lands on cannot be made reliable; a constant measure also
%    keeps facing pages in register, which the hand-made original does not.
%    \begin{sosawide} buys the reserve back for a wide table or figure.
%  * Which page gets which picture is entirely under your control.
%
%    \SosaOrnamentCycle{f1,f2,f3}   artwork used in turn on ornament pages
%    \SosaOrnament{<page>}{<file>}  pin one file to one printed page number
%    \SosaNoOrnament{<p1,p2,...>}   suppress the strip on those printed pages
%    \SosaForceOrnament{<p1,...>}   force one onto those printed pages
%    \SosaNoOrnamentHere            suppress it wherever this lands (2 passes)
%    \SosaOrnamentHere              force one wherever this lands  (2 passes)
%
\newcounter{sosa@ornidx}
\newcounter{sosa@orncount}

\newcommand{\sosa@countorn}[1]{%
  \stepcounter{sosa@orncount}%
  \csgdef{sosa@ornfile@\thesosa@orncount}{#1}}
\newcommand{\SosaOrnamentCycle}[1]{%
  \setcounter{sosa@orncount}{0}%
  \forcsvlist{\sosa@countorn}{#1}}

\newcommand{\SosaOrnament}[2]{\csgdef{sosa@ornpage@#1}{#2}}
\newcommand{\sosa@declnoorn}[1]{\csgdef{sosa@noorn@#1}{}}
\newcommand{\SosaNoOrnament}[1]{\forcsvlist{\sosa@declnoorn}{#1}}
\newcommand{\sosa@declyesorn}[1]{\csgdef{sosa@yesorn@#1}{}}
\newcommand{\SosaForceOrnament}[1]{\forcsvlist{\sosa@declyesorn}{#1}}

% A deferred \write (not \immediate): the whatsit is expanded during the
% shipout of whichever page it ends up on, so \the\c@page is that page.  The
% instruction reaches the next run through the .aux -- hence two passes.
\newcommand{\SosaNoOrnamentHere}{%
  \write\@auxout{\string\SosaNoOrnament{\the\c@page}}\ignorespaces}
\newcommand{\SosaOrnamentHere}{%
  \write\@auxout{\string\SosaForceOrnament{\the\c@page}}\ignorespaces}

% The article continues the issue's pagination (e.g. it starts at page 60).
% The alternation is measured from that first page, so always set it here
% rather than with a bare \setcounter{page}{..}.
\newcommand{\sosa@startpage}{1}
\newcommand{\SosaStartPage}[1]{%
  \renewcommand{\sosa@startpage}{#1}\setcounter{page}{#1}}

\newif\ifsosa@paintorn
\def\sosa@all{all}
\newcommand{\sosa@decideornament}{%
  \sosa@paintornfalse
  \ifx\sosa@ornament\sosa@none\else
    \ifnum\c@page>\sosa@startpage\relax
      \ifx\sosa@ornament\sosa@all
        \sosa@paintorntrue
      \else
        \ifodd\numexpr\c@page-\sosa@startpage\relax
          \sosa@paintorntrue
        \fi
      \fi
    \fi
  \fi
  \ifcsdef{sosa@noorn@\the\c@page}{\sosa@paintornfalse}{}%
  \ifcsdef{sosa@yesorn@\the\c@page}{\sosa@paintorntrue}{}%
}

\newcommand{\sosa@ornfile}{}
\newcommand{\sosa@pickornament}{%
  \ifcsdef{sosa@ornpage@\the\c@page}
    {\expandafter\let\expandafter\sosa@ornfile
       \csname sosa@ornpage@\the\c@page\endcsname}%
    {\ifnum\value{sosa@orncount}>0\relax
       \stepcounter{sosa@ornidx}%
       \ifnum\value{sosa@ornidx}>\value{sosa@orncount}\relax
         \setcounter{sosa@ornidx}{1}%
       \fi
       \expandafter\let\expandafter\sosa@ornfile
         \csname sosa@ornfile@\thesosa@ornidx\endcsname
     \else
       \let\sosa@ornfile\@empty
     \fi}%
}

% "cover" fit -- scale the artwork to the band height, then crop equal slices
% off both sides so it fills the band without distorting.  Same idea as CSS's
% background-size: cover.
\newsavebox{\sosa@ornbox}
\newdimen\sosa@cliplo
\newdimen\sosa@cliphi
\newcommand{\sosacoverbox}[3]{% {width}{height}{file}
  \sbox\sosa@ornbox{\includegraphics[height=#2]{#3}}%
  \ifdim\wd\sosa@ornbox>#1\relax
    \ifsosa@haveclip
      \sosa@cliplo=\dimexpr(\wd\sosa@ornbox-#1)/2\relax
      \sosa@cliphi=\dimexpr\sosa@cliplo+#1\relax
      \edef\sosa@clipdo{%
        \noexpand\clipbox*{\the\sosa@cliplo\space 0pt\space
                           \the\sosa@cliphi\space \the\ht\sosa@ornbox}}%
      \sosa@clipdo{\usebox\sosa@ornbox}%
    \else
      \includegraphics[width=#1,height=#2]{#3}%
    \fi
  \else
    \includegraphics[width=#1,height=#2]{#3}%
  \fi}

\def\sosa@stretch{stretch}
\newcommand{\sosa@placeart}[3]{% {width}{height}{file}
  \ifx\sosa@ornamentfit\sosa@stretch
    \includegraphics[width=#1,height=#2]{#3}%
  \else
    \sosacoverbox{#1}{#2}{#3}%
  \fi}

% ---------------------------------------------------------------------------
% 12. Page furniture, stamped straight onto the sheet
% ---------------------------------------------------------------------------
%  Band, strip, running head and folio all sit outside the galley, so they go
%  into the shipout hooks at absolute coordinates rather than through fancyhdr.
%  That is what makes the geometry exact.
\newcommand{\sosarunninghead}{}
\newcommand{\SosaRunningHead}[1]{\renewcommand{\sosarunninghead}{#1}}
\newcommand{\sosamastheadline}{}
\newcommand{\SosaMasthead}[1]{\renewcommand{\sosamastheadline}{#1}}

% On ornament pages the folio sits underneath the strip.  One source article
% simply drops it there, the other prints it over the artwork.  Printing it is
% the default; \SosaHideFolioOnOrnamentPages reproduces the other behaviour.
\newif\ifsosa@foliohide
\newcommand{\SosaHideFolioOnOrnamentPages}{\sosa@foliohidetrue}
\newcommand{\SosaShowFolioOnOrnamentPages}{\sosa@foliohidefalse}

\newcommand{\sosaheadfont}{\fontsize{7.6pt}{9pt}\selectfont}
\newcommand{\sosamastheadfont}{\fontsize{9pt}{11pt}\selectfont}
\newcommand{\sosafoliofont}{\fontsize{10pt}{12pt}\selectfont\bfseries}

% --- Turkish small caps ----------------------------------------------------
%  The masthead and the running head are set in small caps.  Ordinary small
%  caps turn a lower-case `i' into a DOTLESS small capital, which in Turkish is
%  a different letter: "Bilimler" comes out as "BILIMLER" where it must read
%  "BİLİMLER".  The published journal gets this right -- it has the dot -- and
%  the dotless small capital is reserved for `ı', as in "SAĞLIK".
%
%  Neither of our font paths gives us the OpenType `locl' feature that would do
%  this automatically (the Type 1 EB Garamond has no features at all), so the
%  substitution is made here: every literal `i' in the head string becomes a
%  small capital carrying a dot accent.  `ı' is left alone and comes out
%  dotless, which is what it should be.
%
%  What was tried, and what happened
%  ---------------------------------
%  First attempt was \.{i} -- a dot accent over the small capital.  It rendered
%  with NO dot at all under T1 + EB Garamond, so the accent is either being
%  swallowed by a text composite or the small-caps font has no dot accent to
%  place.  The replacement below scales a real İ instead, which uses a glyph
%  the font demonstrably has (the affiliations on page one set "İzmir"
%  correctly), rather than relying on accent composition.
%
%  Even so, the default for Turkish is now `sentence' -- the head is set exactly
%  as typed, with no case mapping at all.  A transformation that cannot run
%  cannot get the letter wrong, and "Sosyal Bilimler ve Sağlık Bülteni" is
%  already correct Turkish on the page.  This departs from the journal, which
%  uses small caps; `uppercase' is the closer-looking option that is also
%  correct, because \MakeUppercase under babel-turkish maps i to İ.
%
%  \SosaHeadStyle picks the treatment:
%    sentence    no transformation -- exactly as typed (Turkish default)
%    uppercase   \MakeUppercase -- locale-aware, so İ is correct; full capitals,
%                and the closest of these to the printed journal
%    smallcaps   true small caps with the İ substitution described above
%    asis        synonym for sentence
%    auto        sentence under lang=turkish, plain \textsc otherwise
\newcommand{\sosadottedsc}{\scalebox{0.8}{\normalfont İ}}
\ExplSyntaxOn
\tl_new:N \l__sosa_head_tl
\cs_new_protected:Npn \__sosa_head_trsc:n #1
  {
    \tl_set:Nx \l__sosa_head_tl { #1 }
    \tl_replace_all:Nnn \l__sosa_head_tl { i } { \sosadottedsc }
    \textsc { \tl_use:N \l__sosa_head_tl }
  }
\cs_new_eq:NN \sosaturkishsc \__sosa_head_trsc:n
\ExplSyntaxOff

\newcommand{\SosaHeadStyle}[1]{\renewcommand{\sosa@headstyle}{#1}}
\AtBeginDocument{%
  \ifdefstring{\sosa@headstyle}{auto}{%
    \ifsosa@turkish
      \renewcommand{\sosa@headstyle}{sentence}%
    \else
      \renewcommand{\sosa@headstyle}{plainsmallcaps}%
    \fi}{}%
}
% Applies the chosen treatment to one head string.
\newcommand{\sosaheadcase}[1]{%
  \ifdefstring{\sosa@headstyle}{sentence}{#1}{%
  \ifdefstring{\sosa@headstyle}{asis}{#1}{%
  \ifdefstring{\sosa@headstyle}{uppercase}{\MakeUppercase{#1}}{%
  \ifdefstring{\sosa@headstyle}{plainsmallcaps}{\textsc{#1}}{%
    \sosaturkishsc{#1}}}}}}

\newlength{\sosaherotop}    \setlength{\sosaherotop}{71pt}
\newlength{\sosaheroheight} \setlength{\sosaheroheight}{108pt}
\newcommand{\sosa@herofile}{}
\newcommand{\SosaHero}[1]{\renewcommand{\sosa@herofile}{#1}}

% --- keeping the title readable over the banner ----------------------------
%  The banner artwork is chosen for the issue, not for the words that have to
%  sit on top of it, so a light or busy image can swallow the white title.
%  Two knobs:
%
%    \SosaHeroScrim{0.35}       a wash laid over the banner, 0 = off
%    \SosaHeroScrimColor{black} what colour that wash is
%    \SosaTitleColor{white}     the title itself
%
%  The scrim goes into the background, under the title, so it darkens the
%  picture without touching the type.  For a pale banner, invert instead:
%  \SosaHeroScrim{0} together with \SosaTitleColor{sosaink}.
\newcommand{\sosa@scrimopacity}{0.35}
\newcommand{\SosaHeroScrim}[1]{\renewcommand{\sosa@scrimopacity}{#1}}
\newcommand{\sosa@scrimcolor}{black}
\newcommand{\SosaHeroScrimColor}[1]{\renewcommand{\sosa@scrimcolor}{#1}}
\newcommand{\sosa@titlecolor}{white}
\newcommand{\SosaTitleColor}[1]{\renewcommand{\sosa@titlecolor}{#1}}

\newcommand{\sosa@paintheroscrim}{%
  \ifdim\sosa@scrimopacity pt>\z@
    \put(0,\LenToUnit{-\dimexpr\sosaherotop+\sosaheroheight\relax}){%
      \begin{tikzpicture}[baseline=0pt]
        \fill[fill=\sosa@scrimcolor, opacity=\sosa@scrimopacity,draw=none]
          (0pt,0pt) rectangle (\the\paperwidth,\the\sosaheroheight);
      \end{tikzpicture}}%
  \fi}

\newcommand{\sosa@paintband}{%
  \ifnum\c@page=\sosa@startpage\relax
    \textcolor{sosamasthead}{\rule{\paperwidth}{\sosabandheight}}%
  \else
    \textcolor{sosaband}{\rule{\paperwidth}{\sosabandheight}}%
  \fi}

\newcommand{\sosa@paintbackground}{%
  \AtPageUpperLeft{%
    % header band, full bleed
    \put(0,\LenToUnit{-\sosabandheight}){\sosa@paintband}%
    \ifnum\c@page=\sosa@startpage\relax
      % first page: the hero band
      \put(0,\LenToUnit{-\dimexpr\sosaherotop+\sosaheroheight\relax}){%
        \ifdefempty{\sosa@herofile}
          {\textcolor{sosaherofallback}{\rule{\paperwidth}{\sosaheroheight}}}%
          {\sosa@placeart{\paperwidth}{\sosaheroheight}{\sosa@herofile}}}%
      \sosa@paintheroscrim
    \else
      % body pages: the right-hand ornament strip
      \sosa@decideornament
      \ifsosa@paintorn
        \sosa@pickornament
        \ifdefempty{\sosa@ornfile}{}{%
          \put(\LenToUnit{\dimexpr\paperwidth-\sosaornamentwidth\relax},%
               \LenToUnit{-\paperheight}){%
            \sosa@placeart{\sosaornamentwidth}%
              {\dimexpr\paperheight-\sosabandheight\relax}{\sosa@ornfile}}}%
      \fi
    \fi
  }%
}

\newcommand{\sosa@paintforeground}{%
  \AtPageUpperLeft{%
    \put(\LenToUnit{\sosaheadinset},\LenToUnit{-\sosaheadbaseline}){%
      \ifnum\c@page=\sosa@startpage\relax
        \textcolor{sosaink}{\sosamastheadfont\sosaheadcase{\sosamastheadline}}%
      \else
        \textcolor{sosaink}{\sosaheadfont\sosaheadcase{\sosarunninghead}}%
      \fi}%
  }%
  \sosa@decideornament
  \ifsosa@foliohide\ifsosa@paintorn\else\sosa@paintfolio\fi\else\sosa@paintfolio\fi
  \ifsosa@proof\sosa@paintguides\fi
}

\newcommand{\sosa@paintfolio}{%
  \AtPageLowerLeft{%
    \put(\LenToUnit{\dimexpr\paperwidth-\sosafolioinset\relax},%
         \LenToUnit{\sosafoliobaseline}){%
      \llap{\textcolor{sosaink}{\sosafoliofont\thepage}}}%
  }%
}

\AddToShipoutPictureBG{\sosa@paintbackground}
\AddToShipoutPictureFG{\sosa@paintforeground}

% Layout guides, for the `proof' option.
\newcommand{\sosa@paintguides}{%
  \AtPageUpperLeft{%
    \put(\LenToUnit{\sosasidemargin},\LenToUnit{-\sosatopbaseline}){%
      \textcolor{red!45}{\rule{\textwidth}{0.2pt}}}%
    \put(\LenToUnit{\sosasidemargin},\LenToUnit{-\paperheight}){%
      \textcolor{red!45}{\rule{0.2pt}{\paperheight}}}%
    \put(\LenToUnit{\dimexpr\sosasidemargin+\textwidth\relax},%
         \LenToUnit{-\paperheight}){%
      \textcolor{red!45}{\rule{0.2pt}{\paperheight}}}%
    \put(\LenToUnit{\dimexpr\paperwidth-\sosaornamentwidth\relax},%
         \LenToUnit{-\paperheight}){%
      \textcolor{blue!45}{\rule{0.2pt}{\paperheight}}}%
    \put(\LenToUnit{\dimexpr\paperwidth-\sosasidemargin\relax},%
         \LenToUnit{-\paperheight}){%
      \textcolor{green!55!black}{\rule{0.2pt}{\paperheight}}}%
  }}

% ---------------------------------------------------------------------------
% 13. Full-measure blocks
% ---------------------------------------------------------------------------
%  Reclaims the ornament reserve for one block -- a wide table, a wide figure.
%  It also suppresses that page's strip, which is exactly what the journal
%  does: every wide table in the source articles sits on an ornament-free page.
\newsavebox{\sosa@widebox}
\newif\ifsosa@usedwide
\AtEndDocument{%
  \ifsosa@usedwide
    \ClassWarningNoLine{sosa}{The sosawide environment was used -- compile
      once more so the ornament strips settle onto the right pages}%
  \fi}
\newenvironment{sosawide}
  {\global\sosa@usedwidetrue\SosaNoOrnamentHere
   \par\begin{lrbox}{\sosa@widebox}\begin{minipage}{\sosafullwidth}}
  {\end{minipage}\end{lrbox}%
   \noindent\makebox[\textwidth][l]{\usebox{\sosa@widebox}}\par}

% Same, but keeps the strip -- for a block that only just overflows.
\newenvironment{sosawidekeep}
  {\par\begin{lrbox}{\sosa@widebox}\begin{minipage}{\sosafullwidth}}
  {\end{minipage}\end{lrbox}%
   \noindent\makebox[\textwidth][l]{\usebox{\sosa@widebox}}\par}

% ---------------------------------------------------------------------------
% 14. Front-matter data
% ---------------------------------------------------------------------------
\newcommand{\sosa@articletype}{Özgün Makale}
\newcommand{\SosaArticleType}[1]{\renewcommand{\sosa@articletype}{#1}}
\newcommand{\sosa@titletr}{}
\newcommand{\sosa@titleen}{}
\renewcommand{\title}[1]{\renewcommand{\sosa@titletr}{#1}}
\newcommand{\SosaTitleTR}[1]{\renewcommand{\sosa@titletr}{#1}}
\newcommand{\SosaTitleEN}[1]{\renewcommand{\sosa@titleen}{#1}}
% --- authors, one \SosaAuthor line each ------------------------------------
%   \SosaAuthor{Name Surname}{1,2}{0000-0000-0000-0000}
%              ^name          ^affiliation numbers, or empty
%                                  ^ORCID, or empty
% Repeat once per author, in order.  The commas between names, the
% superscripts and the ORCID marks are all inserted for you.
%
% \author{...} still works and overrides the whole line, for the rare case
% where you need to hand-build it.
\newcommand{\sosa@authorline}{}
\newif\ifsosa@firstauthor \sosa@firstauthortrue
\newcommand{\SosaAuthor}[3]{%
  \ifsosa@firstauthor
    \sosa@firstauthorfalse
  \else
    \appto\sosa@authorline{, }%
  \fi
  \appto\sosa@authorline{#1}%
  \ifblank{#2}{}{\appto\sosa@authorline{\sosaaff{#2}}}%
  \ifblank{#3}{}{\appto\sosa@authorline{\orcid{#3}}}%
}
\renewcommand{\author}[1]{\renewcommand{\sosa@authorline}{#1}}

% --- affiliations, one \SosaAffiliation line each --------------------------
% They are numbered automatically, in the order given, to match the
% superscripts in \SosaAuthor.
\newcommand{\sosa@affiliations}{}
\newcommand{\SosaAffiliation}[1]{\appto\sosa@affiliations{\item #1}}
% Plural form: hand-build the whole list of \item's at once.
\newcommand{\SosaAffiliations}[1]{\renewcommand{\sosa@affiliations}{#1}}

\newcommand{\sosa@note}{}
\newcommand{\SosaNote}[1]{\renewcommand{\sosa@note}{#1}}

\newcommand{\sosa@oz}{}         \newcommand{\SosaOz}[1]{\renewcommand{\sosa@oz}{#1}}
\newcommand{\sosa@abstract}{}   \newcommand{\SosaAbstract}[1]{\renewcommand{\sosa@abstract}{#1}}
\newcommand{\sosa@keywordstr}{} \newcommand{\SosaKeywordsTR}[1]{\renewcommand{\sosa@keywordstr}{#1}}
\newcommand{\sosa@keywordsen}{} \newcommand{\SosaKeywordsEN}[1]{\renewcommand{\sosa@keywordsen}{#1}}

\newcommand{\sosa@received}{}   \newcommand{\SosaReceived}[1]{\renewcommand{\sosa@received}{#1}}
\newcommand{\sosa@accepted}{}   \newcommand{\SosaAccepted}[1]{\renewcommand{\sosa@accepted}{#1}}
\newcommand{\sosa@published}{}  \newcommand{\SosaPublished}[1]{\renewcommand{\sosa@published}{#1}}
\newcommand{\sosa@corrauthor}{} \newcommand{\SosaCorrespondingAuthor}[1]{\renewcommand{\sosa@corrauthor}{#1}}
\newcommand{\sosa@corrmail}{}   \newcommand{\SosaCorrespondingEmail}[1]{\renewcommand{\sosa@corrmail}{#1}}
\newcommand{\sosa@editor}{}     \newcommand{\SosaHandlingEditor}[1]{\renewcommand{\sosa@editor}{#1}}
\newcommand{\sosa@citation}{}   \newcommand{\SosaCitation}[1]{\renewcommand{\sosa@citation}{#1}}
\newcommand{\sosa@citationauthors}{}
\newcommand{\SosaCitationAuthors}[1]{\renewcommand{\sosa@citationauthors}{#1}}

% --- issue metadata --------------------------------------------------------
%  Give these once and the masthead line, the running head and the suggested
%  citation are all built from them, instead of being typed three times in
%  three slightly different forms.  Setting \SosaMasthead, \SosaRunningHead or
%  \SosaCitation by hand still overrides the derived version.
\newcommand{\sosa@journal}{}      \newcommand{\SosaJournal}[1]{\renewcommand{\sosa@journal}{#1}}
\newcommand{\sosa@journalshort}{} \newcommand{\SosaJournalShort}[1]{\renewcommand{\sosa@journalshort}{#1}}
\newcommand{\sosa@year}{}         \newcommand{\SosaYear}[1]{\renewcommand{\sosa@year}{#1}}
\newcommand{\sosa@issuelabel}{}
\newcommand{\sosa@issuenumber}{}
\newcommand{\SosaIssue}[2]{%
  \renewcommand{\sosa@issuelabel}{#1}\renewcommand{\sosa@issuenumber}{#2}}
\newcommand{\sosa@firstpage}{}
\newcommand{\sosa@lastpage}{}
% \SosaPages also sets the start page, so the ornament alternation is anchored
% correctly -- you do not need a separate \SosaStartPage.
\newcommand{\SosaPages}[2]{%
  \renewcommand{\sosa@firstpage}{#1}\renewcommand{\sosa@lastpage}{#2}%
  \SosaStartPage{#1}}
\newcommand{\sosa@shorttitle}{}
\newcommand{\SosaShortTitle}[1]{\renewcommand{\sosa@shorttitle}{#1}}

% Fill in whatever the author did not set explicitly.
\AtBeginDocument{%
  \ifdefempty{\sosa@shorttitle}
    {\let\sosa@shorttitle\sosa@titletr}{}%
  \ifdefempty{\sosamastheadline}{%
    \renewcommand{\sosamastheadline}{%
      \sosa@journal{} (\sosa@journalshort). \sosa@year;
      \sosa@issuelabel(\sosa@issuenumber):\sosa@firstpage-\sosa@lastpage}%
  }{}%
  \ifdefempty{\sosarunninghead}{%
    \renewcommand{\sosarunninghead}{%
      \sosa@shorttitle. \sosa@journalshort. %
      \sosa@year;\sosa@issuelabel(\sosa@issuenumber)}%
  }{}%
  \ifdefempty{\sosa@citation}{%
    \ifdefempty{\sosa@citationauthors}{}{%
      \renewcommand{\sosa@citation}{%
        \sosa@citationauthors{} (\sosa@year). \sosa@titletr.
        \textit{\sosa@journal{} (\sosa@journalshort),
                \sosa@issuelabel(\sosa@issuenumber),}
        \sosa@firstpage-\sosa@lastpage}%
    }%
  }{}%
}

% ---------------------------------------------------------------------------
% 15. Fixed strings  (redefine any of these for an English-language issue)
% ---------------------------------------------------------------------------
\newcommand{\sosaozname}{Öz}
\newcommand{\sosaabstractname}{Abstract}
\newcommand{\sosakeywordstrname}{Anahtar sözcükler:}
\newcommand{\sosakeywordsenname}{Keywords:}
\newcommand{\sosareferencesname}{Kaynaklar}
\newcommand{\sosareceivedname}{Geliş Tarihi / Received:}
\newcommand{\sosaacceptedname}{Kabul Tarihi / Accepted:}
\newcommand{\sosapublishedname}{Yayın Tarihi / Published:}
\newcommand{\sosacorrname}{Sorumlu Yazar / Correspondence:}
\newcommand{\sosamailname}{Eposta:}
\newcommand{\sosaeditorname}{Sorumlu Editör / Handling Editor:}
\newcommand{\sosacitationname}{Atıf için / Suggested Citation:}

% ---------------------------------------------------------------------------
% 16. Small pieces used in the front matter
% ---------------------------------------------------------------------------
% Affiliation superscript, at the journal's 8.7pt on a 15pt author line.
\newcommand{\sosaaff}[1]{%
  \raisebox{0.55ex}{\fontsize{8.7pt}{8.7pt}\selectfont\bfseries#1}}

% ORCID mark -- drawn, so no image file is needed.
\newcommand{\sosaorcidmark}{%
  \raisebox{-0.15ex}{\begin{tikzpicture}[baseline=0pt]
    \fill[sosaorcid] (0,0.35ex) circle (0.55ex);
    \node[white,inner sep=0pt] at (0,0.35ex)
      {\resizebox{0.75ex}{!}{\normalfont\sffamily\bfseries iD}};
  \end{tikzpicture}}}
\newcommand{\orcid}[1]{\,\href{https://orcid.org/#1}{\sosaorcidmark}}

% ---------------------------------------------------------------------------
% 17. The first page
% ---------------------------------------------------------------------------
%  Measured baselines, from the paper top:
%    masthead line        24.5      running head band, small caps 9pt
%    "Özgün Makale"       63.5      bold 14pt
%    hero band            71 .. 179 full bleed, Turkish title centred in it
%    English title       201.5      bold 11.2pt
%    author line         235.5      bold 15pt, 20pt leading
%    affiliations        295.5      italic 9.6pt, 13pt leading
%    Öz / Abstract head  376        bold 13pt   (floats with the block above)
%    colophon rule       704.1      1.42pt, x = 40.3 .. 550.5
%    colophon text       721.4      8pt, x = 90.6
%
%  Everything above the English title, plus the colophon, is stamped at fixed
%  coordinates; the block from the English title down to the abstract flows,
%  so a longer author list pushes the abstract down exactly as in the original.
\newlength{\sosaabstractcolwidth} \setlength{\sosaabstractcolwidth}{216pt}
\newlength{\sosaabstractgutter}   \setlength{\sosaabstractgutter}{40.5pt}
\newlength{\sosacolophonrule}     \setlength{\sosacolophonrule}{704.1pt}
\newlength{\sosacolophoninset}    \setlength{\sosacolophoninset}{90.6pt}
\newlength{\sosacolophonwidth}    \setlength{\sosacolophonwidth}{396pt}
\newlength{\sosatitleinset}       \setlength{\sosatitleinset}{42.5pt}

% Vertical rhythm of the flowing block -- nudge these if your author list or
% title runs to a different number of lines than the ones measured.
\newlength{\sosafirstblocktop}    \setlength{\sosafirstblocktop}{188pt}
\newlength{\sosaskipauthors}      \setlength{\sosaskipauthors}{14pt}
\newlength{\sosaskipaffil}        \setlength{\sosaskipaffil}{6pt}
\newlength{\sosaskipabstract}     \setlength{\sosaskipabstract}{26pt}
\newlength{\sosaskipnote}         \setlength{\sosaskipnote}{22pt}

\newcommand{\sosatitlefont}{\fontsize{22.4pt}{30pt}\selectfont\bfseries}
\newcommand{\sosaentitlefont}{\fontsize{11.2pt}{14pt}\selectfont\bfseries}
\newcommand{\sosaauthorfont}{\fontsize{15pt}{20pt}\selectfont\bfseries}
\newcommand{\sosaafffont}{\fontsize{9.6pt}{13pt}\selectfont\itshape}
\newcommand{\sosaozheadfont}{\fontsize{13pt}{16pt}\selectfont\bfseries}
\newcommand{\sosatypefont}{\fontsize{14pt}{17pt}\selectfont\bfseries}
\newcommand{\sosacolophonfont}{\fontsize{8pt}{13pt}\selectfont}
\newcommand{\sosanotefont}{\fontsize{9pt}{16pt}\selectfont}

% The abstract panes are set very tight in the original -- 8pt type on a 7.1pt
% baseline.  9pt is the readable default here; \SosaAbstractLeading{7.1pt}
% reproduces the source exactly.
\newcommand{\sosaabstractfont}{\fontsize{8pt}{9pt}\selectfont}
\newcommand{\SosaAbstractLeading}[1]{%
  \renewcommand{\sosaabstractfont}{\fontsize{8pt}{#1}\selectfont}}

\newcommand{\sosa@painttitle}{%
  \AtPageUpperLeft{%
    \put(\LenToUnit{\sosatitleinset},%
         \LenToUnit{-\dimexpr\sosaherotop+\sosaheroheight\relax}){%
      \begin{minipage}[b][\sosaheroheight][c]%
          {\dimexpr\paperwidth-2\sosatitleinset\relax}%
        \color{\sosa@titlecolor}\sosatitlefont\raggedright\sosa@titletr
      \end{minipage}}%
    \put(\LenToUnit{43.1pt},\LenToUnit{-63.5pt}){%
      \textcolor{sosaink}{\sosatypefont\sosa@articletype}}%
  }}

% The colophon sits at a fixed height whatever the abstract does.
\newcommand{\sosa@paintcolophon}{%
  \AtPageUpperLeft{%
    \put(\LenToUnit{40.3pt},\LenToUnit{-\sosacolophonrule}){%
      \textcolor{sosaink}{\rule{510.2pt}{1.42pt}}}%
    \put(\LenToUnit{\sosacolophoninset},\LenToUnit{-721.4pt}){%
      \begin{minipage}[t]{\sosacolophonwidth}%
        \color{sosaink}\sosacolophonfont
        \setlength{\parskip}{5.5pt}\setlength{\parindent}{0pt}%
        \raggedright
        \textbf{\sosareceivedname} \sosa@received\quad
        \textbf{\sosaacceptedname} \sosa@accepted\quad
        \textbf{\sosapublishedname} \sosa@published\par
        \textbf{\sosacorrname} \sosa@corrauthor
        \ifdefempty{\sosa@corrmail}{}%
          {\quad\textbf{\sosamailname} \sosa@corrmail}\par
        \ifdefempty{\sosa@editor}{}%
          {\textbf{\sosaeditorname} \sosa@editor\par}%
        \textbf{\sosacitationname} \sosa@citation\par
      \end{minipage}}%
  }}

\renewcommand{\maketitle}{%
  \AddToShipoutPictureFG*{\sosa@painttitle\sosa@paintcolophon}%
  \thispagestyle{empty}%
  % push the galley down to the top of the English title
  \vspace*{\dimexpr\sosafirstblocktop-\sosatopbaseline\relax}%
  \noindent\makebox[\textwidth][l]{%
    \begin{minipage}{\sosafullwidth}%
      \color{sosaink}\setlength{\parskip}{0pt}\setlength{\parindent}{0pt}%
      % --- English title ---------------------------------------------------
      \ifdefempty{\sosa@titleen}{}%
        {{\sosaentitlefont\raggedright\sosa@titleen\par}}%
      % --- authors ---------------------------------------------------------
      % The author line hangs 7.9pt into the left margin in the original.
      \vspace{\sosaskipauthors}%
      \hspace*{-7.86pt}%
      \begin{minipage}{\dimexpr\sosafullwidth+7.86pt\relax}%
        \sosaauthorfont\raggedright\sosa@authorline\par
      \end{minipage}\par
      % --- affiliations ----------------------------------------------------
      \ifdefempty{\sosa@affiliations}{}{%
        \vspace{\sosaskipaffil}%
        {\sosaafffont\raggedright
         \begin{enumerate}[label=\arabic*., align=left,
             labelindent=11.34pt, labelwidth=10pt, labelsep=8pt,
             leftmargin=29.34pt, itemindent=0pt,
             itemsep=0pt, parsep=0pt, topsep=0pt, partopsep=0pt]
           \sosa@affiliations
         \end{enumerate}}}%
      % --- Öz | Abstract ---------------------------------------------------
      \vspace{\sosaskipabstract}\par
      \noindent
      \begin{minipage}[t]{\sosaabstractcolwidth}%
        {\sosaozheadfont\sosaozname\par}\vspace{4pt}%
        {\sosaabstractfont\setlength{\parskip}{8pt}\justifying
         \sosa@oz
         \ifdefempty{\sosa@keywordstr}{}%
           {\par\noindent\textbf{\sosakeywordstrname} \sosa@keywordstr}\par}%
      \end{minipage}\hfill
      \begin{minipage}[t]{\sosaabstractcolwidth}%
        {\sosaozheadfont\sosaabstractname\par}\vspace{4pt}%
        {\sosaabstractfont\setlength{\parskip}{8pt}\justifying
         \sosa@abstract
         \ifdefempty{\sosa@keywordsen}{}%
           {\par\noindent\textbf{\sosakeywordsenname} \sosa@keywordsen}\par}%
      \end{minipage}%
      % --- optional acknowledgement note ------------------------------------
      \ifdefempty{\sosa@note}{}{%
        \par\vspace{\sosaskipnote}%
        {\sosanotefont\justifying\noindent\sosa@note\par}}%
    \end{minipage}}%
  \par
  \clearpage}

% ---------------------------------------------------------------------------
% 18. References
% ---------------------------------------------------------------------------
%  APA 7: hanging indent 36pt, single-spaced (11pt on 13pt), 8pt between
%  entries, justified.  The heading is one point larger than the body.
\newlength{\sosarefhang}    \setlength{\sosarefhang}{36pt}
\newlength{\sosarefleading} \setlength{\sosarefleading}{13pt}

\newlength{\sosa@refheadsize}
\setlength{\sosa@refheadsize}{\dimexpr\sosa@fontsize pt+1pt\relax}
\newcommand{\sosarefheadfont}{%
  \fontsize{\sosa@refheadsize}{16pt}\selectfont\bfseries}

\newcommand{\sosareferencesheading}{%
  \par\addvspace{24pt}%
  \phantomsection
  \addcontentsline{toc}{section}{\sosareferencesname}%
  {\sosarefheadfont\sosareferencesname\par}%
  \nopagebreak\vspace{2pt}}

% Separate entries with a blank line, as usual.
\newenvironment{sosareferences}
  {\sosareferencesheading
   \fontsize{\sosa@fontsize pt}{\sosarefleading}\selectfont
   \setlength{\parskip}{8pt}%
   \setlength{\parindent}{-\sosarefhang}%
   \setlength{\leftskip}{\sosarefhang}%
   \sloppy}
  {\par}

% If you would rather let BibLaTeX do the work: load biblatex with style=apa
% in the preamble, call \SosaStyleBibliography, then
% \printbibliography[heading=sosa].
\newcommand{\SosaStyleBibliography}{%
  \@ifundefined{defbibheading}{}{%
    \defbibheading{sosa}[\sosareferencesname]{\sosareferencesheading}%
  }}

% ---------------------------------------------------------------------------
% 19. Loaded last, as usual
% ---------------------------------------------------------------------------
\RequirePackage{tikz}
\RequirePackage[hidelinks,unicode,breaklinks]{hyperref}
\urlstyle{same}
\RequirePackage{bookmark}
\RequirePackage{microtype}

\endinput
