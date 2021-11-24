# frozen_string_literal: true

class ProcessReservationRequestJob < ApplicationJob
  queue_as :default

  # Background Job
  #
  # Classify and Create / Update a Reservation
  #
  # * If not able to classify then raise Rollbar exception.
  # * If successfully classifed, create or update a reservation.
  #
  # When succssfully classified, convert the String class name
  # returned into an object and execute that objects method
  # to create or update a reservation.
  #
  # TODO: Think through retry pattern on failures.
  #
  # @param json [String] reservation data.
  #
  def perform(json)
    klass = Reservation.classify(json)
    raise 'Cannot classify this reservation!' unless klass.present?

    obj = klass.constantize.new
    obj.create_or_update_from_json(json)
  end
end
