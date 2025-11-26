# Rails API mode
1. 新しい __backend__ リポジトリをGCPに作成する
    ```sh
    gcloud artifacts repositories create backend \
    --repository-format=docker \
    --location=asia-northeast1 \
    --description="backend docker repo" \
    --project=ishii-worksit-project
    ```