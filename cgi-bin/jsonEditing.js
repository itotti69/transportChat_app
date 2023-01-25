const url = "./write.json"; // JSONファイル名
// cgi-bin/final/write.json
let result;

// JSONファイルを整形して表示する
function formatJSON(data) {
    var for_time = ''; //出発時刻
    var to_time = ''; //到着時刻

    for_time = data.start_time;
    to_time = data.goal_time;

    var year_start = for_time.slice(0, 4); //年
    var month_start = for_time.slice(5, 7); //月
    var days_start = for_time.slice(8, 10); //日
    var hour_start = for_time.slice(11, 13); //時
    var minute_start = for_time.slice(14, 16); //分
    var hour_start = for_time.slice(11, 13); //時
    var minute_start = for_time.slice(14, 16); //分

    var year_goal = to_time.slice(0, 4); //年
    var month_goal = to_time.slice(5, 7); //月
    var days_goal = to_time.slice(8, 10); //日

    // この情報をLINEに転送したい
    var hour_goal = to_time.slice(11, 13); //時
    var minute_goal = to_time.slice(14, 16); //分

    // 整形して表示
    let html = "<h1>" + year_start + "年" +
        month_start + "月" + days_start + "日</h1><br>";
    html += "<h2>" +
        data.start_station_name + "駅" + "</h2><br>";
    html += "<h3>" + hour_start + "時" + minute_start + "分発" + "</h3><br>";
    html += "<h2>" +
        data.goal_station_name + "駅" + "</h2><br>";
    html += "<h3>" + hour_goal + "時" + minute_goal + "分着" + "</h3><br>";
    html += "<h3>" + data.total_time + "分" + "</h3><br>";
    html += "<h3>" + data.move_type + "</h3><br>";

    result.innerHTML = html;
}

// 起動時の処理
window.addEventListener("load", () => {
    // JSON表示用
    result = document.getElementById("result");

    // JSONファイルを取得して表示
    fetch(url)
        .then((response) => response.json())
        .then((data) => formatJSON(data));
});