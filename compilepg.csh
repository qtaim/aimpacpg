#! /bin/csh
unalias rm
set FORT=g77
set LIBPG="/home/progs/pgplot/pgplot/libpgplot.a"
set LIBX11="-L /usr/X11R6/lib -lX11"
$FORT -c hereplot.f
foreach i ( contor grdvec )
  $FORT -O -o $i  $i.f hereplot.o $LIBPG -lc -lbsd $LIBX11 
end
rm hereplot.o
