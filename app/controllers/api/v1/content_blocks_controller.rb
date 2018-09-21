# frozen_string_literal: true

module Api
  module V1
    class ContentBlocksController < ApplicationController
      include ::V1::Authenticatable

      before_action :set_content_block, only: %i[show update destroy]
      after_action :verify_authorized, except: %i[index show]

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

      def set_content_block
        @content_block = ContentBlock.where(content_id: params[:content_id]).find(params[:id])
      end

      def content_block_params
        params.require(:data).permit(:block_type, :order, body: {})
      end
    end
  end
end
