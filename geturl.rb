#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require
require 'parallel'
require 'faraday'
require 'nokogiri'
require 'charlock_holmes'
require 'unicode_utils'

FILE_PATH = '/home/haturatu/Downloads/mstdon/test'
RESULT_FILE = 'Result'
OTHER_ERROR_FILE = 'Other'
CONCURRENCY = 10

def is_garbled?(text)
  text.include?('�') || text.chars.any? { |char| char.ord > 0xFFFF }
end

def clean_title(title)
  title = title.chars.reject { |ch| UnicodeUtils.general_category(ch).start_with?('C') }.join
  title = UnicodeUtils.nfkc(title)
  title = title.chars.select(&:valid_encoding?).join
  title.strip
end

def get_page_title(url)
  conn = Faraday.new(url: url, ssl: { verify: false }) do |faraday|
    faraday.adapter Faraday.default_adapter
    faraday.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  end

  response = conn.get do |req|
    req.options.timeout = 30
  end

  content = response.body
  encodings = ['UTF-8', 'Shift_JIS', 'EUC-JP', 'ISO-2022-JP', 'Windows-31J']
  
  title = nil
  encodings.each do |encoding|
    begin
      text = content.force_encoding(encoding).encode('UTF-8', invalid: :replace, undef: :replace)
      doc = Nokogiri::HTML(text)
      title = doc.at_css('title')&.text&.strip || 'No title found'
      break unless is_garbled?(title)
    rescue
      next
    end
  end

  if is_garbled?(title)
    detection = CharlockHolmes::EncodingDetector.detect(content)
    encoding = detection[:encoding] || 'UTF-8'
    text = content.force_encoding(encoding).encode('UTF-8', invalid: :replace, undef: :replace)
    doc = Nokogiri::HTML(text)
    title = doc.at_css('title')&.text&.strip || 'No title found'
    if is_garbled?(title)
      title = url.split('/').last.gsub('-', ' ').gsub('_', ' ').capitalize
      title = 'Error: Unable to extract title' if title.empty?
    end
  end

  [url, clean_title(title)]
rescue => e
  [url, "Error: #{e.class} - #{e.message}"]
end

def process_url(url)
  url, title = get_page_title(url)
  if title.start_with?('Error:')
    File.open(OTHER_ERROR_FILE, 'a') { |f| f.puts "URL: #{url}\nError: #{title}\n\n" }
  else
    File.open(RESULT_FILE, 'a') { |f| f.puts "URL: #{url}\nTitle: #{title}\n\n" }
  end
  puts "URL: #{url}\nTitle: #{title}\n\n"
end

def process_urls(file_path)
  urls = File.readlines(file_path).map(&:strip).reject(&:empty?)
  
  Parallel.each(urls, in_threads: CONCURRENCY) do |url|
    process_url(url)
    sleep(rand(1.0..3.0))
  end
end

process_urls(FILE_PATH)
