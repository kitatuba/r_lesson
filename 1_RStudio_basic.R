install.packages("tidyverse")
library(tidyverse)
setwd("~/R_Lesson/")

dat2 <- read_csv("SampleData/csv/sales.csv", col_types = list(col_character(), col_character(), col_datetime()))
str(dat2)

dat2 <- read_csv("SampleData/csv/sales.csv", col_types = 'ccT')

product <- read_csv("SampleData/csv/Products.csv")
head(product)

product_cp932 <- read_csv("SampleData/csv/Products_cp932.csv")
head(product_cp932)

# ファイルのエンコーディングを調べる
guess_encoding("SampleData/csv/Products.csv")

# エンコーディングを指定して読み込み
product_enc <- read_csv("SampleData/csv/Products_cp932.csv", locale = locale(encoding = "CP932"))
head(product_enc)

# ファイルの書き出し
# 標準関数 write.csvに比べて、書き込み時に余計なもの(行番号)が挿入されない
# 第一引数にオブジェクト名、第二引数にファイル名
write_csv(iris,"iris_tidy.csv")

# Excelファイルの読み込み
library(readxl)
dat_xl <- read_excel("SampleData/xlsx/sales.xlsx", sheet = 1)

# SAS: 医療系
# SPSS: 心理系
# STATA: 経済系
library(haven)
#read_sas() SAS
#read_sav() SPSS
#read_dta() STATA

# Vignette(ビニット)パッケージで詳細な解説を参照
vignette("dplyr")
