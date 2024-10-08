#!/usr/bin/env ruby

def convert_to_markdown(input_file, output_file)
  content = File.read(input_file, encoding: 'utf-8')

  pairs = content.scan(/URL: (.*?)\nTitle: (.*?)\n/m)

  File.open(output_file, 'w', encoding: 'utf-8') do |f|
    pairs.each do |url, title|
      # URLが空でない場合のみ処理
      next if url.strip.empty?

      # タイトルが空の場合、URLの最後の部分を使用
      title = url.split('/')[-1] if title.strip.empty?

      # 特殊文字をエスケープ
      title = title.gsub(/[\[\]\(\)\{\}]/) { |m| "\\#{m}" }

      # md形式のリンクを作成
      markdown_link = "[#{title}](#{url})\n\n"
      f.write(markdown_link)
    end
  end
end

convert_to_markdown('Result', 'Result.md')
