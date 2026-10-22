# frozen_string_literal: true

module V1
  # 公開スキル（閲覧者向け）。書き込みは skill_drafts + オーナー公開のみ。
  class SkillsController < ApplicationController
    before_action :set_skill, only: :show

    def index
      render json: Skill.order(:id)
    end

    def show
      render json: @skill
    end

    private

    def set_skill
      @skill = Skill.find_by(id: params[:id])
      return if @skill

      render json: { error: "Skill not found" }, status: :not_found
    end
  end
end
