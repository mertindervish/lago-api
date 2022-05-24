# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppliedCoupons::CreateService, type: :service do
  subject(:create_service) { described_class.new(membership.user) }

  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }

  let(:customer) { create(:customer, organization: organization) }
  let(:customer_id) { customer.id }

  let(:coupon) { create(:coupon, status: 'active', organization: organization) }
  let(:coupon_id) { coupon.id }

  let(:amount_cents) { nil }
  let(:amount_currency) { nil }

  before do
    create(:active_subscription, customer_id: customer_id) if customer
  end

  describe 'create' do
    let(:create_args) do
      {
        coupon_id: coupon_id,
        customer_id: customer_id,
        amount_cents: amount_cents,
        amount_currency: amount_currency,
        organization_id: organization.id,
      }
    end

    let(:create_result) { create_service.create(**create_args) }

    it 'applied the coupon to the customer' do
      expect { create_result }.to change(AppliedCoupon, :count).by(1)

      expect(create_result.applied_coupon.customer).to eq(customer)
      expect(create_result.applied_coupon.coupon).to eq(coupon)
      expect(create_result.applied_coupon.amount_cents).to eq(coupon.amount_cents)
      expect(create_result.applied_coupon.amount_currency).to eq(coupon.amount_currency)
    end

    context 'with overridden amount' do
      let(:amount_cents) { 123 }
      let(:amount_currency) { 'EUR' }

      it { expect(create_result.applied_coupon.amount_cents).to eq(123) }
      it { expect(create_result.applied_coupon.amount_currency).to eq('EUR') }

      context 'when currency does not match' do
        let(:amount_currency) { 'NOK' }

        it { expect(create_result).not_to be_success }
        it { expect(create_result.error).to eq('currencies_does_not_match') }
      end
    end

    context 'when customer is not found' do
      let(:customer) { nil }
      let(:customer_id) { 'foo' }

      it { expect(create_result).not_to be_success }
      it { expect(create_result.error).to eq('not_found') }
    end

    context 'when coupon is not found' do
      let(:coupon_id) { 'foo' }

      it { expect(create_result).not_to be_success }
      it { expect(create_result.error).to eq('not_found') }
    end

    context 'when coupon is inactive' do
      before { coupon.terminated! }

      it { expect(create_result).not_to be_success }
      it { expect(create_result.error).to eq('not_found') }
    end

    context 'when customer does not have a subscription' do
      before { customer.active_subscription.terminated! }

      it { expect(create_result).not_to be_success }
      it { expect(create_result.error).to eq('no_active_subscription') }
    end

    context 'when coupon is already applied to the customer' do
      before { create(:applied_coupon, customer: customer, coupon: coupon) }

      it { expect(create_result).not_to be_success }
      it { expect(create_result.error).to eq('coupon_already_applied') }
    end

    context 'when currency of coupon does not match customer currency' do
      let(:coupon) { create(:coupon, status: 'active', organization: organization, amount_currency: 'NOK') }

      it { expect(create_result).not_to be_success }
      it { expect(create_result.error).to eq('currencies_does_not_match') }
    end
  end
end
