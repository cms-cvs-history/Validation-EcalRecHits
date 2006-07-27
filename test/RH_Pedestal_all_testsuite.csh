#!/bin/csh

# Script to run the standard Ecal RecHits Validation 
# It assumes the Digis input files and the RecHits 
# reference plots are available
#
# C. Rovelli - 20-Jul-2006

eval `scramv1 ru -csh`

setenv WORKDIR `pwd`

setenv SWSOURCE $CMSSW_RELEASE_BASE
#setenv SWSOURCE $CMSSW_BASE

setenv ECALREFDIR  /afs/cern.ch/cms/data/CMSSW/Validation/EcalRecHits/data
#setenv ECALREFDIR  `pwd`

echo "===================> Step1: executing ERHProducer (/RecoLocalCalo/EcalRecProducers/) for Pedestal_all"

/bin/rm ${WORKDIR}/Pedestal_all_testsuite1.cfg >& /dev/null

sed 's/reco-application-ecal-digitization.root/Pedestal_all_digis.root/' ${SWSOURCE}/src/Validation/EcalRecHits/test/recoUnsuppressedRecHits.cfg >&! ${WORKDIR}/Pedestal_all_testsuite1.cfg

ln -sf ${ECALREFDIR}/Pedestal_all_digis.root ${WORKDIR}/Pedestal_all_digis.root

echo cmsRun --parameter-set ${WORKDIR}/Pedestal_all_testsuite1.cfg
cmsRun --parameter-set ${WORKDIR}/Pedestal_all_testsuite1.cfg

/bin/rm ${WORKDIR}/Pedestal_all_digis.root

mv reco-application-ecal-localreco.root Pedestal_all_recHits.root



echo "===================> Step2: executing ERHAnalyser (Validation/EcalRecHits) for Pedestal_all"

/bin/rm ${WORKDIR}/Pedestal_all_testsuite2.cfg >& /dev/null

sed 's/rechits.root/Pedestal_all_recHits.root/' ${SWSOURCE}/src/Validation/EcalRecHits/test/EcalRecHitsAnalysis_test.cfg | sed 's/ecalSelectiveReadout/ecaldigi/' | sed 's/esZeroSuppression/ecaldigi/' | sed 's/ebDigis//' | sed 's/eeDigis//' >&! ${WORKDIR}/Pedestal_all_testsuite2.cfg

cmsRun --parameter-set ${WORKDIR}/Pedestal_all_testsuite2.cfg

mv EcalRecHitsValidation.root Pedestal_all_EcalRecHitsValidation_new.root
    

echo "===================> Step3: executing ROOT macro for Pedestal_all"

/bin/rm ${WORKDIR}/Pedestal_all_testsuite3.C >& /dev/null

sed 's/EcalRecHitsValidation_old.root/Pedestal_all_EcalRecHitsValidation_old.root/' ${SWSOURCE}/EcalRecHitsPlotCompare.C >&! ${WORKDIR}/Pedestal_all_testsuite3.C
sed 's/EcalRecHitsValidation_new.root/Pedestal_all_EcalRecHitsValidation_new.root/' ${WORKDIR}/Pedestal_all_testsuite3.C >&! ${WORKDIR}/Pedestal_all_testsuite4.C
sed 's/EcalRecHitsPlotCompare/Pedestal_all_testsuite5/' ${WORKDIR}/Pedestal_all_testsuite4.C >&! ${WORKDIR}/Pedestal_all_testsuite5.C

cp ${SWSOURCE}/src/Validation/EcalRecHits/test/HistoCompare.C ${WORKDIR}

cp ${SWSOURCE}/src/Validation/EcalRecHits/data/Photon_30GeV_all_EcalRecHitsValidation.root ${WORKDIR}/Pedestal_all_EcalRecHitsValidation_old.root

cp Pedestal_all_EcalRecHitsValidation_new.root ${WORKDIR}

cd ${WORKDIR} ; root -b -q ${WORKDIR}/Pedestal_all_testsuite5.C

