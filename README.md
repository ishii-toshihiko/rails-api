# Works IT Portfolio API（rails-api）

個人ポートフォリオサイト向けの **Rails API** です。フロント（React）から認証・スキル取得・アクセス計測・お問合せ送信を受け付けます。

| 項目 | 内容 |
|------|------|
| 役割 | JSON API（RESTful） |
| フロント | [react-rails](https://github.com/ishii-toshihiko/react-rails)（Firebase Hosting） |
| デモ | フロント: [ishii-portfolio-front.web.app](https://ishii-portfolio-front.web.app) |

## 技術スタック

- Ruby on Rails 7（API モード）
- PostgreSQL（Neon）
- Devise Token Auth
- Cloud Run + Artifact Registry + GitHub Actions
- Secret Manager
- Resend（お問合せメール・HTTPS API）

## 主な機能

- トークン認証（登録 / ログイン / ログアウト）
- スキル一覧 API
- ページビュー計測（`POST /v1/page_views`）
- お問合せ受付（`POST /v1/contacts` → Resend → 担当者メール）
  - バリデーション・honeypot・簡易レート制限

## 構成（概要）

```text
Browser (Firebase Hosting)
  → Cloud Run (rails-api)
      → Neon (Postgres)
      → Resend (contact email)
```

## 担当・ポイント

- Fat Controller を避け、お問合せは Form / Service に分離
- メールは ActionMailer/SMTP ではなく Resend HTTP（Cloud Run 向け）
- 秘密情報は GitHub Secrets → Secret Manager → Cloud Run のみ（リポジトリに置かない）
