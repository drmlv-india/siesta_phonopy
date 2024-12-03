#!/bin/bash
#======================================================#
#Script:mlv_siesta_phonopy  for phonon run             #
#======================================================#
# Author: Mohan L Verma,                               #
#        Computational Nanoionics Research lab,        #  
#        Department of Applied Physics,                #
#        SSGI, Shri Shanakaracharya Technical          # 
#        Campus-Junwani Bhilai(Chhattisgarh)  INDIA    #
#        Aug 2021 ver-1                                #
# Commands to run this example:                        #
# $ sh mlv_siesta_phonopy.sh                           #
# Before runing the script make sure that *.psf files  # 
# and phonopy tool has been installed properly         #
# If not install it using tutorial enclosed here       #
#===================================================== #
 
head="
SystemName  Ti3Au_cubic221
SystemLabel Ti3Au_cubic221

NumberOfSpecies     2

%block ChemicalSpeciesLabel
    1   22  Ti
    2   79  Au
%endblock ChemicalSpeciesLabel


PAO.BasisSize       sz

MeshCutoff         450.0 Ry

MaxSCFIterations    50
SCF.MustConverge     .false.
DM.MixingWeight      0.001
DM.NumberPulay       5
DM.Tolerance         1.d-4
DM.UseSaveDM

SolutionMethod       diagon

WriteForces          .true.

ElectronicTemperature  100 K

AtomicCoordinatesFormat  Fractional
"

kgrid_uc="
%block kgrid_Monkhorst_Pack
   5   0   0  0.0
   0   5   0  0.0
   0   0   5  0.0
%endblock Kgrid_Monkhorst_Pack
"

kgrid_sc="
%block kgrid_Monkhorst_Pack
   3   0   0  0.0
   0   3   0  0.0
   0   0   3  0.0
%endblock Kgrid_Monkhorst_Pack
"

atoms_uc="
NumberOfAtoms       4

LatticeConstant 1.0 Bohr 

%block LatticeVectors
    7.701638079   0.000000    0.000000
    0.000000    7.701638079    0.000000
    0.000000    0.000000       7.701638079
%endblock LatticeVectors

%block AtomicCoordinatesAndAtomicSpecies
    0.50000000    0.00000000    0.50000000   1       1  Ti
    0.00000000    0.50000000    0.50000000   1       2  Ti
    0.50000000    0.50000000    0.00000000   1       3  Ti
    0.00000000    0.00000000    0.00000000   2       4  Au
%endblock AtomicCoordinatesAndAtomicSpecies
" 
echo "$head" >> phonopy_siesta.fdf
echo "$kgrid_uc" >> phonopy_siesta.fdf
echo "$atoms_uc" >> phonopy_siesta.fdf
phonopy --siesta -d --dim="3 3 3" -c phonopy_siesta.fdf --amplitude=0.04

for i in `seq -w 001 001 002`  
do

mkdir disp-$i
cp *.psf supercell-$i.fdf disp-$i
cd disp-$i
echo "$head" > phonopy_siesta.fdf
echo "$kgrid_sc" >> phonopy_siesta.fdf
echo "LatticeConstant 1.0 Bohr">> phonopy_siesta.fdf
echo "%include supercell-$i.fdf" >> phonopy_siesta.fdf
mpirun -np 6 siesta phonopy_siesta.fdf | tee phonopy_siesta.out
cd ..

done

phonopy --siesta -f disp-*/Ti3Au_cubic221.FA

cat > band.conf << EOF
ATOM_NAME = Ti Au  
DIM =  3 3 3
BAND_POINTS = 100
BAND = 0.0 0.0 0.0  0.0 1/2 0.0  1/2 1/2 0.0  0.0 0.0 0.0  1/2 1/2 1/2  0.0 1/2 0.0  1/2 1/2 0.0
BAND_LABELS = $\Gamma$ X M $\Gamma$ R X/R M  # will work if latex is installed.
BAND_CONNECTION = .TRUE.

EOF
phonopy --siesta -p band.conf -c phonopy_siesta.fdf


  
#you can give feedback in:-
# drmohanlv@gmail.com  OR  9303452648  
# we can also disscuss some problem regarding to this."
#================================================================================================
