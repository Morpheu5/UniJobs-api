# frozen_string_literal: true

class ContentBlockPolicy < ApplicationPolicy
  def index?
    !user.nil? && (user.organizations.include?(resource.content.organization))
  end

  def create?
    !user.nil? && (user.role == 'ADMIN' || user.organizations.include?(resource.content.organization))
  end

  def update?
    !user.nil? && (user.role == 'ADMIN' || user.organizations.include?(resource.content.organization))
  end

  def destroy?
    !user.nil? && (user.role == 'ADMIN' || user.organizations.include?(resource.content.organization))
  end
end
