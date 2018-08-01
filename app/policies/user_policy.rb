# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    !user.nil? && user == resource
  end

  def logout?
    # resource is an AuthenticationToken
    !user.nil? && user == resource.user
  end

  def destroy?
    !user.nil? && (user == resource || user.role == 'ADMIN')
  end
end
