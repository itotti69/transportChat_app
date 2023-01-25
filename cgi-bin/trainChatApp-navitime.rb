#!/usr/bin/env ruby
# coding: UTF-8
print "content-type: text/html\n\n"
require "json"
require "cgi" # CGI ライブラリの読み込み
require "date"  #dateクラスを扱う
require 'uri'
require 'net/http'
require 'openssl'
form = CGI.new # formデータを受け取る準備

# 他の言語のtry-catchのようなもの
begin
    start = form["start"]
    goal = form["goal"]
    day = form["day"]
    time = form["time"]
    # 出力
    # puts start
    # puts goal
rescue
    # 問題あったら
    error_cgi
    puts form.params
end

#駅名IDを取得する ここから
url_head1 = "https://navitime-transport.p.rapidapi.com/transport_node/autocomplete?word="
url_last1 = "&word_match=prefix&datum=wgs84&coord_unit=degree"
#%E5%90%8D%E9%89%84%E5%90%8D%E5%8F%A4%E5%B1%8B → 名鉄名古屋
url_word1 = CGI.escape start  #文字のURLエンコード処理
url1_create = url_head1 + url_word1 + url_last1  #自作のURL
url1 = URI(url1_create)

http1 = Net::HTTP.new(url1.host, url1.port)
http1.use_ssl = true
http1.verify_mode = OpenSSL::SSL::VERIFY_NONE

request1 = Net::HTTP::Get.new(url1)
request1["X-RapidAPI-Key"] = 'ea1192caf2msh26fb6c87c267297p1d5a17jsne93f0f82488e'
request1["X-RapidAPI-Host"] = 'navitime-transport.p.rapidapi.com'

response1 = http1.request(request1)
#出発駅のID取得ここまで
# puts response.read_body

#到着駅のID取得ここから
url_head2 = "https://navitime-transport.p.rapidapi.com/transport_node/autocomplete?word="
url_last2 = "&word_match=prefix&datum=wgs84&coord_unit=degree"
url_word2 = CGI.escape goal
url2_create = url_head2 + url_word2 + url_last2
url2 = URI(url2_create)

http2 = Net::HTTP.new(url2.host, url2.port)
http2.use_ssl = true
http2.verify_mode = OpenSSL::SSL::VERIFY_NONE

request2 = Net::HTTP::Get.new(url2)
request2["X-RapidAPI-Key"] = 'ea1192caf2msh26fb6c87c267297p1d5a17jsne93f0f82488e'
request2["X-RapidAPI-Host"] = 'navitime-transport.p.rapidapi.com'

response2 = http2.request(request2)
#到着駅のID取得ここまで

# 到着駅のID情報は、start_station.jsonに書き込み
File.open("start_station.json", 'a') do |f|
    # dumpメソッド→JSONファイルに書き込みをするメソッド
    hash1 = JSON.parse(response1.read_body)
    JSON.dump(hash1, f)
  end

# 出発駅のID情報は、goal_station.jsonに書き込み
File.open("goal_station.json", 'a') do |f|
    hash2 = JSON.parse(response2.read_body)
    JSON.dump(hash2, f)
  end
#駅ID取得ここまで

#出発駅名・ID、到着駅名・IDをまとめたJSONファイルを作る
$start_station_name = "江南"
$goal_station_name = "名鉄名古屋"

# start_station.jsonの内容を読み込む ブロック記述
# File.open(ファイルパス, 読み書きモード(デフォルト値r:読み取り専用)) do | インスタンス名 |
File.open("start_station.json") do |f|
    # ファイル操作処理
    data1 = JSON.load(f)  #JSONファイルを読み込んだデータ格納
    $start_station_id = data1["items"][0]["id"]  #→"00004372"
    $start_station_name = data1["items"][0]["name"]  #→"名鉄名古屋"
end

