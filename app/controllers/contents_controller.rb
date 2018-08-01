# frozen_string_literal: true

class ContentsController < ApplicationController
  before_action :set_content, only: %i[destroy]
  after_action :verify_authorized, except: %i[index show]

  # GET /contents
  def index
    @contents = Content.where(content_type: params[:content_type]) if params[:content_type]
    @contents = if request.headers['X-Auth-Token'] && current_user
                  policy_scope(@contents)
                else
                  @contents.where('metadata @> ?', { published: true }.to_json)
                end

    render json: @contents
  end

  # GET /contents/1
  def show
    @content = Content.includes(%i[content_blocks organization])
    @content = @content.where(content_type: params[:content_type]) if params[:content_type]
    @content = if request.headers['X-Auth-Token'] && current_user
                 policy_scope(@content)
               else
                 @content.where('metadata @> ?', { published: true }.to_json)
               end

    render  json: @content.find(params[:id]),
            except: %i[organization_id],
            include: {
              organization: {
                except: %i[parent_id created_at updated_at],
                include: {
                  ancestors: {}
                }
              },
              content_blocks: {
                except: [:content_id]
              }
            }
  end

  # POST /contents
  def create
    @content = Content.new(content_params)
    authorize @content

    if @content.save
      render json: @content, status: :created, location: content_path(@content)
    else
      render json: @content.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contents/1
  def update
    @content = Content.find(params[:id])
    # Check that the user is allowed to edit this content
    authorize @content

    @content.assign_attributes(content_params)
    # Check that the user is allowed to save the edits (e.g., hasn't changed organization)
    authorize @content

    if @content.save
      render json: @content
    else
      render json: @content.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contents/1
  def destroy
    authorize @content
    @content.destroy
  end

  private

  def current_user
    token = AuthenticationToken.find_by(token: request.headers['X-Auth-Token'])
    token&.user
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_content
    @content = Content.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def content_params
    params.require(:data).permit(:content_type, :organization_id, title: {}, metadata: {})
  end
end
