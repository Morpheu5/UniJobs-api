# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :set_job, only: %i[destroy]

  # GET /jobs
  def index
    @jobs = Content.where content_type: 'job'
    render json: @jobs
  end

  # GET /jobs/1
  def show
    @job = Content.includes(:content_blocks)
                  .where(content_type: 'job')
                  .find(params[:id])
    render json: @job, include: { content_blocks: { except: [:content_id] } }
  end

  # POST /jobs
  def create
    @job = Content.new(job_params)

    if @job.save
      render json: @job, status: :created, location: job_path(@job)
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/1
  def update
    @job = Content.where(content_type: 'job').find(params[:id])

    if @job.update(job_params)
      render json: @job
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_job
    @job = Content.where(content_type: 'job').find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def job_params
    params.require(:data).permit(:content_type, :title => {}, :metadata => {})
  end
end
