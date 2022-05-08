require 'json'
require 'aws-sdk'
require 'net/http'
require 'uri'

# コスト集計方法
# AmortizedCost,BlendedCost,NetAmortizedCost,NetUnblendedCost,NormalizedUsageAmount,UnblendedCost,
METRICS = 'AmortizedCost'.freeze
TITLE = ''.freeze

def lambda_handler(event:, context:)
  # コスト格納用ハッシュ
  costs = {}

  # 前日との差分を取得
  costs['diff'] = 0
  diff = fetch_cost((Date.today - 1), (Date.today + 1))
  costs['diff'] = diff.results_by_time[0].total[METRICS].amount.to_f.round(2)

  # 月初から当日までのコストを取得
  time = Time.now
  costs['until_today'] = 0

  # 月初の場合は当日が月初にあたり差分がないため計算しない
  unless Date.new(time.year, time.month, 1).equal?(Date.today)
    until_today = fetch_cost(Date.new(time.year, time.month, 1), Date.today + 1)
    costs['until_today'] = until_today.results_by_time[0].total[METRICS].amount.to_f.round(2)
    # discordへ通知
    notify(costs)
  end
  { statusCode: 200, body: JSON.generate('OK') }
end

# コスト取得
# @param [Date] start_date 開始日(当日を含む)
# @param [Date] end_date 終了日(当日を含まない)
# @return [none]
def fetch_cost(start_date, end_date)
    client = Aws::CostExplorer::Client.new
    client.get_cost_and_usage(
      time_period: {
        start: start_date.strftime('%F'),
        end: end_date.strftime('%F')
      },
      granularity: 'MONTHLY',
      metrics: [METRICS]
    )
end

# Discord通知
# @param [Hash] costs 通知に載せるコスト
# @return [none]
def notify(costs)
  # webhookのURLをSecretsManagerから取得
  secret_name = "discord/prod"
  region_name = "ap-northeast-1"
  client = Aws::SecretsManager::Client.new(region: region_name)
  get_secret_value_response = client.get_secret_value(secret_id: secret_name)
  secret = JSON.parse(get_secret_value_response.secret_string)
  webhook = secret["DISCORD_WEBHOOK"]

  # 通知メッセージに必要な情報を設定
  time = Time.now
  period = "#{Date.new(time.year, time.month, 1).strftime('%F')} - #{Date.today.strftime('%F')}"
  color = 1_127_128 # blue(default)

  uri = URI.parse(webhook)
  request = Net::HTTP::Post.new(uri)
  request.content_type = 'application/json'
  request.body = JSON.dump({
                             'username' => 'AWSの利用料金',
                             'content' => '',
                             'embeds' => [
                               {
                                 'title' => TITLE,
                                 'color' => color,
                                 "fields": [
                                   {
                                     'name' => "利用料金 #{period})",
                                     'value' => "$#{costs['until_today']}",
                                     'inline' => true
                                   },
                                   {
                                     'name' => '前日との利用料金差分',
                                     'value' => "$#{costs['diff']}",
                                     'inline' => true
                                   }
                                 ]
                               }
                             ]
                           })
  req_options = { use_ssl: uri.scheme == 'https' }
  # Send Request.
  Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end

