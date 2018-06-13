require 'yaml'
require 'openssl'

unless Rails.env.test?
  (YAML.load_file('config/management_api_v1.yml') || {}).deep_symbolize_keys.each do |k, v|
    v.fetch(:keychain).each do |keychain_id, keychain_key|
      v[:keychain][keychain_id][:value] = OpenSSL::PKey.read(Base64.urlsafe_decode64(keychain_key.fetch(:value)))
    end

    v.fetch(:actions).each do |action_name, action_settings|
      action_settings[:required_signatures].map!(&:to_sym)
      if action_settings[:required_signatures].empty?
        raise ArgumentError, "actions.#{action_name}.required_signatures is empty, " \
                             'however it should contain at least one value (in config/management_api_v1.yml).'
      end
    end

    Rails.configuration.x.public_send "#{k}_management_api_v1_configuration=", v
  end
end
