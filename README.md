# Rails API mode
1. 新しい __backend__ リポジトリをGCPに作成する
    ```sh
    gcloud artifacts repositories create backend \
    --repository-format=docker \
    --location=asia-northeast1 \
    --description="backend docker repo" \
    --project=yyyy
    ```

1. サービスアカウントにインパーソネーション権限を付与する
    ```sh
    gcloud iam service-accounts add-iam-policy-binding nnnn-compute@developer.gserviceaccount.com \
    --member="user:xxxx@gmail.com" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --project=yyyy
    ```

1. Secret は GitHub Actions の Secrets を正とし、デプロイ時に GCP Secret Manager へ同期する。Cloud Run / Job では `--set-secrets` 経由で注入する

## デプロイ（GitHub Actions）

`main` への push で [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) が実行される。

### 処理の流れ

1. Docker イメージを Artifact Registry へ build / push
2. GitHub Secrets の値を GCP Secret Manager に同期
3. Cloud Run Service `rails-api` をデプロイ
4. Cloud Run Job `rails-api-prepare` で `db:prepare` を実行

### Cloud Run Job（DB 初期化 / migration）

Service デプロイ後、Cloud Run Job で DB 準備を行う。

| 項目 | 内容 |
|------|------|
| Job 名 | `rails-api-prepare` |
| コマンド | `bundle exec rails db:prepare` |
| 実行タイミング | デプロイ workflow 内（`gcloud run jobs execute --wait`） |
| 接続 | Neon（パブリック Postgres、`POSTGRES_SSLMODE=require`） |

Job が失敗すると GitHub Actions 全体も失敗する。ログは Cloud Console → Cloud Run → Jobs → `rails-api-prepare` の実行履歴から確認できる。