# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApplicationController
      include ::V1::Authenticatable

      before_action :set_organization, only: %i[show update destroy]
      after_action :verify_authorized, only: %i[create]

      def_param_group :organization_response do
        property :id, :number, 'Organization ID', required: true
        property :parent_id, :number, 'ID of the parent organization, or null', allow_nil: true
        property :name, String, 'Full name of the organization', required: true
        property :short_name, String, 'Short name of the organization', required: true
      end

      def_param_group :organization_creation_params do
        param :data, Hash do
          param :name, String, 'Long name (e.g., Università di Padova)', required: true
          param :short_name, String, 'Short name (e.g., UniPD)', required: true
          param :parent_id, :number, 'ID of the parent organization, or null', required: false, allow_nil: true
        end
      end

      def_param_group :organization_update_params do
        param :data, Hash do
          param :name, String, 'Long name (e.g., Università di Padova)', required: false, allow_nil: true
          param :short_name, String, 'Short name (e.g., UniPD)', required: false, allow_nil: true
          param :parent_id, :number, 'ID of the parent organization, or null', required: false, allow_nil: true
        end
      end

      api :GET, '/organizations/tree', 'Free-text hierarchical organization search'
      param :q, String, 'URL encoded search string'
      returns array_of: :organization_response, code: 200, desc: 'Returns all the organizations that match the query provided with full hierarchy. Returns all the organizations in the database if no query is provided.'
      def free_text_tree
        os = params[:q] ? Organization.find_by_name_parts(params[:q].split(' ')) : Organization.all
        @organizations = make_tree(os.map(&:attributes))
        render json: @organizations
      end

      api :GET, '/organizations', 'Free-text organization search'
      param :q, String, 'URL encoded search string'
      returns array_of: :organization_response, code: 200, desc: 'Returns all the organizations that match the query provided including ancestors but in a flat array. Returns all the organizations in the database if no query is provided.'
      def index
        os = params[:q] ? Organization.find_by_name_parts(params[:q].split(' ')) : Organization.all
        @organizations = os
        render json: @organizations, include: { ancestors: {} }
      end

      api :GET, '/organizations/:id', 'Retrieve one organization'
      param :id, :number, 'Organization ID'
      returns code: 200 do
        param_group :organization_response
        property :created_at, DateTime
        property :updated_at, DateTime
      end
      error :not_found
      def show
        render json: @organization, include: { ancestors: {} }
      end

      api :GET, '/organizations/:id/ancestors', 'Retrieve the ancestors of an organization'
      param :id, :number, 'Organization ID'
      returns array_of: :organization_response, desc: 'All the ancestors of an organization, in root-to-leaf order'
      def ancestors
        @ancestors = Organization.find_ancestors(id: params[:id])
        render json: @ancestors
      end

      api :POST, '/organizations', 'Create a new Organization'
      param_group :organization_creation_params
      error :forbidden, 'Only admins and editors can create new Organizations'
      error :unprocessable_entity, 'Could not create the Organization'
      returns :organization_response, desc: 'The details of the newly created Organization'
      def create
        @organization = Organization.new(organization_params)
        authorize @organization

        if @organization.save
          render json: @organization,
                 include: { ancestors: {} },
                 except: %i[created_at updated_at]
        else
          render json: @organization.errors, status: :unprocessable_entity
        end
      end

      api :PATCH, '/organizations/:id', 'Update an Organization'
      api :PUT, '/organizations/:id', 'Update an Organization (see PATCH)'
      param :id, :number, 'The numeric ID of the Organization', required: true
      param_group :organization_update_params
      error :unauthorized, 'On anonymous requests'
      error :forbidden, 'Logged in user does not have permission to update the Organization'
      error :unprocessable_entity, 'Could not save changes to the Organization'
      returns :organization_response, desc: 'The details of the updated Organization'
      def update
        authorize @organization

        if @organization.save
          render json: @organization,
                 include: { ancestors: {} },
                 except: %i[created_at updated_at]
        else
          render json: @organization.errors, status: :unprocessable_entity
        end
      end

      api :DELETE, '/organizations/:id', 'Delete an Organization'
      param :id, :number, 'The numeric ID of the Organization', required: true
      def destroy
        authorize @organization
        # TODO Tombstone maybe
        # @organization.destroy
      end

      private

      def set_organization
        @organization = Organization.find(params[:id])
      end

      def organization_params
        params.require(:data).permit(:name, :short_name, :parent_id)
      end

      def make_tree(list)
        hash = list.map { |l| [l['id'], l.except('created_at', 'updated_at')] }.to_h
        keys = hash.keys

        keys.each do |k|
          next unless !hash[k]['parent_id'].nil? && !hash[k].nil?
          if hash[hash[k]['parent_id']].nil?
            hash[hash[k]['parent_id']] = Organization.find(k).attributes
          end
          hash[hash[k]['parent_id']]['children'] = [*hash[hash[k]['parent_id']]['children'], hash[k]]
        end

        hash.select { |_i, o| o['parent_id'].nil? }.map { |_k, v| v }
      end
    end
  end
end