# goal_station.jsonの内容を読み込む ブロック記述
File.open("goal_station.json") do |f|
    data2 = JSON.load(f)
    $goal_station_id = data2["items"][0]["id"]
    $goal_station_name = data2["items"][0]["name"]
end

# 新しいjsonファイルall_station.jsonに書き込み
File.open("all_station.json", 'a') do |f|
    hash2 = {"start_station_id" => $start_station_id, "start_station_name" => $start_station_name,
    "goal_station_id" => $goal_station_id, "goal_station_name" => $goal_station_name}
    JSON.dump(hash2, f)
  end
#ここまで

# all_station.jsonから必要な情報だけ取得
File.open("all_station.json") do |f|
    data3 = JSON.load(f)
    $start_station_id_result = data3["start_station_id"]  #→"00002441"
    $goal_station_id_result = data3["goal_station_id"]  #→"00004372"
end

start_station_id = $start_station_id_result
goal_station_id = $goal_station_id_result

# 文字列":"を%3Aに置き換え time.sub(/:/, '%3A')
create_start_time = day + "T" + time.sub(/:/, '%3A') + "%3A00"
start_time = create_start_time

url_head = "https://navitime-route-totalnavi.p.rapidapi.com/route_transit?start="
url_last = "&datum=wgs84&term=1440&limit=1&coord_unit=degree"
# 乗り換え検索APIを使うためのURLを作成
url_create = url_head + start_station_id + "&goal=" + goal_station_id + "&start_time=" +start_time + url_last

url = URI(url_create)

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["X-RapidAPI-Key"] = 'ea1192caf2msh26fb6c87c267297p1d5a17jsne93f0f82488e'
request["X-RapidAPI-Host"] = 'navitime-route-totalnavi.p.rapidapi.com'

# ここで乗り換え情報を全て取得
response = http.request(request)
# puts response.read_body

# 新しいjsonファイルtransport_data.jsonに書き込み
#渡す内容は、出発時刻、到着時刻、所要時刻、路線名だけ
File.open("transport_data.json", 'a') do |f|
    # dumpメソッド→JSONファイルに書き込みをするメソッド
    hash = JSON.parse(response.read_body)
    JSON.dump(hash, f)
  end

# transport_data.jsonの内容を読み込む ブロック記述
File.open("transport_data.json") do |f|
    data_full = JSON.load(f)
    $start_time = data_full["items"][0]["summary"]["move"]["from_time"]  #→"2022-01-16T10:07:00+09:00" 出発時刻
    $goal_time = data_full["items"][0]["summary"]["move"]["to_time"]  #→"2022-01-16T10:28:00+09:00" 到着時刻
    $start_station_name = data_full["items"][0]["summary"]["start"]["name"]  #→"江南" 出発駅
    $goal_station_name = data_full["items"][0]["summary"]["goal"]["name"]  #→"名鉄名古屋" 到着駅
    $total_time = data_full["items"][0]["summary"]["move"]["time"]  #→21 所要時間
    $move_type = data_full["items"][0]["sections"][1]["transport"]["name"]  #→"名鉄犬山線急行" 路線・電車名
  end
  
  # 新しいjsonファイルwrite.jsonに書き込み
  #渡す内容は、出発時刻、到着時刻、所要時刻、路線名だけ
  File.open("write.json", 'a') do |f|
    hash = {"start_time" => $start_time, "goal_time" => $goal_time,
    "start_station_name" => $start_station_name, "goal_station_name" => $goal_station_name, 
    "total_time" => $total_time, "move_type" => $move_type}
    # dumpメソッド→JSONファイルに書き込みをするメソッド
    JSON.dump(hash, f)
  end

# /chat.htmlへmetaタグを使ったリダイレクト
# puts <<-EOS
# <!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8">
# <meta http-equiv="refresh" content="0;URL='/trainChatApp-output.html'" />
# </head><body></body></html>
# EOS

#NAVITIME API 「Route(totalnavi)」をコピー&ペースト
#inputで受け取った値からURLを作成し、それを元にJSONファイルを作成する処理