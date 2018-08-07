# frozen_string_literal: true

class ContentPolicy < ApplicationPolicy
  def index?
    !user.nil? && user.organizations.include?(resource.organization)
  end

  def create?
    !user.nil? && (user.role == 'ADMIN' || user.organizations.include?(resource.organization))
  end

  def update?
    !user.nil? && (user.role == 'ADMIN' || user.organizations.include?(resource.organization))
  end

  def destroy?
    !user.nil? && (user.role == 'ADMIN' || user.organizations.include?(resource.organization))
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
