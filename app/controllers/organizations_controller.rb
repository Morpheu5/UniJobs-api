# frozen_string_literal: true

class OrganizationsController < ApplicationController
  # GET /organizations(?q=this+and+that)
  def index
    os = params[:q] ? Organization.find_by_name_parts(params[:q].split(' ')) : Organization.all
    @organizations = make_tree(os.map(&:attributes))
    render json: @organizations
  end

  private

  def make_tree(list)
    hash = list.map { |l| [l['id'], l] }.to_h
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
