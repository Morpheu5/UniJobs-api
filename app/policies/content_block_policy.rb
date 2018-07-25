# frozen_string_literal: true

class ContentBlockPolicy < ApplicationPolicy
  def index?
    user and user.organizations.include?(resource.content.organization)
  end

  def create?
    user and (user.role == 'ADMIN' or user.organizations.include?(resource.content.organization))
  end

  def update?
    user and (user.role == 'ADMIN' or user.organizations.include?(resource.content.organization))
  end

  def destroy?
    user and (user.role == 'ADMIN' or user.organizations.include?(resource.content.organization))
  end
end