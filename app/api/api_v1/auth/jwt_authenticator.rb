# frozen_string_literal: true

module APIv1
  module Auth
    class JWTAuthenticator
      def initialize(token)
        @token = token
      end

      #
      # Decodes and verifies JWT.
      # Returns authentic member email or raises an exception.
      #
      # @param [Hash] options
      # @return [String, User, NilClass]
      def authenticate!(options = {})
        Peatio::Auth::JWTAuthenticator
          .new(Utils.jwt_public_key)
          .authenticate!(@token)
          .yield_self { |payload| fetch_member(payload) }
          .yield_self { |member| options[:return] == :member ? member : fetch_email(payload) }
      rescue => e
        report_exception(e)
        if Peatio::Auth::Error === e
          raise e
        else
          raise Peatio::Auth::Error, e.inspect
        end
      end

      def authenticate!(options = {})
        payload, header = Peatio::Auth::JWTAuthenticator
                              .new(Utils.jwt_public_key)
                              .authenticate!(@token)
        fetch_user(payload).yield_self do |user|
          options[:return] == :user ? user : fetch_uid(payload)
        end
      rescue => e
        report_exception(e)
        if Peatio::Auth::Error === e
          raise e
        else
          raise Peatio::Auth::Error, e.inspect
        end
      end

      #
      # Exception-safe version of #authenticate!.
      #
      # @return [String, User, NilClass]
      def authenticate(*args)
        authenticate!(*args)
      rescue
        nil
      end

    private

      def fetch_email(payload)
        payload[:email].to_s.tap do |email|
          raise(Peatio::Auth::Error, 'E-Mail is blank.') if email.blank?
          raise(Peatio::Auth::Error, 'E-Mail is invalid.') unless EmailValidator.valid?(email)
        end
      end

      def fetch_uid(payload)
        payload.fetch(:uid).tap do |uid|
          raise(Peatio::Auth::Error, 'UID is blank.') if uid.blank?
        end
      end

      def fetch_scopes(payload)
        Array.wrap(payload[:scopes]).map(&:to_s).map(&:squash).reject(&:blank).tap do |scopes|
          raise(Peatio::Auth::Error, 'Token scopes are not defined.') if scopes.empty?
        end
      end

      def fetch_user(payload)
        if payload[:iss] == 'barong'
          from_barong_payload(payload)
        else
          User.find_by(uid: fetch_uid(payload))
        end
      end

      def from_barong_payload(payload)
        User.find_or_initialize_by(uid: fetch_uid(payload)).tap do |member|
          member.transaction do
            attributes = {
              email: fetch_email(payload),
              state: payload.fetch(:state).to_s,
              level: payload.fetch(:level).to_i
            }

            # Prevent overheat validations.
            member.assign_attributes(attributes)
            member.save!(validate: member.new_record?)
          end
        end
      end
    end
  end
end
