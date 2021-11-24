# frozen_string_literal: true

# Airbnb.com Partner
#
# This model holds Airbnb specifc logic for a reservation.
#
module Partners
  class Airbnb < Reservation

    # TODO: Memory.
    #
    # Think about loading this into memory on Rails initialize instead.
    #
    JSON_SCHEMA = Pathname.new(Rails.root.join('config', 'partners', 'schemas', 'airbnb.com.json'))

    # Create or Update the Reservation for Airbnb.com
    #
    # Based upon the Reservation JSON passed in, create or
    # update this Airbnb.com Reservation, Guest, and Phone records.
    #
    # Exmaple of Airbnb.com Reservation parsed into Hash:
    #
    # {
    #   "reservation_code" => "YYY12345678",
    #   "start_date" => "2021-04-14",
    #   "end_date" => "2021-04-18",
    #   "nights" => 4,
    #   "guests" => 4,
    #   "adults" => 2,
    #   "children" => 2,
    #   "infants" => 0,
    #   "status" => "accepted",
    #   "guest" => {
    #     "first_name" => "Wayne",
    #     "last_name" => "Woodbridge",
    #     "phone" => "639123456789",
    #     "email" => "wayne_woodbridge@bnb.com"
    #   },
    #   "currency" => "AUD",
    #   "payout_price" => "4200.00",
    #   "security_price" => "500",
    #   "total_price" => "4700.00"
    # }
    #
    # @param json [String] reservation data.
    #
    # @return [Boolean] if successful.
    # @return [Exception] if it fails.
    #
    def create_or_update_from_json(json)
      reservation_hash = JSON.parse(json, symbolize_names: true)

      ActiveRecord::Base.transaction do
        guest = create_or_update_guest(reservation_hash)
        create_or_update_phone_number(reservation_hash, guest)
        create_or_update_reservation(reservation_hash, guest)
      end

    rescue ActiveRecord::RecordInvalid => e
      Rollbar.error(e, "Can't create or update this Airbnb.com reservation!")
    end

    # Create or Update the Guest Record
    #
    # Not super efficient. The new hottness like `upsert` or
    # `create_or_find_by` in Rails 6 wasn't mature enough for
    # this use-case, at least within the given time constraints.
    #
    # Worth exploring further with more time...
    #
    # @param reservation [Hash] JSON parsed reservation data.
    # @return [Guest] object.
    #
    def create_or_update_guest(reservation)
      data = reservation[:guest]
      attributes = { first_name: data[:first_name], last_name: data[:last_name] }

      guest = Guest.find_by(email: data[:email])

      if guest.present?
        guest.update!(attributes)
      else
        attributes.merge!(email: data[:email])
        guest = Guest.create!(attributes)
      end
      guest
    end

    # Create or Update Guest Phone Number.
    #
    # * For Airbnb there is only ever 1 phone number.
    #
    # @param reservation [Hash] JSON parsed reservation data.
    # @param guest [Guest] object to associate.
    #
    def create_or_update_phone_number(reservation, guest)
      data = reservation[:guest]

      if guest.phones.any?
        guest.phones.first.update!(number: data[:phone])
      else
        guest.phones.create!(number: data[:phone])
      end
    end

    # Create or Update Reservation
    #
    # Same as the above Guest record above, not super efficient.
    #
    # @param reservation [Hash] JSON parsed reservation data
    # @param guest [Guest] object to associate
    #
    def create_or_update_reservation(reservation, guest)
      fields = reservation_attributes(reservation)
      reservation_code = reservation[:reservation_code]

      record = Reservation.find_by(code: reservation_code)

      if record.present?
        record.update!(fields)
      else
        fields.merge!(code: reservation_code, guest_id: guest.id)
        Partners::Airbnb.create!(fields)
      end
    end

    private

    # Reservation Attributes
    #
    # @param reservation [Hash] compiled from JSON.
    # @return [Hash] of database fields.
    #
    def reservation_attributes(reservation)
      {
        start_date: reservation[:start_date], end_date: reservation[:end_date],
        nights: reservation[:nights], guests: reservation[:guests],
        adults: reservation[:adults], children: reservation[:children],
        infants: reservation[:infants], status: reservation[:status],
        currency: reservation[:currency], payout_price: reservation[:payout_price],
        security_price: reservation[:security_price], total_price: reservation[:total_price]
      }
    end
  end
end
