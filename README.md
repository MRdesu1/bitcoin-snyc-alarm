# bitcoin-snyc-alerm

## 目的
Bitcoinノードの最新ブロックと、Explorerの最新ブロックのブロック差分（以下 Diffとする）を監視するスクリプト。ネットワークは、Mainnet。

## 要件
### 元要件
- 定期的なジョブとして動かすことができること(cron, whenever)
- 言語 Ruby
- bitcoind から latest block number を取得する
    - Bitcoin ノードは、自分でBitcoinノードを準備するか、または、Web 上でパブリック公開をしているBitcoin ノードを使用して、latest block numberを取得してください
- explorer から latest block number を取得する
    - 利用する explorer の API は問いません
- bitcondとexplorerの差分の±3 block以上のDiffがあればslackに通知し、Diffが±2以下であれば、何も通知しない

## 環境
### bitcoin core
v24.0.1
https://github.com/bitcoin/bitcoin/releases/tag/v24.0.1

### Ruby
ruby 3.1.3p185

## 使い方
### bitcoin core
bitcoin/bitcoin.confを参考にbitcoindをmainnetに構築してください

### 設定
本リポジトリのクローン
```
cd ~
git clone https://github.com/MRdesu1/bitcoin-snyc-alarm.git
```

config.yml以下を適宜設定してください。
```
RPC_USER: "bitcoin.conf記載のrpcuserと同じもの"
RPC_PASSWORD: "bitcoin.conf記載のrpcpasswordと同じもの"
RPC_PORT: bitcoin.conf記載の[main]部分のportと同じもの
RPC_HOST: bitcoin coreを起動したサーバのIP
WEBHOOK_URL: 事前にWEBHOOK_URLを取得してください
```

### 起動設定
以下を例にcronを設定してください。
設定例
```
*/10 * * * * ruby $HOME/bitcoin-sync-alerm/bitcoin-sync-alerm.rb
```
 ※例ではbitcoinのブロック生成時間に合わせて10分間隔での通知としています。



## その他
+ エクスプローラーサイトのAPIは以下を参照
https://www.blockchain.com/explorer/api/q
+ ノードやエクスプローラーサイトへの問い合わせに関しては通信の瞬断の可能性を考慮してリトライ処理を入れています。
+ Slack通知はgem（slack-notifierなど）を利用したほうが簡単かと思いましたが、セキュリティ上余計なgemを入れないように単純にwebhookをたたくだけとしています。
+ テストコードは時間が足りず未実装です。（WebMockを利用してスタブを作成したテストを検討していました）

# 以上