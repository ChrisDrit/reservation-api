# frozen_string_literal: true

# Phone Numbers
#
# The Bookings.com example JSON passed an array
# of phone numbers for a guest. This model handles
# that.
#
# There are other approaches to think through, but
# this is the one choosen for this example application.
#
class Phone < ApplicationRecord
  belongs_to :guest
end
