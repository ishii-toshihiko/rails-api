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

## お問合せ（Resend）

`POST /v1/contacts` から Resend HTTP API で自分宛にメールを送る（SMTP / ActionMailer は使わない）。

### GitHub Secrets（追加）

| Secret | 用途 |
|--------|------|
| `RESEND_API_KEY` | Resend API キー |
| `CONTACT_TO_EMAIL` | 受信先（自分のメール固定） |
| `CONTACT_FROM_EMAIL` | 例: `Works IT Portfolio <onboarding@resend.dev>` |

デプロイ時に Secret Manager へ同期され、Cloud Run Service の `--set-secrets` に注入される。値をチャットやリポジトリに置かないこと。

### ローカル確認

```bash
export RESEND_API_KEY=re_...
export CONTACT_TO_EMAIL=your@gmail.com
export CONTACT_FROM_EMAIL='Works IT Portfolio <onboarding@resend.dev>'

curl -sS -X POST http://localhost:3000/v1/contacts \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test","email":"test@example.com","message":"hello","website":""}'
```

成功時は `{ "ok": true }`。受信箱（迷惑メール含む）を確認する。
