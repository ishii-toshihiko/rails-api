class V1::Auth::SessionsController < DeviseTokenAuth::RegistrationsController
  wrap_parameters false     ## これがないとJSON リクエスト時に自動で session: {...} のようにラップされる

  ##### ログイン処理 #####
  def create
    user = User.find_by(email: resource_params[:email])
    if user && user.valid_password?(resource_params[:password])
      # トークンを生成
      token = user.create_new_auth_token
      # トークン情報をJSON形式で返す
      render json: {
        data: user.as_json.merge({
          access_token: token["access-token"],
          client: token["client"],
          uid: token["uid"]
        })
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
      # 認証情報を含むヘッダーからトークン情報を取得
      client_id = request.headers["client"]
      uid = request.headers["uid"]
      access_token = request.headers["access-token"]

      # トークン情報を使用してユーザーを特定し、トークンを無効化する
      user = User.find_by_uid(uid)
      user.tokens.delete(client_id) if user

      if user&.save
          render json: { message: "ログアウトしました。" }
      else
          render json: { errors: [ "ログアウトに失敗しました。" ] }, status: :unprocessable_entity
      end
  end

  private

  def resource_params
    params.permit(:email, :password, :format)
  end

  respond_to :json    ## jsonを返すように指定する
end
