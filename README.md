# serverless

AWSの使用料金をdiscodeへ通知するツールになります。

## 事前に実施する事項

以下のコマンドを使用できていること。

```bash
servless
aws(aws configureによる設定済であること。)
```

discodeにてチャンネル書き込みのためのアクセスキーを発行していること。

## 参考URL

(AWS CLIを利用するため必要な初期設定について)[https://dev.classmethod.jp/articles/aws-cli_initial_setting/]
(Serverless Framework のインストールから AWS へのデプロイまで)[https://zenn.dev/ombran/articles/serverless-install-and-aws-deploy]
(指定したツイートをDiscordに自動投稿してくれるbotの導入方法【2022年更新】)[https://note.com/kawa0108/n/ndc5aef135519]
(AWS Secrets Managerを使おう！)[https://qiita.com/mm-Genqiita/items/f93285a6058c64b39f23]

## 構築方法

discodeにてwebhookURLを入手する。

discodeで入手した投稿に必要な情報をAWS SecretManagerに登録する

種類:その他
キー名:DISCORD_WEBHOOK
値:前の手順で入手したURL
名前:discord/prod

以下のコマンドを入力して構築する。

```bash
git clone https://github.com/kiyomaru/serverless.git
cd servless/services/aws-billing
npm install aws-sdk aws-xray-sdk serverless-plugin-tracing
serverless deploy
```

毎日10:00にdiscodeにて特定のチャンネルに、AWS利用料が通知されていることを確認する。

## 通知時刻変更方法

LambdaからCloudWatchイベントを開き、スケジュールがUTC1:00(JPT10:00)となっているのを
適当な時刻に修正する。

## 任意のタイミングで通知する方法

Lambdaを開き、batch-prod-aws-billing関数のテスト実行を行う。

## 削除方法

```bash
cd servless/services/aws-billing
serverless remove
```
