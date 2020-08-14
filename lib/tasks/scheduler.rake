desc "This task is called by the Heroku scheduler add-on"
task update_feed: :environment do
  require "line/bot"
  require "open-uri"
  require "kconv"
  require "pry"
  require "csv"

  client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }

  # ID
  # 1804616 == 沖縄
  # 1856057 == 名古屋
  city_id = "1856057"
  BASE_URL = "http://api.openweathermap.org/data/2.5/weather"

  row_data = open(BASE_URL + "?id=#{city_id}&APPID=#{ENV["OWA_TOKEN"]}")
  wx_data = JSON.parse(row_data.read)

  location = wx_data["name"]
  wx_id = wx_data["weather"][0]["id"]
  wx_condition = wx_data["weather"][0]["main"]
  temp_max = (wx_data["main"]["temp_max"] - 273.15).round(1)
  temp_min = (wx_data["main"]["temp_min"] - 273.15).round(1)
  humidity = wx_data["main"]["humidity"]
  aphorism = CSV.read("comment.csv").sample
  current_day = ""

  CSV.foreach("db/CSV_file/OWM_weather_id.csv", headers: true) do |row|
    if row["ID"].to_i == wx_id
      current_day = <<~TEXT
        今日の天気をお知らせします！
        Location：#{location}
        天気：#{row["Description"]}
        最高気温：#{temp_max} ℃
        最低気温：#{temp_min} ℃
        湿度：#{humidity} %

        【本日の金言】
        #{aphorism[0]}

        7日先までなら返信してくれれば追加で教えます！
        例：3日後の天気が知りたければ「３」
      TEXT
    end
    user_ids = User.all.pluck(:line_id)
    message = { type: "text", text: current_day.chomp! }
    response = client.multicast(user_ids, message)
  end
  "OK"
end
