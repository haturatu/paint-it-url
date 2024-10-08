# paint-it-url
URLからページタイトルを取得、出力します。

## Usage
依存関係をインストール
```
bundle install --path ~/.gem
```
## 設定
設定は`geturl.rb`の以下で行います。
```
FILE_PATH = '/Your/URLs/list/file'
RESULT_FILE = 'Result'
OTHER_ERROR_FILE = 'Other'
CONCURRENCY = 10
```
`FILE_PATH`以外は変更する必要はあまりありませんが、`RESULT_FILE`を変更する場合は`md.rb`での設定と対になっています。
```
convert_to_markdown('Result', 'Result.md')
```
そのため、`RESULT_FILE`を変更した場合ここも変えないといけません。  

## geturl.rb
入力ファイルは以下のような形式とします。
`inputfile`
```
https://github.com/haturatu/paint-it-url
https://soulminingrig.com/
```
そして実行します。
```
chmod +x geturl.rb
./geturl.rb
```
出力
```
URL: https://soulminingrig.com/
Title: Home - SOULMINIGRIG

URL: https://github.com/haturatu/paint-it-url
Title: GitHub - haturatu/paint-it-url: URLからページタイトルを取得しMarkdown形式で出力する
```

## md.rb
出力されたファイルをMarkdown形式で出力する。
```
chmod +x md.rb
./md.rb
```
出力
```
$ cat Result.md 
[Home - SOULMINIGRIG](https://soulminingrig.com/)

[GitHub - haturatu/paint-it-url: URLからページタイトルを取得しMarkdown形式で出力する](https://github.com/haturatu/paint-it-url)
```
