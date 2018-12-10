# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user&.role == 'ADMIN'
  end

  def update?
    user == resource || user&.role == 'ADMIN'
  end

  def logout?
    # resource is an AuthenticationToken
    user == resource.user
  end

  def destroy?
    user == resource || user&.role == 'ADMIN'
  end

  def whoami?
    user == resource
  end
end
