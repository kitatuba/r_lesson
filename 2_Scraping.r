# h1要素 <h1>見出し</h1>
# href属性, "http://gihyo.jp/book"値　<a href="http://gihyo.jp/book">ページ1</a>
# CSSセレクタ HTML内の要素を判別してスタイルを適用、HTML内の特定の要素にアクセス可能
# XML Path Language(XPath) XMLの特定の箇所にアクセスするための構文, HTMLの要素もアクセス可能
# スクレイピングは、CSSセレクタかXPathを用いる
# URLを読み込み、DOMのノード(HTML中の要素または属性)にアクセスして、値を取得すること

install.packages("tidyverse")
# rvestパッケージが代表的
library(rvest)

kabu_url <- "https://kabutan.jp/stock/kabuka?code=0000"
# 対象URLの読み込み,DOM(Document Object Model)として変形、保存
url_res <- read_html(kabu_url)
# URLの読み込み結果からtitle要素を抽出, CSSセレクタは動作せず
url_titile <- html_nodes(url_res, xpath = "/html/head/title")
# 人間が解読できるよう変換
title <- html_text(url_titile)

# パイプ演算子 これまでの処理を次の関数の第一引数として渡す
#  magritrパッケージに含まれている
#  tidyverseの主要パッケージは依存しているので、読み込まれる
# URL読み込みから変換までをワンライナー
title2 <- read_html(kabu_url) %>% 
  html_nodes(xpath = "/html/head/title") %>% 
  html_text()

# stock_kabuka_tableという値のid属性のテーブルの2番目をスクレイピングし、Rのデータフレームとして取り込む
# 先頭10行を表示
read_html(kabu_url) %>% 
  html_node(xpath = "//*[@id='stock_kabuka_table']/table[2]") %>% 
  html_table() %>% 
  head(10)

# 複数ページのスクレイピング
library(dplyr)
# https://kabutan.jp/stock/kabuka?code=0000&ashi=day&page=2
# for分の中で利用するオブジェクトを宣言しておく
urls <- NULL
kabukas <- list()

base_url <- "https://kabutan.jp/stock/kabuka?code=0000&ashi=day&page="
xpath <- "//*[@id='stock_kabuka_table']/table[2]"
for (i in 1:5) {
  # ページ番号付きのURLを生成
  urls[i] <- paste0(base_url, as.character(i))
  
  # 生成したURLを基にスクレイピング
  kabukas[[i]] <- read_html(urls[i]) %>% 
    html_node(xpath = xpath) %>% 
    html_table() %>% 
    mutate_at("前日比", as.character) #前日比の列はいったん文字列で読んでおく
    # データフレームの指定の列を指定の関数に変換する
  
  # 1ページをスクレイピングしたら1秒スリープ
  Sys.sleep(1)
}

# データフレームのリストを縦につなげて1つのデータフレームを生成
dat <- bind_rows(kabukas)

# ブラウザの自動操作
install.packages("RSelenium")
# chromeのドライバとSeleniumサーバの準備(起動含む)
library(wdman)
selenium(retcommand = TRUE)

library(RSelenium)
eCaps <- list(
  chromeOptions =
    list(prefs = list(
      # ポップアップを表示しない
      "profile.default_content_settings.popups" = 0L,
      # ラウンロードプロンプトを表示しない
      "download.prompt_for_download" = FALSE,
      # ダウンロードディレクトリの変更
      "download.default_directory" = "/Users/kitada/Desktop"
    )
    )
)
# ブラウザの起動, デフォルトはchrome
rD <- rsDriver(browser = "firefox", verbose = FALSE)
#remoteDriverクラスのインスタンスを作成
remDr <- rD[["client"]]
# URLにアクセス
target_url <- "https://e-stat.go.jp/"
remDr$navigate(target_url)
# 要素を選択
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[1]/div[2]/div[2]/div[2]/div/div/section/div/div/a[1]")
# クリック
webElem$clickElement()
# 境界データダウンロード
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/article/div/div/section/ul/li/a[3]")
webElem$clickElement()
# 小地域
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/ul/li[1]/a")
webElem$clickElement()
# 国勢調査
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/ul/li[1]/a/span[2]")
webElem$clickElement()
# 2015年
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/div[2]/ul[1]/li/div[1]/span[1]/i[1]")
webElem$clickElement()
# 小地域(町丁・字等別集計)
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/div[2]/ul[1]/li/div[2]/ul/li[1]/div/span[1]/span/a")
webElem$clickElement()
# 世界測地系緯度経度・Shape
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/div[2]/ul[1]/li/a")
webElem$clickElement()
# 神奈川県
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/div/div/article[14]/div/ul/a/li[1]")
webElem$clickElement()
# 神奈川県全域の世界測地系緯度経度・Shape
webElem <- remDr$findElement("xpath", "/html/body/div[1]/div/main/div[2]/section/div[2]/main/section/div[3]/div/div/article[1]/div/ul/li[3]/a")
webElem$clickElement()
# ブラウザを閉じる
remDr$close()
# Seleniumサーバを停止
rD[["server"]]$stop()

# API