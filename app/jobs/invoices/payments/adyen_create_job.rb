# frozen_string_literal: true

module Invoices
  module Payments
    class AdyenCreateJob < ApplicationJob
      queue_as 'providers'

      unique :until_executed

      retry_on Faraday::ConnectionFailed, wait: :exponentially_longer, attempts: 6

      def perform(invoice)
        result = Invoices::Payments::AdyenService.new(invoice).create
        result.raise_if_error!
      end
    end
  end
end
