# README #

■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■
■CONFIGの設定について

1.settings_dir 
  configを管理しているsettings repositoryのLocal pathを指定
2.builds_dir
  アプリのソースコード(開発) repositoryのLocal pathを指定
3.release_dir
  cloud buildのTriggerと連携している各アプリ repositoryのLocal pathを指定
　(git cloneしたままの名称で配置：release-hmt-keel)

実例
User:tahi

1.settings_dir:settingsのディレクトリパスを指定
(ディレクトリの中身は、settingsリポ:hmt-v1-settings, hmt-v2-settingsをgit clone)
[sample]
settings_dir /Users/tahi/zwv/svc_bs_developer/settings/hmt

(/Users/tahi/zwv/svc_bs_developer/settings/hmt Dirの中身)
└hmt-v1-settings
└hmt-v2-settings

2.builds_dir:build(開発ソースコード)のディレクトリパスを指定
※コンポーネントを一つのディレクトリ配下にしておくが必須事項
(ディレクトリの中身は、buildsリポ:boarding,keel,,,をgit clone)
[sample]
builds_dir /Users/tahi/zwv/svc_bs_developer/builds/hmt

(/Users/tahi/zwv/svc_bs_developer/builds/hmt Dirの中身)
└boarding
└keel
:

3.release_dir:release(デプロイ・リリース専用)のディレクトリパスを指定
(ディレクトリの中身は、releaseリポ:release-hmt-boarding, release-hmt-keel,,,をgit clone)
[sample]
release_dir /Users/tahi/zwv/svc_bs_developer/release

(/Users/tahi/zwv/svc_bs_developer/release Dirの中身)
└release-hmt-boarding
└release-hmt-keel
:

4.versions_dir:hmt-release-versions(バージョン)のディレクトリを指定
(ディレクトリの中身は、releaseリポ:hmt-release-versions をgit clone)
[sample]
versions_dir /Users/tahi/zwv/svc_bs_developer/deploy

(/Users/tahi/zwv/svc_bs_developer/deploy Dirの中身)
└hmt-release-versions

上記の配置の場合の、CONFIG/confgへの書き込みサンプル
[sample]
settings_dir /Users/tahi/zwv/svc_bs_developer/settings/hmt
builds_dir /Users/tahi/zwv/svc_bs_developer/builds/hmt
release_dir /Users/tahi/zwv/svc_bs_developer/release
versions_dir /Users/tahi/zwv/svc_bs_developer/deploy


■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■
■Depoly Triggerについて

基本利用方法
１．Cloud Build(GCP)を利用。
２．Triger登録内容に基づき、これにあわせてrepositoryにpushし、デプロイさせている

本番デプロイについて
releaseリポジトリーのrelease/master_*へのpushにトリガーを登録すること（必須）。

ブランチ運用について
https://svc.atlassian.net/wiki/spaces/CDLAB/pages/788332788




■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■
■各ファイルの役割について
1.build_script.sh:::起動＆フロー
2.hearing.sh:::選択入力_
3.validation.sh:::バリデーション
4.version.sh:::バージョンの取得、設定
5.create_release_branch.sh:::リリース用ブランチ作成
6.git_source_branch_checkout.sh:::リリース元ブランチをチェックアウト
7.git_delete_tester_branch.sh:::Testerブランチ削除
8.update_release_branch.sh:::リリースブランチアップデート
9.version_injection.sh:::DockerFileへの書き込み
10.cloud_builds.sh:::CLoudBuildアクセス
11.finisher.sh:::最終処理

<共通>
error_chk.sh:::エラーチェック
colored.sh:::文字装飾







