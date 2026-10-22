# frozen_string_literal: true

module V1
  class SkillsController < ApplicationController
    before_action :authenticate_user!, except: %i[index show]
    before_action :set_skill, only: %i[show update destroy]

    def index
      render json: Skill.order(:id)
    end

    def show
      render json: @skill
    end

    def create
      form = Skills::SkillForm.new(skill_params)
      unless form.valid?
        return render json: { error: "Invalid request" }, status: :unprocessable_entity
      end

      skill = Skill.create!(form.to_skill_attributes)
      render json: skill, status: :created
    end

    def update
      form = Skills::SkillForm.new(skill_params)
      unless form.valid?
        return render json: { error: "Invalid request" }, status: :unprocessable_entity
      end

      @skill.update!(form.to_skill_attributes)
      render json: @skill
    end

    def destroy
      @skill.destroy!
      head :no_content
    end

    private

    def set_skill
      @skill = Skill.find_by(id: params[:id])
      return if @skill

      render json: { error: "Skill not found" }, status: :not_found
    end

    def skill_params
      params.permit(:category, :item, :term)
    end
  end
end
