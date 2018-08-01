# frozen_string_literal: true

class AuthenticationTokenPolicy < ApplicationPolicy
  def destroy?
    user == resource.user
  end
end
