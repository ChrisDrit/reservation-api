# frozen_string_literal: true

# Reservation
#
# This is the core STI model for Guest reservations
# with any partner that we support.
#
# Supported partners are those subclassed by this
# parent model.
#
class Reservation < ApplicationRecord
  belongs_to :guest

  validates :code, presence: true

  class << self

    # Classify the Reservation
    #
    # Take the JSON reservation data passed in and classify it
    # as being one of the children inheriting this parent class.
    #
    # Do this by looping through all of the subclasses for this
    # parent class.
    #
    # * If there is a match, return the subclass name.
    # * If there is no match, return 'nil'.
    #
    # @param json [String] of reservation data.
    #
    # @return [String] subclass name if it has been classified.
    # @return [Nil] if subclass has not been classified.
    #
    def classify(json)
      Reservation.subclasses.map(&:name).each do |name|
        klass = name.constantize
        schema = klass::JSON_SCHEMA

        if json_matches_schema?(schema, json)
          @success = name
          break
        end
      end

      @success
    end

    # JSON Matches Schema?
    #
    # Match the hard-coded schema found in each child
    # class against the passed in JSON schema.
    #
    # * If there is a match, it's valid.
    # * If there is no match, it has not been validated.
    #
    # @params schema [Pathname] to the hard-coded schema file.
    # @params json [String] of reservation data.
    #
    # @return [Boolean] if we have a valid match or not.
    #
    def json_matches_schema?(schema, json)
      schemer = JSONSchemer.schema(schema)
      schemer.valid?(JSON.parse(json))
    end

  end
end
