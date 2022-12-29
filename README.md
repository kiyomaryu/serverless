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

キー名:secret_name
値:前の手順で入手したURL
名前:secret_name

以下のコマンドを入力して構築する。

```bash
git clone https://github.com/kiyomaru/serverless.git
cd servless/services/aws-billing
serverless deploy
```

毎日10:00にdiscodeにて特定のチャンネルに、AWS利用料が通知されていることを確認する。

## 削除方法

```bash
cd servless/services/aws-billing
serverless remove
```
