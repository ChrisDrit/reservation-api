# frozen_string_literal: true

# Guest
#
# This model holds guest records with an association
# to the guests phone numbers and their one reservation.
#
class Guest < ApplicationRecord
  has_many :phones
  has_one :reservation

  validates :email, presence: true
end
