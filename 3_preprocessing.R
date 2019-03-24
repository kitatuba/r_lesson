# tidy data: ベクトルの処理が得意なRで取り扱い易い縦長なデータ形式
# - 1つの列が1つの変数を表す
# - 1つの行が1つの観測を表す
# - 1つのテーブルが1つのデータセットだけを含む
# tidyr: データをtidy dataの形式に変形

scores_messy <- data.frame(
  名前 = c("生徒A", "生徒B"),
  算数 = c(100, 100),
  国語 = c(80, 100),
  理科 = c(60, 100),
  社会 = c(40, 20),
  stringsAsFactors = FALSE # 文字列が因子型に変換されないようにする
)

library(tidyverse)
# gather()でtidy dataに変形
scores_tidy <- gather(scores_messy,
       key = "教科", value = "点数", # 新しく出来る列の名前を指定, 新しく出来る列は"で囲む
       算数, 国語, 理科, 社会) # 変形する対象の列を指定, 既存の列は"で囲まない
# spread()で横長に戻す
spread(scores_tidy, key = 教科, value = 点数)
