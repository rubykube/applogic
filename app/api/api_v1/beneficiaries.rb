# frozen_string_literal: true

module APIv1
  class Beneficiaries < Grape::API
    before { authenticate! }

    resource :beneficiaries do
      desc 'List all beneficiaries for current account.',
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
      get do
        present Beneficiary.by_current_user(current_user),
                with: APIv1::Entities::Beneficiary
      end

      desc 'Return a beneficiary by rid',
        failure: [
          { code: 400, message: 'Required params are empty' },
          { code: 401, message: 'Invalid bearer token' },
          { code: 404, message: 'Beneficiary is not found' }
        ]
      params do
        requires :rid, type: String, allow_blank: false
      end
      get ':rid' do
        beneficiary = Beneficiary.by_current_user(current_user)
                                 .find_by!(rid: params[:rid])
        present beneficiary,
                with: APIv1::Entities::Beneficiary
      end

      desc 'Create a beneficiary',
           failure: [
             { code: 400, message: 'Required params are empty' },
             { code: 401, message: 'Invalid bearer token' },
             { code: 422, message: 'Validation errors' }
           ]
      params do
        requires :full_name
        requires :address
        requires :country
        requires :currency
        requires :account_number
        requires :account_type
        requires :bank_name
        requires :bank_address
        requires :bank_country
        optional :bank_swift_code
        optional :intermediary_bank_name
        optional :intermediary_bank_address
        optional :intermediary_bank_country
        optional :intermediary_bank_swift_code
      end
      post do
        declared_params = declared(params, include_missing: false)
        beneficiary = Beneficiary.create(declared_params.merge(uid: current_user.uid))
        error!(beneficiary.errors.as_json, 422) if beneficiary.errors.any?

        present beneficiary,
                with: APIv1::Entities::Beneficiary
      end

      desc 'Updates a beneficiary',
           failure: [
             { code: 400, message: 'Required params are empty' },
             { code: 401, message: 'Invalid bearer token' },
             { code: 404, message: 'Beneficiary is not found' },
             { code: 422, message: 'Validation errors' }
           ]
      params do
        optional :rid, type: String, allow_blank: false
        optional :full_name
        optional :address
        optional :country
        optional :currency
        optional :account_number
        optional :account_type
        optional :bank_name
        optional :bank_address
        optional :bank_country
        optional :bank_swift_code
        optional :intermediary_bank_name
        optional :intermediary_bank_address
        optional :intermediary_bank_country
        optional :intermediary_bank_swift_code
      end
      patch ':rid' do
        declared_params = declared(params, include_missing: false)
        beneficiary = Beneficiary.by_current_user(current_user)
                                 .find_by!(rid: params[:rid])
        unless beneficiary.update(declared_params)
          error!(beneficiary.errors.as_json, 422)
        end

        present beneficiary,
                with: APIv1::Entities::Beneficiary
      end

      desc 'Delete a beneficiary',
           success: { code: 204, message: 'Succefully deleted' },
           failure: [
             { code: 400, message: 'Required params are empty' },
             { code: 401, message: 'Invalid bearer token' },
             { code: 404, message: 'Beneficiary is not found' }
           ]
      params do
        requires :rid, type: String, allow_blank: false
      end
      delete ':rid' do
        beneficiary = Beneficiary.by_current_user(current_user)
                                 .find_by!(rid: params[:rid])
        beneficiary.destroy
        status 204
      end
    end
  end
end
