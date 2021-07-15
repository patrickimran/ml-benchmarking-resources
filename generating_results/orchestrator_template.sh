#!/bin/bash

DATASETS=( imsms imsms sol sol finrisk finrisk )
LEVELS="16S MG"

TARGETS=( bmi age bmi_v2 age_v2 BMI BL_AGE )
DISCRETE=False


PPN=( 1 1 4 4 4 4 1 1 1 1 1 4 4 1 1 )
ALGORITHMS=( RidgeRegressor LinearSVR RandomForestRegressor XGBRegressor LGBMRegressor_RF LGBMRegressor_GBDT ElasticNet GradientBoostingRegressor AdaBoostRegressor RadialSVR SigmoidSVR HistGradientBoostingRegressor ExtraTreesRegressor  Lasso MLPRegressor )

# Output shell script (run this to submit jobs)
OUTSCRIPT="doctor_all_algorithms_submit.sh"

rm $OUTSCRIPT

for i in ${!TARGETS[*]}
do
    TARGET=${TARGETS[$i]}
    DATASET=${DATASETS[$i]}
    for LEVEL in ${LEVELS}
    do
        echo ${DATASET} ${LEVEL} ${TARGET}
        
        for j in ${!ALGORITHMS[*]}
        do
            ALGORITHM=${ALGORITHMS[$j]}
            
            mlab-orchestrator ${DATASET} ${LEVEL} ${TARGET} ${ALGORITHM} --ppn ${PPN[$idx]} --chunk_size 50 --base_dir ./processed/ --wall 500

        done
    done
done