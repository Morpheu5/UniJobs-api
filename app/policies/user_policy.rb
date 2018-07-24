class UserPolicy < ApplicationPolicy
  def update?
    !user.nil? and user == resource
  end

  def logout?
    !user.nil? and user == resource
  end

  def destroy?
    !user.nil? and (user == resource or user.role == 'ADMIN')
  end
end