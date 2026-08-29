# Two passes are needed: \begin{sosawide} records the pages that must drop
# their ornament strip in the .aux file, and that is only read back on the
# next run.  latexmk normally works this out for itself; this makes sure.
$pdf_mode = 1;              # 1 = pdflatex, 5 = xelatex, 4 = lualatex
$max_repeat = 5;
$clean_ext = 'synctex.gz run.xml bbl';
