require "json"
# NAVITIME Route(totalnavi)から取得した
# JSONファイルを読み込み、必要な項目だけを取り出して、別のJSONファイルに書き出しを行う処理

# $start_time = "2023-01-01T00:00:00+00:00"  #出発時刻
# $goal_time = "2023-01-01T00:00:00+00:00"  #到着時刻
# $start_station_name = "出発駅名"  #出発駅名
# $goal_station_name = "到着駅名"  #到着駅名
# $total_time = 0  #電車の所要時間
# $move_type = "名鉄犬山線急行"  #路線名・乗車した電車の種類

# memo.jsonの内容を読み込む ブロック記述
# File.open(ファイルパス, 読み書きモード(デフォルト値r:読み取り専用)) do | インスタンス名 |
File.open("transport_data.json") do |f|
  # ファイル操作処理
  data = JSON.load(f)  #JSONファイルを読み込んだデータ格納
  $start_time = data["items"][0]["summary"]["move"]["from_time"]  #→"2022-01-16T10:07:00+09:00" 出発時刻
  $goal_time = data["items"][0]["summary"]["move"]["to_time"]  #→"2022-01-16T10:28:00+09:00" 到着時刻
  $start_station_name = data["items"][0]["summary"]["start"]["name"]  #→"江南" 出発駅
  $goal_station_name = data["items"][0]["summary"]["goal"]["name"]  #→"名鉄名古屋" 到着駅
  $total_time = data["items"][0]["summary"]["move"]["time"]  #→21 所要時間
  $move_type = data["items"][0]["sections"][1]["transport"]["name"]  #→"名鉄犬山線急行" 路線・電車名
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

# ファイル操作処理
# f.write $start_time
# f.write "\n"
# f.write $goal_time
# f.write "\n"
# f.write $total_time
# f.write "\n"
# f.write $move_type
# f.write "\n"

p $start_time;
p $goal_time;
p $start_station_name;
p $goal_station_name;
p $total_time;
p $move_type;

