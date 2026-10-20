# frozen_string_literal: true

module V1
  class PageViewsController < ApplicationController
    # ポートフォリオ向けの公開カウンター（認証不要）
    def create
      page_view = PageView.hit!(params.require(:path))
      render json: { path: page_view.path, count: page_view.count }, status: :ok
    end
  end
end
