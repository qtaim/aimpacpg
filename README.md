Instructions for installation of new AIMPAC programs.

1. Download the file aimpacpg.zip or aimpacpg.tar.Z. Inside you will find the
following files:

contorpg.f, grdvecpg.f - modified versions of contor and grdvec.
                         These should replace the sourcefiles 
                         downloaded in aimpac.zip.

hereplot.f - a link command sourcefile for installation.

compilepg.csh - the command file that compiles the programs.

Make sure all 4 files are in the same directory, preferably your aimpac 
directory, for simplicity.

2. Download and install the PGPLOT graphics library from the website indicated.
 Please be careful in following the instructions for installation, and make 
note of where the library has been installed on the directory tree. 
PLEASE direct any problems with installation to the CalTech site, not us.

3. Modify compilepg.csh. Here is the file in full:

****

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

****

You will have to modify this file to reflect your own system; these settings 
are for our computer:
	
	FORT: the fortran compiler on your computer.
	LIBPG: the location of the libpgplot.a file, which is the 
               library that contor and grdvec will link to during 
               compiling.
	LIBX11: where the X11 library is on your computer. This is 
                particular to a computer that has Xwindows installed 
                on it; if Xwindows is not installed, omit this line, 
                and the -lbsd $LIBX11 section of line 8.

Note on line 7, ( foreach i ( contor grdvec ) ): the compiler will look for 
the files contor.f and grdvec.f. PLEASE remember that the files provided are 
contorpg.f and grdvecpg.f, solely in order to differentiate them from the 
contor.f and grdvec.f provided in aimpac.zip. Either replace the old contor.f 
and grdvec.f with the new files, or change line 7 to reflect the different 
names.

Note on line 8, ( $FORT -O -o $i  $i.f hereplot.o $LIBPG -lc -lbsd $LIBX11 ): 
Please note that the settings -lc and -lbsd $LIBX11 may not necessarily be 
correct for your compiler, or there may be necessary options that are not 
listed. Please consult your compiler program manual for what the correct 
settings should be. PLEASE do not e-mail us if these settings are not correct; 
we dont know what machine or compiler you are using, and therefore cannot tell 
you how to modify your compiler options.

4. Set the file compilepg.csh to executable, ie. x compilepg.csh.

5. run the executable compilepg.csh, which will compile the programs, with the 
appropriate links to the PGPLOT library.


Instructions for use of new AIMPAC programs.

1. Run gridv as normal, to generate .grd file.

2. Run command:

	contorpg grdfile xw|psfile

where grdfile is the name of the .grd file (without the .grd suffix). The 
second option can either be typed in as xw, which must be used in conjunction 
with Xwindows, or the desired filename for the postscript file that will be 
generated (without the .ps suffix).
This will generate a contour plot as described in the gridv manual.

3. Run command:

	grdvecpg vecfile wfnfile xw|psfile

where vecfile is the input .vec file, and wfnfile is the .wfn file.
This will generate a gradient vector plot, as described in the grdvec manual.

Using Postscript: If you are generating postscript files, you must have a 
postscript viewer, or a postscript compatible printer. Note that these two 
programs generate separate postscript files that are meant to be viewed 
together; the contour plot of rho, for example, provided by contor, with the 
interatomic paths and zero-flux surfaces provided by grdvec. The two postscript
files can be merged by whatever software program you have available, or by 
manual modification of the files, which we leave to you.
