#!/bin/bash
######################################################################################
## PURPOSE: For each Zd mass point for the H-->ZdZd-->4l, quickly and easily:
##              - make MadGraph cards
##              - prepare a workspace (crab_cfg.py, stepX files)
##              - generate a new gridpack (tarball)
##              - submit any CRAB process (e.g., GEN-SIM, PUMix, AOD, MiniAOD)
## SYNTAX:  ./<scriptname.sh>
## NOTES:   User needs to do: source /cvmfs/cms.cern.ch/crab3/crab.sh before running
##          this script. 
## AUTHOR:  Jake Rosenzweig
## DATE:    2019-02-09
######################################################################################

#_____________________________________________________________________________________
# User-specific Parameters
# If you change parameters here, you have to rerun makeWorkspace=1 for them to take effect

overWrite=1 # 1 = overwrite any files and directories without prompting
masslist="125"
tarballName=HZZ4l_tarball.tar.xz
nevents=1000
njobs=500
storageSiteGEN='/store/user/klo/MLHEP/GENSIM/'

#_____________________________________________________________________________________
# User chooses which processes to run: 1 = run, 0 = don't run
makeCards=1         # New MadGraph cards
makeWorkspace=0     # run this each time you change above parameters
makeTarball=1       # MUST HAVE clean CMSSW environment, i.e. mustn't have cmsenv'ed!
submitGENSIM=0      # first run: source /cvmfs/cms.cern.ch/crab3/crab.sh 

#_____________________________________________________________________________________
# Automatic variables
startDir=`pwd`
maxjobs=$(( 5 * $njobs ))

#_____________________________________________________________________________________
# Create new MadGraph cards 
if [ ${makeCards} = 1 ]; then
    for mass in ${masslist}; do

        cardsDir=hzz_mh${mass}

        echo "Making MadGraph5 cards for ${mass} GeV in ${cardsDir}"

        cp -rT template_card/ ${cardsDir}
        cd ${cardsDir}
        sed -i "s|MASS|${mass}|g"       hzz_customizecards.dat
        #sed -i "s|MASS|${mass}|g"       hzz_param_card.dat
        cd ..

    done
    cd ${startDir}
fi

#_____________________________________________________________________________________
# Generate new tarball (gridpack) for each mass point
if [ ${makeTarball} = 1 ]; then
    #echo "Running scram b clean... cleaning"
    #scram b clean
    for mass in ${masslist}; do

        cardsDir=hzz_mh${mass}

        echo "Generating gridpack ${tarballName} for ${mass} GeV" 

        ./mkgridpack.sh hzz ${cardsDir}/

        echo "Moving log files with MadGraph cards into: ${cardsDir}"
        mv hzz/ hzz.log ${cardsDir}/
        ## Move tarball into workspace

    done

    cd ${startDir}
fi
