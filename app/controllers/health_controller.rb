# frozen_string_literal: true

# サーバーが正常に動作していることを表示する
class HealthController < ApplicationController
  def show
    render json: { status: "ok" }
  end
end
