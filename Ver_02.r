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
fileInfo <- data.frame(nodeCol=1, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_1985_clip.tif", rasterBand=1) %>%
 rbind(data.frame(nodeCol=2, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_1990_clip.tif", rasterBand=1)) %>%
 rbind(data.frame(nodeCol=3, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_1995_clip.tif", rasterBand=1)) %>%
 rbind(data.frame(nodeCol=4, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_2000_clip.tif", rasterBand=1)) %>%
 rbind(data.frame(nodeCol=5, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_2005_clip.tif", rasterBand=1)) %>%
 rbind(data.frame(nodeCol=6, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_2010_clip.tif", rasterBand=1)) %>%
 rbind(data.frame(nodeCol=7, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_2015_clip.tif", rasterBand=1)) %>%
 rbind(data.frame(nodeCol=8, rasterFile="G:/Bachelor_Degree_Thesis/DATA/LUCC_30m_WHU/Extracted/CLCD_v01_2019_clip.tif", rasterBand=1))

# define node info 注意数据框的信息写入，分别为节点的唯一ID，对应的栅格值，节点的所属的年份组，节点的绘图颜色组
# mapclass就是栅格value
# NodeID 要按照顺序输入
# nodeCol 是分组
# nodeGroup，加颜色要用

nodeInfo <- data.frame(         nodeName="1985 Cropland"                           , nodeID=0,   mapClass=1,  nodeCol=1, nodeGroup='a')  %>%
 rbind(data.frame(nodeName="1985 Forest"                                           , nodeID=1,   mapClass=2,  nodeCol=1, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="1985 Shrub"                                            , nodeID=2,   mapClass=3,  nodeCol=1, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="1985 Grassland"                                        , nodeID=3,   mapClass=4,  nodeCol=1, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="1985 Water"                                            , nodeID=4,   mapClass=5,  nodeCol=1, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="1985 Sonw/Ice"                                         , nodeID=5,   mapClass=6,  nodeCol=1, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="1985 Barren"                                           , nodeID=6,   mapClass=7,  nodeCol=1, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="1985 Impervious"                                       , nodeID=7,   mapClass=8,  nodeCol=1, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="1985 Wetland"                                          , nodeID=8,   mapClass=9,  nodeCol=1, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="1990 Cropland"                                         , nodeID=9,   mapClass=1,  nodeCol=2, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="1990 Forest"                                           , nodeID=10,  mapClass=2,  nodeCol=2, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="1990 Shrub"                                            , nodeID=11,  mapClass=3,  nodeCol=2, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="1990 Grassland"                                        , nodeID=12,  mapClass=4,  nodeCol=2, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="1990 Water"                                            , nodeID=13,  mapClass=5,  nodeCol=2, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="1990 Sonw/Ice"                                         , nodeID=14,  mapClass=6,  nodeCol=2, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="1990 Barren"                                           , nodeID=15,  mapClass=7,  nodeCol=2, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="1990 Impervious"                                       , nodeID=16,  mapClass=8,  nodeCol=2, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="1990 Wetland"                                          , nodeID=17,  mapClass=9,  nodeCol=2, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="1995 Cropland"                                         , nodeID=18,  mapClass=1,  nodeCol=3, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="1995 Forest"                                           , nodeID=19,  mapClass=2,  nodeCol=3, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="1995 Shrub"                                            , nodeID=20,  mapClass=3,  nodeCol=3, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="1995 Grassland"                                        , nodeID=21,  mapClass=4,  nodeCol=3, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="1995 Water"                                            , nodeID=22,  mapClass=5,  nodeCol=3, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="1995 Sonw/Ice"                                         , nodeID=23,  mapClass=6,  nodeCol=3, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="1995 Barren"                                           , nodeID=24,  mapClass=7,  nodeCol=3, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="1995 Impervious"                                       , nodeID=25,  mapClass=8,  nodeCol=3, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="1995 Wetland"                                          , nodeID=26,  mapClass=9,  nodeCol=3, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="2000 Cropland"                                         , nodeID=27,  mapClass=1,  nodeCol=4, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="2000 Forest"                                           , nodeID=28,  mapClass=2,  nodeCol=4, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="2000 Shrub"                                            , nodeID=29,  mapClass=3,  nodeCol=4, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="2000 Grassland"                                        , nodeID=30,  mapClass=4,  nodeCol=4, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="2000 Water"                                            , nodeID=31,  mapClass=5,  nodeCol=4, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="2000 Sonw/Ice"                                         , nodeID=32,  mapClass=6,  nodeCol=4, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="2000 Barren"                                           , nodeID=33,  mapClass=7,  nodeCol=4, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="2000 Impervious"                                       , nodeID=34,  mapClass=8,  nodeCol=4, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="2000 Wetland"                                          , nodeID=35,  mapClass=9,  nodeCol=4, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="2005 Cropland"                                         , nodeID=36,  mapClass=1,  nodeCol=5, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="2005 Forest"                                           , nodeID=37,  mapClass=2,  nodeCol=5, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="2005 Shrub"                                            , nodeID=38,  mapClass=3,  nodeCol=5, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="2005 Grassland"                                        , nodeID=39,  mapClass=4,  nodeCol=5, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="2005 Water"                                            , nodeID=40,  mapClass=5,  nodeCol=5, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="2005 Sonw/Ice"                                         , nodeID=41,  mapClass=6,  nodeCol=5, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="2005 Barren"                                           , nodeID=42,  mapClass=7,  nodeCol=5, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="2005 Impervious"                                       , nodeID=43,  mapClass=8,  nodeCol=5, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="2005 Wetland"                                          , nodeID=44,  mapClass=9,  nodeCol=5, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="2010 Cropland"                                         , nodeID=45,  mapClass=1,  nodeCol=6, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="2010 Forest"                                           , nodeID=46,  mapClass=2,  nodeCol=6, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="2010 Shrub"                                            , nodeID=47,  mapClass=3,  nodeCol=6, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="2010 Grassland"                                        , nodeID=48,  mapClass=4,  nodeCol=6, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="2010 Water"                                            , nodeID=49,  mapClass=5,  nodeCol=6, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="2010 Sonw/Ice"                                         , nodeID=50,  mapClass=6,  nodeCol=6, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="2010 Barren"                                           , nodeID=51,  mapClass=7,  nodeCol=6, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="2010 Impervious"                                       , nodeID=52,  mapClass=8,  nodeCol=6, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="2010 Wetland"                                          , nodeID=53,  mapClass=9,  nodeCol=6, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="2015 Cropland"                                         , nodeID=54,  mapClass=1,  nodeCol=7, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="2015 Forest"                                           , nodeID=55,  mapClass=2,  nodeCol=7, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="2015 Shrub"                                            , nodeID=56,  mapClass=3,  nodeCol=7, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="2015 Grassland"                                        , nodeID=57,  mapClass=4,  nodeCol=7, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="2015 Water"                                            , nodeID=58,  mapClass=5,  nodeCol=7, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="2015 Snow/Ice"                                         , nodeID=59,  mapClass=6,  nodeCol=7, nodeGroup='f')) %>%
 rbind(data.frame(nodeName="2015 Barren"                                           , nodeID=60,  mapClass=7,  nodeCol=7, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="2015 Impervious"                                       , nodeID=61,  mapClass=8,  nodeCol=7, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="2015 Wetland"                                          , nodeID=62,  mapClass=9,  nodeCol=7, nodeGroup='i')) %>%
 
 rbind(data.frame(nodeName="2019 Cropland"                                         , nodeID=63,  mapClass=1,  nodeCol=8, nodeGroup='a')) %>% 
 rbind(data.frame(nodeName="2019 Forest"                                           , nodeID=64,  mapClass=2,  nodeCol=8, nodeGroup='b')) %>%
 rbind(data.frame(nodeName="2019 Shrub"                                            , nodeID=65,  mapClass=3,  nodeCol=8, nodeGroup='c')) %>%
 rbind(data.frame(nodeName="2019 Grassland"                                        , nodeID=66,  mapClass=4,  nodeCol=8, nodeGroup='d')) %>%
 rbind(data.frame(nodeName="2019 Water"                                            , nodeID=67,  mapClass=5,  nodeCol=8, nodeGroup='e')) %>%
 rbind(data.frame(nodeName="2019 Sonw/Ice"                                         , nodeID=68,  mapClass=6,  nodeCol=8, nodeGroup='f')) %>% 
 rbind(data.frame(nodeName="2019 Barren"                                           , nodeID=69,  mapClass=7,  nodeCol=8, nodeGroup='g')) %>%
 rbind(data.frame(nodeName="2019 Impervious"                                       , nodeID=70,  mapClass=8,  nodeCol=8, nodeGroup='h')) %>%
 rbind(data.frame(nodeName="2019 Wetland"                                          , nodeID=71,  mapClass=9,  nodeCol=8, nodeGroup='i')) 
# 记得删除最后一行的%号，不然会导致数据写入错误。

# define plot features，设置字体
fontSize <- 15
fontFamily <- "Times-New-Roman"
nodeWidth <- 20
#节点宽度

# define group color - note that the colors correspond to the nodeGroups, one for each unique group, we have used (a, b, c, d, e, f) - color is applied in order
# 节点的绘图颜色组，给节点组赋予颜色
groupColor <- c("#FAE39C","#446F33", "#33A02C", "#ABD37B", "#1E69B4", "#A6CEE3","#CFBDA3","#E24290", "#289BE8")
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
              
              height = 1300,
              width = 2500,
              
              colourScale = paste0('d3.scaleOrdinal().range([',groupColor,'])')
              
              )

C <- sankeyNetwork(
 
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
 
                    height = 1300,
                    width = 2500,
 
                    colourScale = paste0('d3.scaleOrdinal().range([',groupColor,'])')
 
                    )

saveNetwork(C, "C:/Users/Charlie林川/Desktop/C.html")
              
