#代码的两个功能：将栅格之间的变化情况分析到数据框中，并且根据数据框的数据绘制桑基图

# install.packages(c('raster', 'networkD3', 'dplyr', 'igraph', 'rgdal'))
# 必须的包
# 请规避运行环境中出现的任何可能的中文！！！！！！！！！！！

library(sp)
library(raster)
library(networkD3)
library(dplyr)
library(rgdal)

# define file info 注意文件的路径，不能有中文
fileInfo <- data.frame(         nodeCol=1, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/1985_clip.tif", rasterBand=1) %>%
               rbind(data.frame(nodeCol=2, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/1990_clip.tif", rasterBand=1)) %>%
               rbind(data.frame(nodeCol=3, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/1995_clip.tif", rasterBand=1)) %>%
               rbind(data.frame(nodeCol=4, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/2000_clip.tif", rasterBand=1)) %>%
               rbind(data.frame(nodeCol=5, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/2005_clip.tif", rasterBand=1)) %>%
               rbind(data.frame(nodeCol=6, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/2010_clip.tif", rasterBand=1)) %>%
               rbind(data.frame(nodeCol=7, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/2015_clip.tif", rasterBand=1)) %>%
               rbind(data.frame(nodeCol=8, rasterFile="D:/emapr_sankey_diagram_land_cover_change_demo/2020_clip.tif", rasterBand=1))

# define node info 注意数据框的信息写入，分别为节点的唯一ID，对应的栅格值，节点的所属的年份组，节点的绘图颜色组
nodeInfo <- data.frame(         nodeName="1985 Unable to classify"                                         , nodeID=0,   mapClass=0,   nodeCol=1, nodeGroup='a')  %>%
               rbind(data.frame(nodeName="1985 Rainfed cropland"                                           , nodeID=1,   mapClass=10,  nodeCol=1, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="1985 Herbaceous cover"                                           , nodeID=2,   mapClass=11,  nodeCol=1, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="1985 Tree or shrub cover (Orchard)"                              , nodeID=3,   mapClass=12,  nodeCol=1, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="1985 Irrigated cropland"                                         , nodeID=4,   mapClass=20,  nodeCol=1, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="1985 Closed evergreen broadleaved forest"                        , nodeID=5,   mapClass=52,  nodeCol=1, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="1985 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=6,   mapClass=61,  nodeCol=1, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="1985 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=7,   mapClass=62,  nodeCol=1, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="1985 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=8,   mapClass=71,  nodeCol=1, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="1985 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=9,   mapClass=72,  nodeCol=1, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="1985 Shrubland"                                                  , nodeID=10,  mapClass=120, nodeCol=1, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="1985 Deciduous shrubland"                                        , nodeID=11,  mapClass=122, nodeCol=1, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="1985 Grassland"                                                  , nodeID=12,  mapClass=130, nodeCol=1, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="1985 Sparse vegetation (fc<0.15)"                                , nodeID=13,  mapClass=150, nodeCol=1, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="1985 Wetlands"                                                   , nodeID=14,  mapClass=180, nodeCol=1, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="1985 Impervious surfaces"                                        , nodeID=15,  mapClass=190, nodeCol=1, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="1985 Bare areas"                                                 , nodeID=16,  mapClass=200, nodeCol=1, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="1985 Consolidated bare areas"                                    , nodeID=17,  mapClass=201, nodeCol=1, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="1985 Unconsolidated bare areas"                                  , nodeID=18,  mapClass=202, nodeCol=1, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="1985 Water body"                                                 , nodeID=19,  mapClass=210, nodeCol=1, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="1985 Permanent ice and snow"                                     , nodeID=20,  mapClass=220, nodeCol=1, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="1990 Unable to classify"                                         , nodeID=21,  mapClass=0,   nodeCol=2, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="1990 Rainfed cropland"                                           , nodeID=22,  mapClass=10,  nodeCol=2, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="1990 Herbaceous cover"                                           , nodeID=23,  mapClass=11,  nodeCol=2, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="1990 Tree or shrub cover (Orchard)"                              , nodeID=24,  mapClass=12,  nodeCol=2, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="1990 Irrigated cropland"                                         , nodeID=25,  mapClass=20,  nodeCol=2, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="1990 Closed evergreen broadleaved forest"                        , nodeID=26,  mapClass=52,  nodeCol=2, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="1990 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=27,  mapClass=61,  nodeCol=2, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="1990 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=28,  mapClass=62,  nodeCol=2, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="1990 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=29,  mapClass=71,  nodeCol=2, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="1990 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=30,  mapClass=72,  nodeCol=2, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="1990 Shrubland"                                                  , nodeID=31,  mapClass=120, nodeCol=2, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="1990 Deciduous shrubland"                                        , nodeID=32,  mapClass=122, nodeCol=2, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="1990 Grassland"                                                  , nodeID=33,  mapClass=130, nodeCol=2, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="1990 Sparse vegetation (fc<0.15)"                                , nodeID=34,  mapClass=150, nodeCol=2, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="1990 Wetlands"                                                   , nodeID=35,  mapClass=180, nodeCol=2, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="1990 Impervious surfaces"                                        , nodeID=36,  mapClass=190, nodeCol=2, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="1990 Bare areas"                                                 , nodeID=37,  mapClass=200, nodeCol=2, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="1990 Consolidated bare areas"                                    , nodeID=38,  mapClass=201, nodeCol=2, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="1990 Unconsolidated bare areas"                                  , nodeID=39,  mapClass=202, nodeCol=2, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="1990 Water body"                                                 , nodeID=40,  mapClass=210, nodeCol=2, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="1990 Permanent ice and snow"                                     , nodeID=41,  mapClass=220, nodeCol=2, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="1995 Unable to classify"                                         , nodeID=42,  mapClass=0,   nodeCol=3, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="1995 Rainfed cropland"                                           , nodeID=43,  mapClass=10,  nodeCol=3, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="1995 Herbaceous cover"                                           , nodeID=44,  mapClass=11,  nodeCol=3, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="1995 Tree or shrub cover (Orchard)"                              , nodeID=45,  mapClass=12,  nodeCol=3, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="1995 Irrigated cropland"                                         , nodeID=46,  mapClass=20,  nodeCol=3, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="1995 Closed evergreen broadleaved forest"                        , nodeID=47,  mapClass=52,  nodeCol=3, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="1995 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=48,  mapClass=61,  nodeCol=3, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="1995 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=49,  mapClass=62,  nodeCol=3, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="1995 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=50,  mapClass=71,  nodeCol=3, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="1995 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=51,  mapClass=72,  nodeCol=3, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="1995 Shrubland"                                                  , nodeID=52,  mapClass=120, nodeCol=3, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="1995 Deciduous shrubland"                                        , nodeID=53,  mapClass=122, nodeCol=3, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="1995 Grassland"                                                  , nodeID=54,  mapClass=130, nodeCol=3, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="1995 Sparse vegetation (fc<0.15)"                                , nodeID=55,  mapClass=150, nodeCol=3, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="1995 Wetlands"                                                   , nodeID=56,  mapClass=180, nodeCol=3, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="1995 Impervious surfaces"                                        , nodeID=57,  mapClass=190, nodeCol=3, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="1995 Bare areas"                                                 , nodeID=58,  mapClass=200, nodeCol=3, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="1995 Consolidated bare areas"                                    , nodeID=59,  mapClass=201, nodeCol=3, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="1995 Unconsolidated bare areas"                                  , nodeID=60,  mapClass=202, nodeCol=3, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="1995 Water body"                                                 , nodeID=61,  mapClass=210, nodeCol=3, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="1995 Permanent ice and snow"                                     , nodeID=62,  mapClass=220, nodeCol=3, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="2000 Unable to classify"                                         , nodeID=63,  mapClass=0,   nodeCol=4, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="2000 Rainfed cropland"                                           , nodeID=64,  mapClass=10,  nodeCol=4, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="2000 Herbaceous cover"                                           , nodeID=65,  mapClass=11,  nodeCol=4, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="2000 Tree or shrub cover (Orchard)"                              , nodeID=66,  mapClass=12,  nodeCol=4, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="2000 Irrigated cropland"                                         , nodeID=67,  mapClass=20,  nodeCol=4, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="2000 Closed evergreen broadleaved forest"                        , nodeID=68,  mapClass=52,  nodeCol=4, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="2000 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=69,  mapClass=61,  nodeCol=4, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="2000 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=70,  mapClass=62,  nodeCol=4, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="2000 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=71,  mapClass=71,  nodeCol=4, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="2000 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=72,  mapClass=72,  nodeCol=4, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="2000 Shrubland"                                                  , nodeID=73,  mapClass=120, nodeCol=4, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="2000 Evergreen shrubland"                                        , nodeID=74,  mapClass=121, nodeCol=4, nodeGroup='aa')) %>%
               rbind(data.frame(nodeName="2000 Deciduous shrubland"                                        , nodeID=75,  mapClass=122, nodeCol=4, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="2000 Grassland"                                                  , nodeID=76,  mapClass=130, nodeCol=4, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="2000 Sparse vegetation (fc<0.15)"                                , nodeID=77,  mapClass=150, nodeCol=4, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="2000 Wetlands"                                                   , nodeID=78,  mapClass=180, nodeCol=4, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="2000 Impervious surfaces"                                        , nodeID=79,  mapClass=190, nodeCol=4, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="2000 Bare areas"                                                 , nodeID=80,  mapClass=200, nodeCol=4, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="2000 Consolidated bare areas"                                    , nodeID=81,  mapClass=201, nodeCol=4, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="2000 Unconsolidated bare areas"                                  , nodeID=82,  mapClass=202, nodeCol=4, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="2000 Water body"                                                 , nodeID=83,  mapClass=210, nodeCol=4, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="2000 Permanent ice and snow"                                     , nodeID=84,  mapClass=220, nodeCol=4, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="2005 Unable to classify"                                         , nodeID=85,  mapClass=0,   nodeCol=5, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="2005 Rainfed cropland"                                           , nodeID=86,  mapClass=10,  nodeCol=5, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="2005 Herbaceous cover"                                           , nodeID=87,  mapClass=11,  nodeCol=5, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="2005 Tree or shrub cover (Orchard)"                              , nodeID=88,  mapClass=12,  nodeCol=5, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="2005 Irrigated cropland"                                         , nodeID=89,  mapClass=20,  nodeCol=5, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="2005 Closed evergreen broadleaved forest"                        , nodeID=90,  mapClass=52,  nodeCol=5, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="2005 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=91,  mapClass=61,  nodeCol=5, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="2005 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=92,  mapClass=62,  nodeCol=5, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="2005 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=93,  mapClass=71,  nodeCol=5, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="2005 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=94,  mapClass=72,  nodeCol=5, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="2005 Shrubland"                                                  , nodeID=95,  mapClass=120, nodeCol=5, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="2005 Evergreen shrubland"                                        , nodeID=96,  mapClass=121, nodeCol=5, nodeGroup='aa')) %>%
               rbind(data.frame(nodeName="2005 Deciduous shrubland"                                        , nodeID=97,  mapClass=122, nodeCol=5, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="2005 Grassland"                                                  , nodeID=98,  mapClass=130, nodeCol=5, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="2005 Sparse vegetation (fc<0.15)"                                , nodeID=99,  mapClass=150, nodeCol=5, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="2005 Wetlands"                                                   , nodeID=100,  mapClass=180, nodeCol=5, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="2005 Impervious surfaces"                                        , nodeID=101,  mapClass=190, nodeCol=5, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="2005 Bare areas"                                                 , nodeID=102,  mapClass=200, nodeCol=5, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="2005 Consolidated bare areas"                                    , nodeID=103,  mapClass=201, nodeCol=5, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="2005 Unconsolidated bare areas"                                  , nodeID=104,  mapClass=202, nodeCol=5, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="2005 Water body"                                                 , nodeID=105,  mapClass=210, nodeCol=5, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="2005 Permanent ice and snow"                                     , nodeID=106,  mapClass=220, nodeCol=5, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="2010 Unable to classify"                                         , nodeID=107,  mapClass=0,   nodeCol=6, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="2010 Rainfed cropland"                                           , nodeID=108,  mapClass=10,  nodeCol=6, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="2010 Herbaceous cover"                                           , nodeID=109,  mapClass=11,  nodeCol=6, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="2010 Tree or shrub cover (Orchard)"                              , nodeID=110,  mapClass=12,  nodeCol=6, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="2010 Irrigated cropland"                                         , nodeID=111,  mapClass=20,  nodeCol=6, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="2010 Closed evergreen broadleaved forest"                        , nodeID=112,  mapClass=52,  nodeCol=6, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="2010 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=113,  mapClass=61,  nodeCol=6, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="2010 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=114,  mapClass=62,  nodeCol=6, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="2010 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=115,  mapClass=71,  nodeCol=6, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="2010 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=116,  mapClass=72,  nodeCol=6, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="2010 Shrubland"                                                  , nodeID=117,  mapClass=120, nodeCol=6, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="2010 Evergreen shrubland"                                        , nodeID=118,  mapClass=121, nodeCol=6, nodeGroup='aa')) %>%
               rbind(data.frame(nodeName="2010 Deciduous shrubland"                                        , nodeID=119,  mapClass=122, nodeCol=6, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="2010 Grassland"                                                  , nodeID=120,  mapClass=130, nodeCol=6, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="2010 Sparse vegetation (fc<0.15)"                                , nodeID=121,  mapClass=150, nodeCol=6, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="2010 Wetlands"                                                   , nodeID=122,  mapClass=180, nodeCol=6, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="2010 Impervious surfaces"                                        , nodeID=123,  mapClass=190, nodeCol=6, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="2010 Bare areas"                                                 , nodeID=124,  mapClass=200, nodeCol=6, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="2010 Consolidated bare areas"                                    , nodeID=125,  mapClass=201, nodeCol=6, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="2010 Unconsolidated bare areas"                                  , nodeID=126,  mapClass=202, nodeCol=6, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="2010 Water body"                                                 , nodeID=127,  mapClass=210, nodeCol=6, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="2010 Permanent ice and snow"                                     , nodeID=128,  mapClass=220, nodeCol=6, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="2015 Unable to classify"                                         , nodeID=129,  mapClass=0,   nodeCol=7, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="2015 Rainfed cropland"                                           , nodeID=130,  mapClass=10,  nodeCol=7, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="2015 Herbaceous cover"                                           , nodeID=131,  mapClass=11,  nodeCol=7, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="2015 Tree or shrub cover (Orchard)"                              , nodeID=132,  mapClass=12,  nodeCol=7, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="2015 Irrigated cropland"                                         , nodeID=133,  mapClass=20,  nodeCol=7, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="2015 Closed evergreen broadleaved forest"                        , nodeID=134,  mapClass=52,  nodeCol=7, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="2015 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=135,  mapClass=61,  nodeCol=7, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="2015 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=136,  mapClass=62,  nodeCol=7, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="2015 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=137,  mapClass=71,  nodeCol=7, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="2015 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=138,  mapClass=72,  nodeCol=7, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="2015 Shrubland"                                                  , nodeID=139,  mapClass=120, nodeCol=7, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="2015 Deciduous shrubland"                                        , nodeID=140,  mapClass=122, nodeCol=7, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="2015 Grassland"                                                  , nodeID=141,  mapClass=130, nodeCol=7, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="2015 Sparse vegetation (fc<0.15)"                                , nodeID=142,  mapClass=150, nodeCol=7, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="2015 Wetlands"                                                   , nodeID=143,  mapClass=180, nodeCol=7, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="2015 Impervious surfaces"                                        , nodeID=144,  mapClass=190, nodeCol=7, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="2015 Bare areas"                                                 , nodeID=145,  mapClass=200, nodeCol=7, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="2015 Consolidated bare areas"                                    , nodeID=146,  mapClass=201, nodeCol=7, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="2015 Unconsolidated bare areas"                                  , nodeID=147,  mapClass=202, nodeCol=7, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="2015 Water body"                                                 , nodeID=148,  mapClass=210, nodeCol=7, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="2015 Permanent ice and snow"                                     , nodeID=149,  mapClass=220, nodeCol=7, nodeGroup='u')) %>%

               rbind(data.frame(nodeName="2020 Unable to classify"                                         , nodeID=150,  mapClass=0,   nodeCol=8, nodeGroup='a')) %>% 
               rbind(data.frame(nodeName="2020 Rainfed cropland"                                           , nodeID=151,  mapClass=10,  nodeCol=8, nodeGroup='b')) %>%
               rbind(data.frame(nodeName="2020 Herbaceous cover"                                           , nodeID=152,  mapClass=11,  nodeCol=8, nodeGroup='c')) %>%
               rbind(data.frame(nodeName="2020 Tree or shrub cover (Orchard)"                              , nodeID=153,  mapClass=12,  nodeCol=8, nodeGroup='d')) %>%
               rbind(data.frame(nodeName="2020 Irrigated cropland"                                         , nodeID=154,  mapClass=20,  nodeCol=8, nodeGroup='e')) %>%
               rbind(data.frame(nodeName="2020 Open evergreen broadleaved forest"                          , nodeID=155,  mapClass=51,  nodeCol=8, nodeGroup='bb')) %>% 
               rbind(data.frame(nodeName="2020 Closed evergreen broadleaved forest"                        , nodeID=156,  mapClass=52,  nodeCol=8, nodeGroup='f')) %>%
               rbind(data.frame(nodeName="2020 Open deciduous broadleaved forest (0.15<fc<0.4)"            , nodeID=157,  mapClass=61,  nodeCol=8, nodeGroup='g')) %>%
               rbind(data.frame(nodeName="2020 Closed deciduous broadleaved forest (fc>0.4)"               , nodeID=158,  mapClass=62,  nodeCol=8, nodeGroup='h')) %>%
               rbind(data.frame(nodeName="2020 Open evergreen needle-leaved forest (0.15< fc <0.4)"        , nodeID=159,  mapClass=71,  nodeCol=8, nodeGroup='i')) %>%
               rbind(data.frame(nodeName="2020 Closed evergreen needle-leaved forest (fc >0.4)"            , nodeID=160,  mapClass=72,  nodeCol=8, nodeGroup='j')) %>%
               rbind(data.frame(nodeName="2020 Open deciduous needle-leaved forest (0.15< fc <0.4)y"       , nodeID=161,  mapClass=81,  nodeCol=8, nodeGroup='cc')) %>% 
               rbind(data.frame(nodeName="2020 Closed deciduous needle-leaved forest (fc >0.4)"            , nodeID=162,  mapClass=82,  nodeCol=8, nodeGroup='dd')) %>% 
               rbind(data.frame(nodeName="2020 Shrubland"                                                  , nodeID=163,  mapClass=120, nodeCol=8, nodeGroup='k')) %>%
               rbind(data.frame(nodeName="2020 Evergreen shrubland"                                        , nodeID=164,  mapClass=121, nodeCol=8, nodeGroup='aa')) %>% 
               rbind(data.frame(nodeName="2020 Deciduous shrubland"                                        , nodeID=165,  mapClass=122, nodeCol=8, nodeGroup='l')) %>%
               rbind(data.frame(nodeName="2020 Grassland"                                                  , nodeID=166,  mapClass=130, nodeCol=8, nodeGroup='m')) %>%
               rbind(data.frame(nodeName="2020 Sparse vegetation (fc<0.15)"                                , nodeID=167,  mapClass=150, nodeCol=8, nodeGroup='n')) %>%
               rbind(data.frame(nodeName="2020 Wetlands"                                                   , nodeID=168,  mapClass=180, nodeCol=8, nodeGroup='o')) %>%
               rbind(data.frame(nodeName="2020 Impervious surfaces"                                        , nodeID=169,  mapClass=190, nodeCol=8, nodeGroup='p')) %>%
               rbind(data.frame(nodeName="2020 Bare areas"                                                 , nodeID=170,  mapClass=200, nodeCol=8, nodeGroup='q')) %>%
               rbind(data.frame(nodeName="2020 Consolidated bare areas"                                    , nodeID=171,  mapClass=201, nodeCol=8, nodeGroup='r')) %>%
               rbind(data.frame(nodeName="2020 Unconsolidated bare areas"                                  , nodeID=172,  mapClass=202, nodeCol=8, nodeGroup='s')) %>%
               rbind(data.frame(nodeName="2020 Water body"                                                 , nodeID=173,  mapClass=210, nodeCol=8, nodeGroup='t')) %>%
               rbind(data.frame(nodeName="2020 Permanent ice and snow"                                     , nodeID=174,  mapClass=220, nodeCol=8, nodeGroup='u')) 


# define group color - note that the colors correspond to the nodeGroups, one for each unique group, we have used (a, b, c, d, e, f) - color is applied in order
#节点的绘图颜色组，给节点组赋予颜色

groupColor <- c("#0000CD","#E29E8C", "#FF0000", "#B50000", "#D2CDC0", "#DCCA8F","#E8D1D1","#E29E8C", "#FF0000", "#B50000", "#D2CDC0", "#DCCA8F","#E8D1D1","#0000CD", "#FF0000", "#B50000", "#D2CDC0", "#DCCA8F","#E8D1D1","#E29E8C", "#00FA9A", "#B50000", "#D2CDC0", "#DCCA8F")

# define plot features，设置字体
fontSize <- 10
fontFamily <- "Times-New-Roman"
nodeWidth <- 20

# collapse groupColor to a string
groupColor <- paste0('"',paste(groupColor, collapse = '", "'),'"')

# join fileInfo to nodeInfo
nodeInfo <- dplyr::left_join(nodeInfo, fileInfo, by='nodeCol')

# convert factors to characters
nodeInfo$nodeName <- as.character(nodeInfo$nodeName)
nodeInfo$rasterFile <- as.character(nodeInfo$rasterFile)

# define the links，分析土地利用转移的情况
NodeCols <- sort(unique(nodeInfo$nodeCol))
linkInfo <- data.frame()
for(i in 1:(length(NodeCols)-1)){
  fromCol <- dplyr::filter(nodeInfo, nodeCol==NodeCols[i])
  toCol <- dplyr::filter(nodeInfo, nodeCol==NodeCols[i+1])
  fromR <- values(raster(fromCol$rasterFile[1], fromCol$rasterBand[1]))
  toR <- values(raster(toCol$rasterFile[1], toCol$rasterBand[1]))
  for(f in 1:nrow(fromCol)){
    for(t in 1:nrow(toCol)){
      nFromTo <- length(which(fromR == fromCol$mapClass[f] & toR == toCol$mapClass[t]))
      linkInfo <- rbind(linkInfo, data.frame(source=fromCol$nodeID[f], target=toCol$nodeID[t], value=nFromTo))
    }
  }
}

# 将链接分组，分为Lgroup，和NodeGroup一样，为了后续的绘图上色使用，但是分组规则是后面的nodeGroup
linkInfo$LGroup <- sub(' .*', '', nodeInfo[linkInfo$source + 1, 'nodeGroup'])

# make the sankey plot，绘制桑基图的部分，请参考库的使用指导
sankeyNetwork(

              Links = linkInfo, 
              Nodes = nodeInfo,
              Source = "source",
              Target = "target",
              Value = "value",
              NodeID = "nodeName",
              NodeGroup = "nodeGroup",
              LinkGroup = "LGroup",
              fontSize = fontSize,
              fontFamily = fontFamily,
              nodeWidth = nodeWidth,

              height = 1500,
              width = 2000,

              colourScale = paste0('d3.scaleOrdinal().range([',groupColor,'])')

              )
