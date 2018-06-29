# mulukhiya-toot-proxy

今のところは、トゥート本文中に書かれたURLを正規化するプロキシ。
通称「モロヘイヤ」。

## ■設置の手順

どこに置いても動くだろうけど、Mastodonインスタンスと同じサーバに置くことを推奨。

### リポジトリをクローン

```
git clone git@github.com:pooza/mulukhiya-toot-proxy.git
```

### 依存するgemのインストール

```
cd mulukhiya-toot-proxy
bundle install
```

### local.yamlを編集

local.yamlは、640か600のパーミッションを推奨。

```
vi config/local.yaml
```

以下、設定例。

```
handlers:
  - shortened_url
  - url_normalize
  - amazon_asin
slack:
  hooks:
    - https://hooks.slack.com/services/xxxxx
    - https://discordapp.com/api/webhooks/xxxxx
    - https://mstdn.b-shock.org/webhook/v1.0/toot/xxxxx
amazon:
  associate_id: hoge
```

以下、YPath表記。

#### /handlers

ハンドラのアンダースコア名を列挙。（ハンドラについては後述）  
書いた順番通りに実行されるので、今のところは上記サンプル通りの設定を推奨。

#### /slack/hooks/*

例外発生時の通知先。Slackのwebhookと互換性のあるURLを列挙。省略可だが、明示的な設定を強く推奨。  
モロヘイヤの誤動作は最悪のケースでは「トゥートが行えない」ことにつながり、インスタンスの
メンバーが異常をトゥートで報告することすらできなくなると考えられる。この為、
アラートを受け取る手段は極力確保しておくべき。  
拙作[tomato-toot](https://github.com/pooza/tomato-toot)のwebhookも本来であれば利用可だが、
tomato-tootからのトゥートもモロヘイヤで処理される為、どちらかが誤動作した場合にループする
可能性あり。（テスト中に実際に起きた）
申し訳ないけど当面は、おとなしくSlackやDiscordのwebhookを登録して頂きたい。

#### /amazon/associate_id

アマゾンのアソシエイトIDをお持ちであれば、それを指定。  
お持ちでない、または該当機能を使わないのであれば、省略可。

- [トラッキングIDを使用する](https://affiliate.amazon.co.jp/help/topic/t10/)

#### /instance_url

インスタンスのルートURLを記述。  
インスタンスと同じサーバに設置した場合は設置環境から適切なURLを調べる為、通常は
省略可。明示的な設定が必要なのは、以下のケースだけと思われる。

- インスタンスとは別のサーバに設置する場合。
- どうしてもうまくトゥートできない場合。

### syslog設定

mulukhiya-toot-proxyというプログラム名で、syslogに出力している。  
以下、rsyslogでの設定例。

```
:programname, isequal, "mulukhiya-toot-proxy" -/var/log/mulukhiya-toot-proxy.log
```

### リバースプロキシ設定

通常はMastodonインスタンスがインストールされたサーバに設置するだろうから、Mastodon本体同様、
nginxにリバースプロキシを設定。以下、nginx.confでの設定例。

```
    location = /api/v1/statuses {
      proxy_pass_header Server;
      if ($http_x_mulukhiya != '') {
        proxy_pass http://localhost:3000;
      }
      if ($http_x_mulukhiya = '') {
        proxy_pass http://localhost:3008;
      }
    }
```

該当するserverブロックに上記追記し、nginxを再起動する。

Mastodonインスタンスに対する、トゥートのリクエストを横取りする設定。  
処理後にリクエストヘッダ `X-Mulukhiya` を加えて `/api/v1/statuses` にPOSTし直す
仕様である為、このような設定になっている。

## ■ハンドラについて

モロヘイヤの本質は、トゥートをトリガーとして様々な処理を行うフレームワークである。
…と言っては大げさか。  
Mastodonインスタンスへのトゥート要求に対して、事前に設定された「ハンドラ」を順に実行
する。今のところはトゥートを加工するハンドラだけが用意されているが、ユーザーが任意の
ハンドラを設置して実行することも可能。（ハンドラの仕様については後日追って説明）  
ハンドラが行う処理がトゥートと関連した処理である必要は必ずしもなく、例えばトゥート
本文に書かれたJSONを読み取って、サーバに何かしらのバッチ処理を行わせる様なことも可能。

以下、添付したハンドラそれぞれについての説明。  
実行する際はlocal.yamlに、それぞれのアンダースコア名を __実行する順に__ 記述すること。

### ShortenedUrlHandler

トゥート本文に書かれた短縮URLを元に戻す。

- アンダースコア名 shortened_url
- ネストしたもの（短縮URLの短縮URL等）には未対応。
- 対象とする短縮URLサービスは、今のところ以下のもの。
  - t.co
  - goo.gl
  - bit.ly
  - ow.ly
  - amzn.to
  - amzn.asia
  - youtu.be
  - git.io

### UrlNormalizeHandler

日本語等が含まれるURLを正規化する。

- アンダースコア名 url_normalize
- 国際化ドメイン（IDN）をPunycode化したり、クエリー文字列をURLエンコードしたり。
- 今まで、各種MastodonクライアントでクリックできなかったURLが、
クリックできるようになる可能性あり。

### AmazonAsinHandler

アマゾンの商品URLを正規化する。

- アンダースコア名 amazon_asin
- アマゾンの商品URLは、ブラウザには通常非常に長いものが表示されるが、そのうち実際に
必要なのはASIN（商品のID的なもの）だけ。ASINだけを残して不要な情報全てを削除する。
- もしアソシエイトIDが設定されていたら、末尾に加える。
- 処理の対象は、ドメイン名をドットで区切って `amazon` 文字列が含まれるURL。
雑な判定だが、セキュリティ上の懸念があるわけでもないので、当面は変更の予定なし。
- 対象とするURLは、以下の形式のもの。
  - /dp/__ASIN__
  - /gp/product/__ASIN__
  - /exec/obidos/ASIN/__ASIN__
  - /o/ASIN/__ASIN__

## ■制約

### URLの終端について

アマゾンの商品URLを扱うという要件から、日本語を含んだ（RFC的に正しくない）URLも
扱える必要があった。  
この為、URLの終端を正規表現 `\s` にマッチする文字（半角スペースや改行等）で区切る必要がある。  
この制約は、日本語を含んだURLに対応していないMastodonには本来ないものなので、注意されたい。

### トゥート文字数について

通常のWebクライアントを含めほとんどのクライアントでは、500文字以上のトゥートを
行えない様に文字数を監視している。  
特にアマゾンのURLを含んだトゥートでは、入力時よりも長いものがトゥートできるはずのところ、
クライアントによってエラーとされる可能性がある。

### トゥートを改変するということ

これは「制約」とは違うかも知れないけど、トゥートに何かしらの改変をすることには違いない。  
意図に反した改変はしていないつもりだけど、特にアマゾンのアソシエイトIDが加えられることに
にひとこと言いたい勢はいるかもしれない。  
この点、規約等で重々念を押す必要はあるかもしれない。

## ■操作

インストール先ディレクトリにchdirして、rakeタスクを実行する。root権限不要。

### 起動

```
bundle exec rake start
```

### 停止

```
bundle exec rake stop
```

### 再起動

```
bundle exec rake restart
```

## ■API

### POST /api/v1/statuses

POSTされた内容（トゥート）に対してハンドラを順次実行する。  
その結果によって改変されたトゥートをMastodon本体にPOST、Mastodon本体からの
レスポンスをユーザーに返す。

ユーザーに返すレスポンスは、通常のトゥートのものと互換性あり。  
但し、レスポンスヘッダ `X-Mulukhiya` を加えて返す形に拡張されている。
ヘッダの書式はまだ固まっていなくて、将来変更の予定があり。
今のところは、各ハンドラが置き換えを行った回数を記録する。

### GET /about

上記設定例ではリバースプロキシを設定していない為、一般ユーザーには公開されないが、
現状はプログラム名とバージョン情報だけを含んだ、簡単なJSON文書を出力する。

設置先サーバにcurlがインストールされているなら、以下実行。

```
curl -i http://localhost:3008/about
```

以下、レスポンス例。

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Length: 93
X-Content-Type-Options: nosniff
Connection: keep-alive
Server: thin

{"request":{"path":"/about","params":{}},"response":{"message":"mulukhiya-toot-proxy 1.0.0"}}
```

必要に応じて、監視などに使って頂くとよいと思う。

## ■設定ファイルの検索順

local.yamlは、上記設置例ではconfigディレクトリ内に置いているが、
実際には以下の順に検索している。（ROOT_DIRは設置先）

- /usr/local/etc/mulukhiya-toot-proxy/local.yaml
- /usr/local/etc/mulukhiya-toot-proxy/local.yml
- /etc/mulukhiya-toot-proxy/local.yaml
- /etc/mulukhiya-toot-proxy/local.yml
- __ROOT_DIR__/config/local.yaml
- __ROOT_DIR__/config/local.yml

## ■最後に、これをつくった経緯

プリキュア専用インスタンス「[キュアスタ！](https://precure.ml)」で、ずっと前に
「アマゾンのURL、もっと短くならない〜？」って言われてたのを思い出して作りました。

「利用の条件」というほど強制力のあるお願いではないけど、プリキュアにもし興味あったら
覗いてください。みんな喜びます。
