# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charge, type: :model do
  describe '.validate_graduated_range' do
    subject(:charge) do
      build(:graduated_charge, properties: charge_properties)
    end

    let(:charge_properties) { [{ 'foo' => 'bar' }] }
    let(:validation_service) { instance_double(Charges::Validators::GraduatedService) }

    let(:service_response) do
      BaseService::Result.new.validation_failure!(
        errors: {
          amount: ['invalid_amount'],
          ranges: ['invalid_graduated_ranges'],
        },
      )
    end

    it 'delegates to a validation service' do
      allow(Charges::Validators::GraduatedService).to receive(:new)
        .and_return(validation_service)
      allow(validation_service).to receive(:valid?)
        .and_return(false)
      allow(validation_service).to receive(:result)
        .and_return(service_response)

      aggregate_failures do
        expect(charge).not_to be_valid
        expect(charge.errors.messages.keys).to include(:properties)
        expect(charge.errors.messages[:properties]).to include('invalid_amount')
        expect(charge.errors.messages[:properties]).to include('invalid_graduated_ranges')

        expect(Charges::Validators::GraduatedService).to have_received(:new)
          .with(charge: charge)
        expect(validation_service).to have_received(:valid?)
        expect(validation_service).to have_received(:result)
      end
    end

    context 'when charge model is not graduated' do
      subject(:charge) { build(:standard_charge) }

      it 'does not apply the validation' do
        allow(Charges::Validators::GraduatedService).to receive(:new)
          .and_return(validation_service)
        allow(validation_service).to receive(:valid?)
          .and_return(false)
        allow(validation_service).to receive(:result)
          .and_return(service_response)

        charge.valid?

        expect(Charges::Validators::GraduatedService).not_to have_received(:new)
        expect(validation_service).not_to have_received(:valid?)
        expect(validation_service).not_to have_received(:result)
      end
    end
  end

  describe '.validate_amount' do
    subject(:charge) do
      build(:standard_charge, properties: charge_properties)
    end

    let(:charge_properties) { [{ 'foo' => 'bar' }] }
    let(:validation_service) { instance_double(Charges::Validators::StandardService) }

    let(:service_response) do
      BaseService::Result.new.validation_failure!(
        errors: {
          amount: ['invalid_amount'],
        },
      )
    end

    it 'delegates to a validation service' do
      allow(Charges::Validators::StandardService).to receive(:new)
        .and_return(validation_service)
      allow(validation_service).to receive(:valid?)
        .and_return(false)
      allow(validation_service).to receive(:result)
        .and_return(service_response)

      aggregate_failures do
        expect(charge).not_to be_valid
        expect(charge.errors.messages.keys).to include(:properties)
        expect(charge.errors.messages[:properties]).to include('invalid_amount')

        expect(Charges::Validators::StandardService).to have_received(:new)
          .with(charge: charge)
        expect(validation_service).to have_received(:valid?)
        expect(validation_service).to have_received(:result)
      end
    end

    context 'when charge model is not graduated' do
      subject(:charge) { build(:graduated_charge) }

      it 'does not apply the validation' do
        allow(Charges::Validators::StandardService).to receive(:new)
          .and_return(validation_service)
        allow(validation_service).to receive(:valid?)
          .and_return(false)
        allow(validation_service).to receive(:result)
          .and_return(service_response)

        charge.valid?

        expect(Charges::Validators::StandardService).not_to have_received(:new)
        expect(validation_service).not_to have_received(:valid?)
        expect(validation_service).not_to have_received(:result)
      end
    end
  end

  describe '.validate_package' do
    subject(:charge) do
      build(:package_charge, properties: charge_properties)
    end

    let(:charge_properties) { [{ 'foo' => 'bar' }] }
    let(:validation_service) { instance_double(Charges::Validators::PackageService) }

    let(:service_response) do
      BaseService::Result.new.validation_failure!(
        errors: {
          amount: ['invalid_amount'],
          free_units: ['invalid_free_units'],
          package_size: ['invalid_package_size'],
        },
      )
    end

    it 'delegates to a validation service' do
      allow(Charges::Validators::PackageService).to receive(:new)
        .and_return(validation_service)
      allow(validation_service).to receive(:valid?)
        .and_return(false)
      allow(validation_service).to receive(:result)
        .and_return(service_response)

      aggregate_failures do
        expect(charge).not_to be_valid
        expect(charge.errors.messages.keys).to include(:properties)
        expect(charge.errors.messages[:properties]).to include('invalid_amount')
        expect(charge.errors.messages[:properties]).to include('invalid_free_units')
        expect(charge.errors.messages[:properties]).to include('invalid_package_size')

        expect(Charges::Validators::PackageService).to have_received(:new)
          .with(charge: charge)
        expect(validation_service).to have_received(:valid?)
        expect(validation_service).to have_received(:result)
      end
    end

    context 'when charge model is not package' do
      subject(:charge) { build(:standard_charge) }

      it 'does not apply the validation' do
        allow(Charges::Validators::PackageService).to receive(:new)
          .and_return(validation_service)
        allow(validation_service).to receive(:valid?)
          .and_return(false)
        allow(validation_service).to receive(:result)
          .and_return(service_response)

        charge.valid?

        expect(Charges::Validators::PackageService).not_to have_received(:new)
        expect(validation_service).not_to have_received(:valid?)
        expect(validation_service).not_to have_received(:result)
      end
    end
  end

  describe '.validate_percentage' do
    subject(:charge) { build(:percentage_charge, properties: charge_properties) }

    let(:charge_properties) { [{ 'foo' => 'bar' }] }
    let(:validation_service) { instance_double(Charges::Validators::PercentageService) }

    let(:service_response) do
      BaseService::Result.new.validation_failure!(
        errors: {
          amount: ['invalid_fixed_amount'],
          free_units_per_events: ['invalid_free_units_per_events'],
          free_units_per_total_aggregation: ['invalid_free_units_per_total_aggregation'],
          rate: ['invalid_rate'],
        },
      )
    end

    it 'delegates to a validation service' do
      allow(Charges::Validators::PercentageService).to receive(:new)
        .and_return(validation_service)
      allow(validation_service).to receive(:valid?)
        .and_return(false)
      allow(validation_service).to receive(:result)
        .and_return(service_response)

      aggregate_failures do
        expect(charge).not_to be_valid
        expect(charge.errors.messages.keys).to include(:properties)
        expect(charge.errors.messages[:properties]).to include('invalid_rate')
        expect(charge.errors.messages[:properties]).to include('invalid_fixed_amount')
        expect(charge.errors.messages[:properties]).to include('invalid_free_units_per_events')
        expect(charge.errors.messages[:properties]).to include('invalid_free_units_per_total_aggregation')

        expect(Charges::Validators::PercentageService).to have_received(:new)
          .with(charge: charge)
        expect(validation_service).to have_received(:valid?)
        expect(validation_service).to have_received(:result)
      end
    end

    context 'when charge model is not percentage' do
      subject(:charge) { build(:standard_charge) }

      it 'does not apply the validation' do
        allow(Charges::Validators::PercentageService).to receive(:new)
          .and_return(validation_service)
        allow(validation_service).to receive(:valid?)
          .and_return(false)
        allow(validation_service).to receive(:result)
          .and_return(service_response)
        charge.valid?

        expect(Charges::Validators::PercentageService).not_to have_received(:new)
        expect(validation_service).not_to have_received(:valid?)
        expect(validation_service).not_to have_received(:result)
      end
    end
  end

  describe '.validate_volume' do
    subject(:charge) do
      build(:volume_charge, properties: charge_properties)
    end

    let(:charge_properties) { { ranges: [{ 'foo' => 'bar' }] } }
    let(:validation_service) { instance_double(Charges::Validators::VolumeService) }

    let(:service_response) do
      BaseService::Result.new.validation_failure!(
        errors: {
          amount: ['invalid_amount'],
          ranges: ['invalid_ranges'],
        },
      )
    end

    it 'delegates to a validation service' do
      allow(Charges::Validators::VolumeService).to receive(:new)
        .and_return(validation_service)
      allow(validation_service).to receive(:valid?)
        .and_return(false)
      allow(validation_service).to receive(:result)
        .and_return(service_response)

      aggregate_failures do
        expect(charge).not_to be_valid
        expect(charge.errors.messages.keys).to include(:properties)
        expect(charge.errors.messages[:properties]).to include('invalid_amount')
        expect(charge.errors.messages[:properties]).to include('invalid_ranges')

        expect(Charges::Validators::VolumeService).to have_received(:new)
          .with(charge: charge)
        expect(validation_service).to have_received(:valid?)
        expect(validation_service).to have_received(:result)
      end
    end

    context 'when charge model is not volume' do
      subject(:charge) { build(:standard_charge) }

      it 'does not apply the validation' do
        allow(Charges::Validators::VolumeService).to receive(:new)
          .and_return(validation_service)
        allow(validation_service).to receive(:valid?)
          .and_return(false)
        allow(validation_service).to receive(:result)
          .and_return(service_response)

        charge.valid?

        expect(Charges::Validators::VolumeService).not_to have_received(:new)
        expect(validation_service).not_to have_received(:valid?)
        expect(validation_service).not_to have_received(:result)
      end
    end
  end
end
