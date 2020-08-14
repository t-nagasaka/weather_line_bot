class LinebotController < ApplicationController
  require "line/bot"
  require "open/uri"
  require "kconv"
  require "rexml/document"
  require "csv"

  protect_from_forgery except: :callback

  def callback
    body = request.body.read
    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    unless client.validate_signature(body, signature)
      error 400 do "Bad Request" end
    end

    events = client.parse_events_from(body)
    url = "https://api.openweathermap.org/data/2.5/onecall?lat=33.441792&lon=-94.037689&exclude=hourly,minutely&appid=#{API_KEY}"
    row_data = open(url)
    wx_text = ""

    events.each do |event|
      case event.type
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input = event.message["text"]
          case input
          when /.*(1).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][1]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  明日の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          when /.*(2).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][2]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  明後日の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          when /.*(3).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][3]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  3日後の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          when /.*(4).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][4]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  4日後の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          when /.*(5).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][5]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  5日後の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          when /.*(6).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][6]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  6日後の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          when /.*(7).*/
            weekly_data = JSON.parse(row_data.read)
            forecast = weekly_data["daily"][7]
            wx_condition = forecast["weather"][0]["id"]
            temp_max = (forecast["temp"]["max"] - 273.15).round(1)
            temp_min = (forecast["temp"]["min"] - 273.15).round(1)
            humidity = forecast["humidity"]
            CSV.foreach("OWM_weather_id.csv", headers: true) do |row|
              if row["ID"].to_i == wx_condition
                wx_text = <<~TEXT
                  7日後の天気をお知らせします！
                  天気：#{row["Description"]}
                  最高気温：#{temp_max} ℃
                  最低気温：#{temp_min} ℃
                  湿度：#{humidity} %
                TEXT
              end
            end
          end
        else
          wx_text = "指定の数字以外は理解しかねますが？"
        end
        message = {
          type: "text",
          text: wx_text,
        }
        client.reply_message(event["replyToken"], message)
      when Line::Bot::Event::Follow
        line_id = event["source"]["userID"]
        User.create(line_id: line_id)
      when Line::Bot::Event::Unfollow
        line_id = event["source"]["userID"]
        User.create(line_id: line_id).destroy
      end
    end
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
