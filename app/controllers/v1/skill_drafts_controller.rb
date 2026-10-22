# frozen_string_literal: true

module V1
  class SkillDraftsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_draft, only: %i[update destroy]

    def index
      ensure_drafts!
      render json: draft_payload
    end

    def create
      form = Skills::SkillForm.new(draft_params)
      unless form.valid?
        return render json: { error: "Invalid request" }, status: :unprocessable_entity
      end

      draft = current_user.skill_drafts.create!(form.to_skill_attributes)
      render json: draft, status: :created
    end

    def update
      form = Skills::SkillForm.new(draft_params)
      unless form.valid?
        return render json: { error: "Invalid request" }, status: :unprocessable_entity
      end

      @draft.update!(form.to_skill_attributes)
      render json: @draft
    end

    def destroy
      @draft.destroy!
      head :no_content
    end

    # 公開 skills を自分の下書きにコピーし直す（誰でも可）
    def reset
      Skills::SyncDraftsFromPublishedService.call(user: current_user)
      render json: draft_payload
    end

    # 自分の下書きを公開 skills に反映（オーナーのみ）
    def publish
      Skills::PublishDraftsService.call(user: current_user)
      render json: { ok: true, skills: Skill.order(:id) }
    rescue Skills::PublishDraftsService::ForbiddenError
      render json: { error: "Forbidden" }, status: :forbidden
    end

    private

    def ensure_drafts!
      return if current_user.skill_drafts.exists?

      Skills::SyncDraftsFromPublishedService.call(user: current_user)
    end

    def draft_payload
      {
        drafts: current_user.skill_drafts.order(:id),
        can_publish: Skills::Owner.owner?(current_user)
      }
    end

    def set_draft
      @draft = current_user.skill_drafts.find_by(id: params[:id])
      return if @draft

      render json: { error: "Draft not found" }, status: :not_found
    end

    def draft_params
      params.permit(:category, :item, :term)
    end
  end
end
