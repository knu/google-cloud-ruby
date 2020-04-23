# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!

require "google/cloud/dlp/version"
require "googleauth"
gem "google-cloud-core"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"

# Set the default configuration
Google::Cloud.configure.add_config! :dlp do |config|
  config.add_field! :credentials,  nil, match: [String, Hash, Google::Auth::Credentials]
  config.add_field! :lib_name,     nil, match: String
  config.add_field! :lib_version,  nil, match: String
  config.add_field! :interceptors, nil, match: Array
  config.add_field! :timeout,      nil, match: Numeric
  config.add_field! :metadata,     nil, match: Hash
  config.add_field! :retry_policy, nil, match: [Hash, Proc]
end

module Google
  module Cloud
    module Dlp
      ##
      # Create a new client object for DlpService.
      #
      # By default, this returns an instance of
      # [Google::Cloud::Dlp::V2::DlpService::Client](https://googleapis.dev/ruby/google-cloud-dlp-v2/latest/Google/Cloud/Dlp/V2/DlpService/Client.html)
      # for version V2 of the API.
      # However, you can specify specify a different API version by passing it in the
      # `version` parameter. If the DlpService service is
      # supported by that API version, and the corresponding gem is available, the
      # appropriate versioned client will be returned.
      #
      # ## About DlpService
      #
      # The Cloud Data Loss Prevention (DLP) API is a service that allows clients
      # to detect the presence of Personally Identifiable Information (PII) and other
      # privacy-sensitive data in user-supplied, unstructured data streams, like text
      # blocks or images.
      # The service also includes methods for sensitive data redaction and
      # scheduling of data scans on Google Cloud Platform based data sets.
      #
      # To learn more about concepts and find how-to guides see
      # https://cloud.google.com/dlp/docs/.
      #
      # @param version [String, Symbol] The API version to connect to. Optional.
      #   Defaults to `:v2`.
      # @return [DlpService::Client] A client object for the specified version.
      #
      def self.dlp_service version: :v2, &block
        require "google/cloud/dlp/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dlp
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dlp.const_get package_name
        package_module.const_get(:DlpService).const_get(:Client).new(&block)
      end

      ##
      # Configure the google-cloud-dlp library.
      #
      # The following configuration parameters are supported:
      #
      # * `credentials` (*type:* `String, Hash, Google::Auth::Credentials`) -
      #   The path to the keyfile as a String, the contents of the keyfile as a
      #   Hash, or a Google::Auth::Credentials object.
      # * `lib_name` (*type:* `String`) -
      #   The library name as recorded in instrumentation and logging.
      # * `lib_version` (*type:* `String`) -
      #   The library version as recorded in instrumentation and logging.
      # * `interceptors` (*type:* `Array<GRPC::ClientInterceptor>`) -
      #   An array of interceptors that are run before calls are executed.
      # * `timeout` (*type:* `Integer`) -
      #   Default timeout in milliseconds.
      # * `metadata` (*type:* `Hash{Symbol=>String}`) -
      #   Additional gRPC headers to be sent with the call.
      # * `retry_policy` (*type:* `Hash`) -
      #   The retry policy. The value is a hash with the following keys:
      #     * `:initial_delay` (*type:* `Numeric`) - The initial delay in seconds.
      #     * `:max_delay` (*type:* `Numeric`) - The max delay in seconds.
      #     * `:multiplier` (*type:* `Numeric`) - The incremental backoff multiplier.
      #     * `:retry_codes` (*type:* `Array<String>`) -
      #       The error codes that should trigger a retry.
      #
      # @return [Google::Cloud::Config] The default configuration used by this library
      #
      def self.configure
        yield Google::Cloud.configure.dlp if block_given?

        Google::Cloud.configure.dlp
      end
    end
  end
end
