# frozen_string_literal: true

module Api
  module V1
    class ReservationsController < ApplicationController

      # Create or Update a Reservation
      #
      # Receive new or updated reservation data from any
      # provider to this single API endpoint.
      #
      # Convert params to a simple object (.to_json) for use with Sidekiq.
      #
      # Immediatly return a '200' success response.
      #
      # TODO:
      #
      #   * Verify & confirm source of request.
      #   * Return errors on unverified requests.
      #
      # @return [JSON] blank 200 response.
      #
      def create
        ProcessReservationRequestJob.perform_later normalized_params.to_json
        render json: {}, status: :ok
      end

      private

      # Normalize Params
      #
      # Remove unwanted request paramters and keep only resesrvation data.
      #
      # @return [Params] normalized params.
      #
      def normalized_params
        params.except(:controller, :action)
      end
    end
  end
end
