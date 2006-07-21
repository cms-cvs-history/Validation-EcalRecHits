#!/bin/csh

# Script to run the standard Ecal RecHits Validation 
# It assumes the Digis input files and the RecHits 
# reference plots are available
#
# C. Rovelli - 20-Jul-2006

eval `scramv1 ru -csh`

setenv WORKDIR `pwd`

setenv SWSOURCE $CMSSW_RELEASE_BASE

setenv ECALREFDIR  /afs/cern.ch/cms/data/CMSSW/Validation/EcalRecHits/data
#setenv ECALREFDIR  `pwd`

echo "===================> Step1: executing ERHProducer (/RecoLocalCalo/EcalRecProducers/) for Photon_E30GeV_all"

/bin/rm ${WORKDIR}/Photon_E30GeV_all_testsuite1.cfg >& /dev/null

sed 's/reco-application-ecal-digitization.root/Photon_E30GeV_all_digis.root/' ${CMSSW_BASE}/src/Configuration/Applications/data/reco-application-ecal-localreco.cfg >&! ${WORKDIR}/Photon_E30GeV_all_testsuite1.cfg

ln -sf ${ECALREFDIR}/Photon_E30GeV_all_digis.root ${WORKDIR}/Photon_E30GeV_all_digis.root

echo cmsRun --parameter-set ${WORKDIR}/Photon_E30GeV_all_testsuite1.cfg
cmsRun --parameter-set ${WORKDIR}/Photon_E30GeV_all_testsuite1.cfg

/bin/rm ${WORKDIR}/Photon_E30GeV_all_digis.root

mv reco-application-ecal-localreco.root Photon_E30GeV_all_recHits.root



echo "===================> Step2: executing ERHAnalyser (Validation/EcalRecHits) for Photon_E30GeV_all"

/bin/rm ${WORKDIR}/Photon_E30GeV_all_testsuite2.cfg >& /dev/null

sed 's/rechits.root/Photon_E30GeV_all_recHits.root/' ${SWSOURCE}/src/Validation/EcalRecHits/test/EcalRecHitsAnalysis_test.cfg >&! ${WORKDIR}/Photon_E30GeV_all_testsuite2.cfg

cmsRun --parameter-set ${WORKDIR}/Photon_E30GeV_all_testsuite2.cfg

mv EcalRecHitsValidation.root Photon_E30GeV_all_EcalRecHitsValidation_new.root
    

echo "===================> Step3: executing ROOT macro for Photon_E30GeV_all"

/bin/rm ${WORKDIR}/Photon_E30GeV_all_testsuite3.C >& /dev/null

sed 's/EcalRecHitsValidation_old.root/Photon_E30GeV_all_EcalRecHitsValidation_old.root/' ${SWSOURCE}/EcalRecHitsPlotCompare.C >&! ${WORKDIR}/Photon_E30GeV_all_testsuite3.C
sed 's/EcalRecHitsValidation_new.root/Photon_E30GeV_all_EcalRecHitsValidation_new.root/' ${WORKDIR}/Photon_E30GeV_all_testsuite3.C >&! ${WORKDIR}/Photon_E30GeV_all_testsuite4.C
sed 's/EcalRecHitsPlotCompare/Photon_E30GeV_all_testsuite5/' ${WORKDIR}/Photon_E30GeV_all_testsuite4.C >&! ${WORKDIR}/Photon_E30GeV_all_testsuite5.C

cp ${SWSOURCE}/src/Validation/EcalRecHits/test/HistoCompare.C ${WORKDIR}

cp ${SWSOURCE}/src/Validation/EcalRecHits/data/Photon_30GeV_all_EcalRecHitsValidation.root ${WORKDIR}/Photon_E30GeV_all_EcalRecHitsValidation_old.root

cp Photon_E30GeV_all_EcalRecHitsValidation_new.root ${WORKDIR}

cd ${WORKDIR} ; root -b -q ${WORKDIR}/Photon_E30GeV_all_testsuite5.C

