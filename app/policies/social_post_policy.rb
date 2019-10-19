# frozen_string_literal: true

class SocialPostPolicy < ApplicationPolicy
  def index?
    !user.nil? && user.role == 'ADMIN'
  end

  def show?
    !user.nil? && user.role == 'ADMIN'
  end

  def create?
    !user.nil? && user.role == 'ADMIN'
  end

  def update?
    !user.nil? && user.role == 'ADMIN'
  end

  def destroy?
    !user.nil? && user.role == 'ADMIN'
  end

  def cycle?
    !user.nil? && ['CRON', 'ADMIN'].include?(user.role)
  end
end
