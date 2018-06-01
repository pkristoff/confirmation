# frozen_string_literal: true

#
# Admin for the candidates
#
class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:email],
         reset_password_keys: [:email]
end
