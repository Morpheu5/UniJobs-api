# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    user == resource
  end

  def logout?
    # resource is an AuthenticationToken
    user == resource.user
  end

  def destroy?
    user == resource || user&.role == 'ADMIN'
  end
end
