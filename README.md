# bitcoin-snyc-alarm

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

