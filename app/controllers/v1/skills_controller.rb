# frozen_string_literal: true

# module V1
module V1
  # skill class controller
  class SkillsController < ApplicationController
    before_action :authenticate_user!

    def index
      @skills = Skill.all
      render json: @skills
    end

    def show
      @skill = Skill.find_by(id: params[:id])
      if @skill
        render json: @skill
      else
        render json: { error: 'Skill not found' }, status: :not_found
      end
    end
  end
end
