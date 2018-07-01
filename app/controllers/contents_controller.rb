# frozen_string_literal: true

class ContentsController < ApplicationController
  before_action :set_content, only: %i[destroy]

  # GET /contents
  def index
    @contents = if params[:content_type]
                  Content.where(content_type: params[:content_type]).all
                else
                  Content.all
                end
    render json: @contents
  end

  # GET /contents/1
  def show
    if params[:content_type]
      @content = Content.includes(:content_blocks).where(content_type: params[:content_type]).find(params[:id])
    else
      @content = Content.includes(:content_blocks).find(params[:id])
    end
    render json: @content, include: { content_blocks: { except: [:content_id] } }
  end

  # POST /contents
  def create
    @content = Content.new(content_params)

    if @content.save
      render json: @content, status: :created, location: content_path(@content)
    else
      render json: @content.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contents/1
  def update
    @content = Content.find(params[:id])

    if @content.update(content_params)
      render json: @content
    else
      render json: @content.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contents/1
  def destroy
    @content.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content
    @content = Content.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def content_params
    params.require(:data).permit(:content_type, title: {}, metadata: {})
  end
end
