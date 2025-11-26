# Rails API mode
1. 新しい __backend__ リポジトリをGCPに作成する
    ```sh
    gcloud artifacts repositories create backend \
    --repository-format=docker \
    --location=asia-northeast1 \
    --description="backend docker repo" \
    --project=ishii-worksit-project
    ```

1. サービスアカウントにインパーソネーション権限を付与する
    ```sh
    gcloud iam service-accounts add-iam-policy-binding 807313955645-compute@developer.gserviceaccount.com \
    --member="user:hiko.freebird335@gmail.com" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --project=ishii-worksit-proje
    ```