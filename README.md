# GitHub As A Storage for Windows
物置としての GitHub。オレオレ風味。

## コンセプト
- 複数環境から楽にテキストを同期したい
- いちいち git コマンド打つのはだるいのでラップしたい

## 前提

### OS
- Windows 7
- Windows 10

### GitHub プラン
- Developer プラン(プライベートリポジトリを使うため)

### 扱うコンテンツと扱わないコンテンツ
扱う:

- **自製した** テキスト全般
  - 作業メモ
  - 手順書やノウハウまとめ
  - blog, wiki などの原稿
  - スクリプト全般

扱わない:

- 100KB 以上のバイナリ
- 自製していないテキスト全般(ソースへのポインタをメモするようにする)

### 構成(マシン)

```
  home1 <--> GitHub <--> home2
```

- home1: 毎日通う。
- home2: 数日に一回程度通う。

両者間でのデータ同期が必要となる。

同期は手動 push/pull で行う。

### 構成(ローカルリポジトリ)

```
+ (WORK_DIR)
 + stakiran
  + repo1
  + repo2
  + ...
 + stakiran_sub
  + repo1
  + repo2
  + ...
 - statusall.bat
 - pullall.bat
```

- stakiran: 毎日同期(upload/download)する頻繁利用リポジトリはここに
- stakiran_sub: 上記以外のリポジトリはこっちに clone する

### Stances
- ブランチは `master` のみ使う
  - 理由: 一人なので複雑なブランチは要らない
- リモートは `origin master` のみ使う
  - 理由: ブランチ要らないため
- リモートから引っ張ってくる時は `git pull` のみ使う
  - 理由: fetch してどうこうが面倒くさいので pull で一気に取り込んじゃう

## 解説/導入(必須編)

### バッチファイルについて
- commit/push/pull の単純化
  - [save.bat](save.bat)
  - [upload.bat](upload.bat)
  - [download.bat](download.bat)
  - [displaywait.bat](displaywait.bat)
- save/upload 忘れをまとめて確認する
  - [statusall.bat](statusall.bat)
- GitHub からまとめて同期する(更新分をまとめてダウンロードする)
  - [pullall.bat](pullall.bat)

### 利用プロトコルについて
HTTPS を使う。

- 理由
  - SSH よりも若干速いから
  - SSH よりも認証が楽だから
  - Clone 時の URL として扱いやすいから
    - HTTPS だとアドレスバーからのコピペで OK
    - SSH だともうちょっと面倒

### 認証手段について
wincred を使う。 `%userprofile%\.gitconfig` に以下を書いておく。

```gitconfig
[credential]
	helper = wincred
```

Git のバージョンによっては `C:\program files\Git\mingw32\etc\gitconfig` も同様の修正が必要かもしれない。

### (余談) wincred とは？
Ans: Windows の「資格情報」という仕組み。

認証情報を保存しておいて認証不要でスルーできるようにしてくれる。これを使うと HTTPS 通信時に毎回ユーザー名/パスワードが訊かれるのを回避できる。

- 設定したい
  - 方法1: コントロールパネル > ユーザーアカウント > 資格情報の管理
  - 方法2: cmdkey コマンド

以下は `cmdkey /list` のサンプル。

```
$ cmdkey /list
    ...
    ターゲット: LegacyGeneric:target=git:https://stakiran@github.com
    種類: 汎用 
    ユーザー: stakiran
    ローカル コンピューターの常設
    
    ターゲット: LegacyGeneric:target=git:https://stakiran@gist.github.com
    種類: 汎用 
    ユーザー: stakiran
    ローカル コンピューターの常設
    ...
```

見ての通り **設定はグローバルで一つ** のため、複数アカウントに対しては利用できない。上記で言うとユーザー stakiran のみが wincred を使える。他のユーザーでも（いちいち認証情報入力するのを避けて）使いたい場合は SSH を使うしかない。。。

## 解説/導入(便利編)

### save/upload/download コマンドを使えるようにする
save.bat 等を PATH の通ったディレクトリに配置する。するとカレントディレクトリ上で `save` とか `upload` とか打つだけで save や upload が出来る。

以下は PATH 導通の確認方法。where コマンドを使う。

```
$ where save
D:\work\github\stakiran\path\save.bat

$ where upload
D:\work\github\stakiran\path\upload.bat

$ where download
D:\work\github\stakiran\path\download.bat
```

### フォルダ背景右クリックから upload/download を行えるようにする
マウスからサクサクと upload/download できるので便利。

手順としてはレジストリの `HKEY_CLASSES_ROOT\Directory\Background\shell` をいじる。

```
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\Background\shell]

[HKEY_CLASSES_ROOT\Directory\Background\shell\git_download]
@="git DOWNLOAD"

[HKEY_CLASSES_ROOT\Directory\Background\shell\git_download\command]
@="\"(GAAS_WORK)\\download.bat\" %V"

[HKEY_CLASSES_ROOT\Directory\Background\shell\git_upload]
@="git UPLOAD"

[HKEY_CLASSES_ROOT\Directory\Background\shell\git_upload\command]
@="\"(GAAS_WORK)\\upload.bat\" %V"

```

### Tortoise Git の導入
[Tortoise Git](https://tortoisegit.org/) があると GUI で簡単に git 操作が行えて便利。特に Log の閲覧に重宝。

差分を見たい時は [WinMerge](http://www.geocities.co.jp/SiliconValley-SanJose/8165/winmerge.html) も併せて導入するのが賢い。デフォの差分ビューワーは使いづらい。

- Tortoise Git のデメリット
  - オーバーレイアイコンのせいで Explorer の動作が重くなる

git コマンドに慣れてるなら無理に導入する必要はない。またログについても Web から見れば比較的見やすい。

### ワンタッチで upload 忘れを確認する
statusall.bat の話だが、複数環境から GitHub を使っている場合は upload 忘れを確実に防止しなくてはならない。が、いちいち git status コマンドで見て回るのは面倒。そのために statusall.bat がある。

欲を言えば、statusall.bat をワンタッチで呼び出せるようにしておくと便利。AutoHotkey を使って以下のように設定する。以下は Win + S で確認する例。

```ahk
#s::run,(GAAS_WORK)\statusall.bat
```

あとはタスク管理ツール(筆者は [Tritask](https://qiita.com/sta/items/2b1248869078ac8032d6) を使用)等で毎日帰る前に「statusall.bat する」「upload漏れてる分を全部uploadする」の二つの定期タスクを入れておけば、漏らすことはない。

## License
[MIT License](LICENSE)

## Author
[stakiran](https://github.com/stakiran)
