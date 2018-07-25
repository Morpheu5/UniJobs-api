# frozen_string_literal: true

class ContentBlocksController < ApplicationController
  before_action :set_content_block, only: %i[show update destroy]
  after_action :verify_authorized, except: %i[index show]

  # # GET /contents/1/content_blocks
  # # Probably not necessary
  # def index
  #   @content_blocks = ContentBlock.where(content_id: params[:content_id])
  #   if request.headers['X-Auth-Token'] && current_user
  #     @content_blocks.map { |b| authorize b }
  #   else

  #   end
  #   render json: @content_blocks
  # end

  # # GET /contents/1/content_blocks/1
  # def show
  #   render json: @content_block
  # end

  # POST /contents/1/content_blocks
  def create
    @content_block = ContentBlock.new(content_block_params)
    @content_block[:content_id] = params[:content_id]

    authorize @content_block

    if @content_block.save
      render json: @content_block, status: :created
    else
      render json: @content_block.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contents/1/content_blocks/1
  def update
    # Check that the user is allowed to create a content block
    authorize @content_block

    @content_block.assign_attributes(content_block_params)
    # Check that the user is allowed to save the edits
    authorize @content_block

    if @content_block.save
      render json: @content_block
    else
      render json: @content_block.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contents/1/content_blocks/1
  def destroy
    authorize @content_block
    @content_block.destroy
  end

  private

  def current_user
    token = AuthenticationToken.find_by(token: request.headers['X-Auth-Token'])
    token&.user
  end

  def set_content_block
    @content_block = ContentBlock.where(content_id: params[:content_id]).find(params[:id])
  end

  def content_block_params
    params.require(:data).permit(:block_type, :order, body: {})
  end
end
