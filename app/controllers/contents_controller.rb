# frozen_string_literal: true

class ContentsController < ApplicationController
  include Authenticatable
  
  before_action :set_content, only: %i[destroy]
  after_action :verify_authorized, except: %i[index show find_by_slug]

  # GET /contents
  def index
    @contents = Content
    @contents = @contents.where(content_type: params[:content_type]) if params[:content_type]
    @contents = if request.headers['Authorization'] && current_user
                  policy_scope(@contents)
                else
                  @contents.where('metadata @> ?', { published: true }.to_json)
                end

    render json: @contents,
           except: %i[organization_id updated_at],
           include: {
             organization: {
               except: %i[parent_id created_at updated_at],
               include: { ancestors: {} }
             }
           }
  end

  # GET /contents/1
  def show
    @content = Content.includes(%i[content_blocks organization])
    @content = @content.where(content_type: params[:content_type]) if params[:content_type]
    @content = if request.headers['Authorization'] && current_user
                 policy_scope(@content)
               else
                 @content.where('metadata @> ?', { published: true }.to_json)
               end

    render  json: @content.find(params[:id]),
            except: %i[organization_id updated_at],
            include: {
              organization: {
                except: %i[parent_id created_at updated_at],
                include: { ancestors: {} }
              },
              content_blocks: {
                except: %i[content_id]
              }
            }
  end

  # GET /contents/slug/:slug
  def find_by_slug
    @content = Content.includes(%i[content_blocks organization])
                      .where(content_type: 'page')
                      .where('metadata @> ?', { published: true, slug: params[:slug] }.to_json)

    if @content.empty?
      raise ActiveRecord::RecordNotFound.new("Couldn't find Content with slug='#{params[:slug]}'", 'Content')
    else
      render json: @content[0],
             except: %i[organization_id],
             include: {
               organization: {
                 except: %i[parent_id created_at updated_at],
                 include: {
                   ancestors: {}
                 }
               },
               content_blocks: {
                 except: %i[content_id]
               }
             }
    end
  end

  # POST /contents
  def create
    @content = Content.new(content_params)
    # authorize @content
    skip_authorization

    if @content.save
      render  json: @content,
              except: %i[organization_id updated_at],
              include: {
                organization: {
                  except: %i[parent_id created_at updated_at],
                  include: { ancestors: {} }
                },
                content_blocks: {
                  except: %i[content_id]
                }
              },
              status: :created,
              location: content_path(@content)
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

  # Use callbacks to share common setup or constraints between actions.
  def set_content
    @content = Content.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def content_params
    params.require(:data).permit(:uuid, :content_type, :organization_id, title: {}, metadata: {}, content_blocks_attributes: [:id, :uuid, :block_type, :order, body: {}])
  end
end
