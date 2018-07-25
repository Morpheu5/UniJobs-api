# frozen_string_literal: true

class ContentPolicy < ApplicationPolicy
  def index?
    user and user.organizations.include?(resource.organization)
  end

  def create?
    user and (user.role == 'ADMIN' or user.organizations.include?(resource.organization))
  end

  def update?
    user and (user.role == 'ADMIN' or user.organizations.include?(resource.organization))
  end

  def destroy?
    user and (user.role == 'ADMIN' or user.organizations.include?(resource.organization))
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.role == 'ADMIN'
        scope.all
      else
        scope.where(organization: user.organizations)
      end
    end
  end
end