require '../../.latexmkrc';

END {
    unlink qw(
      main.aux
      main.bbl
      main.bcf
      main.blg
      main.fdb_latexmk
      main.fls
      main.log
      main.nav
      main.out
      main.pdf
      main.run.xml
      main.snm
      main.synctex.gz
      main.toc
    );
}

1;
