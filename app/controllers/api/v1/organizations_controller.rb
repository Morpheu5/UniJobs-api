# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApplicationController
      def_param_group :organization_response do
        property :id, Integer, 'Organization ID', required: true
        property :parent_id, Integer, 'ID of the parent organization, or null', allow_nil: true
        property :name, String, 'Full name of the organization', required: true
        property :short_name, String, 'Short name of the organization', required: true
      end

      api :GET, '/organizations', 'Free-text organization search'
      param :q, String, 'URL encoded search string'
      returns array_of: :organization_response, code: 200, desc: 'Returns all the organizations that match the query provided. Returns all the organizations in the database if no query is provided.'
      def index
        os = params[:q] ? Organization.find_by(name_parts: params[:q].split(' ')) : Organization.all
        @organizations = make_tree(os.map(&:attributes))
        render json: @organizations
      end

      api :GET, '/organizations/:id', 'Retrieve one organization'
      param :id, Integer, 'Organization ID'
      returns code: 200 do
        param_group :organization_response
        property :created_at, DateTime
        property :updated_at, DateTime
      end
      error :not_found
      def show
        @organization = Organization.find(params[:id])
        render json: @organization
      end

      api :GET, '/organizations/:id/ancestors', 'Retrieve the ancestors of an organization'
      param :id, Integer, 'Organization ID'
      returns array_of: :organization_response, desc: 'All the ancestors of an organization, in root-to-leaf order'
      def ancestors
        @ancestors = Organization.find_ancestors(id: params[:id])
        render json: @ancestors
      end

      private

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
