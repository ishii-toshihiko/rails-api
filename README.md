# Works IT Portfolio API（rails-api）

個人ポートフォリオサイト向けの **Rails API** です。フロント（React）から認証・スキル取得・アクセス計測・お問合せ送信を受け付けます。

**案件向けの読み物（フロント側）:** [react-rails / CASE_STUDY.md](https://github.com/ishii-toshihiko/react-rails/blob/main/CASE_STUDY.md)（[運用節](https://github.com/ishii-toshihiko/react-rails/blob/main/CASE_STUDY.md#8-運用)・[運用メモ](https://github.com/ishii-toshihiko/react-rails/blob/main/docs/%E9%81%8B%E7%94%A8%E3%83%A1%E3%83%A2.md)）

| 項目 | 内容 |
|------|------|
| 役割 | JSON API（RESTful） |
| フロント | [react-rails](https://github.com/ishii-toshihiko/react-rails)（Firebase Hosting） |
| デモ | フロント: [ishii-portfolio-front.web.app](https://ishii-portfolio-front.web.app) |
| 担当範囲 | API 設計・認証・DB・メール送信・Cloud Run / Secret Manager デプロイ |
| 想定規模 | 小〜中規模の Rails API + React |
| お問合せ | デモの [Contact](https://ishii-portfolio-front.web.app/contact) 経由（本 API の `POST /v1/contacts`。実メールは非公開） |

## 技術スタック

- Ruby on Rails 7（API モード）
- PostgreSQL（本デモは Neon。案件では Cloud SQL も選択可）
- Devise Token Auth
- Cloud Run + Artifact Registry + GitHub Actions
- Secret Manager
- Resend（お問合せメール・HTTPS API）
- RSpec / RuboCop（CI）

## 主な機能

- トークン認証（登録 / ログイン / ログアウト）
- スキル API
  - `GET /v1/skills` は公開（閲覧者向けの確定データ）
  - `/v1/skill_drafts` はログインユーザーごとの下書き CRUD
  - `POST /v1/skill_drafts/publish` は `SKILLS_OWNER_EMAIL` のオーナーのみ（公開へ反映）
  - `POST /v1/skill_drafts/reset` で公開内容を自分の下書きへ再同期
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

## 品質ゲート（CI）

`main` への push で **Cloud Run デプロイ前**に RuboCop / RSpec を実行します。  
フロント側は lint / knip / Playwright を Hosting デプロイ前に実行（詳細は [CASE_STUDY 運用節](https://github.com/ishii-toshihiko/react-rails/blob/main/CASE_STUDY.md#8-運用)）。

ログは主に **Cloud Logging**（Cloud Run）で確認します。障害時の切り分けはフロント側 [運用メモ](https://github.com/ishii-toshihiko/react-rails/blob/main/docs/%E9%81%8B%E7%94%A8%E3%83%A1%E3%83%A2.md) を参照。

## 担当・ポイント

- Fat Controller を避け、お問合せは Form / Service に分離
- メールは ActionMailer/SMTP ではなく Resend HTTP（Cloud Run 向け）
- 秘密情報は GitHub Secrets → Secret Manager → Cloud Run のみ（リポジトリに置かない）
