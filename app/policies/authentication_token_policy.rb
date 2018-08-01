# frozen_string_literal: true

class AuthenticationTokenPolicy < ApplicationPolicy
  def destroy?
    !user.nil? && user == resource.user
  end
end
  