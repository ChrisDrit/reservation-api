# frozen_string_literal: true

# Bookings.com Partner
#
# This model holds Bookings specifc logic for a reservation.
#
module Partners
  class Booking < Reservation

    # TODO: Memory.
    #
    # Think about loading this into memory on Rails initialize instead.
    #
    JSON_SCHEMA = Pathname.new(Rails.root.join('config', 'partners', 'schemas', 'booking.com.json'))

    # Create or Update Reservation for Bookings.com
    #
    # Based upon the Reservation JSON passed in, create or
    # update this Bookings.com Reservation, Guest, and Phone records.
    #
    # Exmaple of Bookings.com Reservation parsed into Hash:
    #
    # {
    #   :reservation => {
    #     :code => "XXX12345678",
    #     :start_date => "2021-03-12",
    #     :end_date => "2021-03-16",
    #     :expected_payout_amount => "3800.00",
    #     :guest_details => {
    #       :localized_description => "4 guests",
    #       :number_of_adults => 2,
    #       :number_of_children => 2,
    #       :number_of_infants => 0
    #     },
    #     :guest_email => "wayne_woodbridge@bnb.com",
    #     :guest_first_name => "Wayne",
    #     :guest_last_name => "Woodbridge",
    #     :guest_phone_numbers =>
    #       ["639123456789", "639123456789"],
    #     :listing_security_price_accurate => "500.00",
    #     :host_currency => "AUD",
    #     :nights => 4,
    #     :number_of_guests => 4,
    #     :status_type => "accepted",
    #     :total_paid_amount_accurate => "4300.00"
    #   }
    # }
    #
    # @param json [String] reservation data.
    # @return [Boolean] if successful.
    # @return [Exception] if it fails.
    #
    def create_or_update_from_json(json)
      reservation_hash = JSON.parse(json, symbolize_names: true)

      ActiveRecord::Base.transaction do
        guest = create_or_update_guest(reservation_hash)
        create_or_update_phone_numbers(reservation_hash, guest)
        create_or_update_reservation(reservation_hash, guest)
      end

    rescue ActiveRecord::RecordInvalid => e
      Rollbar.error(e, "Can't create or update this Bookings.com reservation!")
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
      data = reservation[:reservation]
      attributes = { first_name: data[:guest_first_name], last_name: data[:guest_last_name] }

      guest = Guest.find_by(email: data[:guest_email])

      if guest.present?
        guest.update!(attributes)
      else
        attributes.merge!(email: data[:guest_email])
        guest = Guest.create!(attributes)
      end

      guest
    end

    # Create Guest Phone Number Record
    #
    # This Bookings.com partner may send us more than
    # one phone number for a single guest.
    #
    # Delete & insert is not the best approach, but due
    # to time constraints this is what has been done.
    #
    # Well worth more time & effort!
    #
    # @param reservation [Hash] JSON parsed reservation data.
    # @param guest [Guest] object to associate.
    #
    def create_or_update_phone_numbers(reservation, guest)
      guest.phones.destroy_all if guest.phones.any?

      query = compile_phone_numbers_query(reservation, guest.id)
      Phone.insert_all!(query)
    end

    # Create Reservation Record
    #
    # @param reservation [Hash] JSON parsed reservation data.
    # @param guest [Guest] object to associate.
    # @return [Reservation] object
    #
    def create_or_update_reservation(reservation, guest)
      data = reservation[:reservation]
      fields = reservation_attributes(data)
      reservation_code = data[:code]

      record = Reservation.find_by(code: reservation_code)

      if record.present?
        record.update!(fields)
      else
        fields.merge!(code: reservation_code, guest_id: guest.id)
        Partners::Booking.create!(fields)
      end
    end

    private

    # Compile Phone Numbers Query
    #
    # Create an array of hashes, with model attributes, for use in a query.
    #
    # @param reservation [Hash] data including guest phone numbers.
    # @param guest_id [Integer] object used in query.
    # @return phone_numbers [Array] of hashes ready to use in a query.
    #
    def compile_phone_numbers_query(reservation, guest_id)
      phone_numbers = []
      reservation[:reservation][:guest_phone_numbers].each do |number|
        phone_numbers << { guest_id: guest_id, number: number, created_at: Time.now, updated_at: Time.now }
      end

      phone_numbers
    end

    # Reservation Attributes
    #
    # @param reservation [Hash] compiled from JSON.
    # @return [Hash] of database fields.
    #
    def reservation_attributes(reservation)
      {
        start_date: reservation[:start_date], end_date: reservation[:end_date],
        nights: reservation[:nights], guests: reservation[:number_of_guests],
        children: reservation[:guest_details][:number_of_children],
        infants: reservation[:guest_details][:number_of_infants], status: reservation[:status_type],
        currency: reservation[:host_currency], payout_price: reservation[:expected_payout_amount],
        security_price: reservation[:listing_security_price_accurate],
        total_price: reservation[:total_paid_amount_accurate],
        adults: reservation[:guest_details][:number_of_adults]
      }
    end

  end
end
