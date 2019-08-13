# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def create?
    !user.nil? && ['ADMIN', 'EDITOR'].include?(user.role)
  end

  def update?
    !user.nil? && ['ADMIN', 'EDITOR'].include?(user.role)
  end

  def destroy?
    !user.nil? && ['ADMIN'].include?(user.role)
  end
end