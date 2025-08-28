sed "s|SEQUENCEOFINTEREST|$2|g" NovelPositionClades.csv > $2.NovelPositionClades.csv
Rscript AutomatedNovelPosition.r $1 $2.NovelPositionClades.csv