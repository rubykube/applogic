require 'yaml'
require 'openssl'

%w[peatio barong].each do |application|
  (YAML.load_file("config/#{application}_management_api_v1.yml") || {}).deep_symbolize_keys.tap do |x|
    x.fetch(:keychain).each do |id, key|
      x[:keychain][id][:value] = OpenSSL::PKey.read(Base64.urlsafe_decode64(key.fetch(:value)))
    end

    x.fetch(:actions).each do |action_name, action_settings|
      action_settings[:required_signatures].map!(&:to_sym)
      if action_settings[:required_signatures].empty?
        raise ArgumentError, "actions.#{action_name}.required_signatures is empty, " \
                             "however it should contain at least one value (in config/#{application}_management_api_v1.yml)."
      end
    end

    Rails.configuration.x.public_send "#{application}_management_api_v1_configuration=", x
  end
end

