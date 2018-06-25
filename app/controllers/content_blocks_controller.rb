# frozen_string_literal: true

class ContentBlocksController < ApplicationController
  before_action :set_content_block, only: %i[show update destroy]

  def index
    @content_blocks = ContentBlock.where(content_id: params[:content_id]).all
    render json: @content_blocks
  end

  # GET /contents/1/content_blocks/1
  def show
    render json: @content_block
  end

  # POST /contents/1/content_blocks
  def create
    @content_block = ContentBlock.new(content_block_params)
    @content_block[:content_id] = params[:content_id]

    if @content_block.save
      render json: @content_block, status: :created
    else
      render json: @content_block.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contents/1/content_blocks/1
  def update
    if @content_block.update(content_block_params)
      render json: @content_block
    else
      render json: @content_block.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contents/1/content_blocks/1
  def destroy
    @content_block.destroy
  end

  private

  def set_content_block
    @content_block = ContentBlock.where(content_id: params[:content_id]).find(params[:id])
  end

  def content_block_params
    params.require(:data).permit(:block_type, :order, body: {})
  end
end
