# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "google/cloud/bigtable/table/list"
require "google/cloud/bigtable/table/cluster_state"
require "google/cloud/bigtable/column_family_map"
require "google/cloud/bigtable/gc_rule"
require "google/cloud/bigtable/mutation_operations"
require "google/cloud/bigtable/read_operations"

module Google
  module Cloud
    module Bigtable
      ##
      # # Table
      #
      # A collection of user data indexed by row, column, and timestamp.
      # Each table is served using the resources of its parent cluster.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.table("my-instance", "my-table")
      #
      #   if table.exists?
      #     p "Table exists."
      #   else
      #     p "Table does not exist"
      #   end
      #
      class Table
        # @!parse extend MutationOperations
        include MutationOperations

        # @!parse extend ReadOperations
        include ReadOperations

        # @private
        # The gRPC Service object.
        attr_accessor :service

        ##
        # @return [String] App profile ID for request routing.
        #
        attr_accessor :app_profile_id

        # @private
        #
        # Creates a new Table instance.
        def initialize grpc, service, view: nil
          @grpc = grpc
          @service = service
          @view = view || :SCHEMA_VIEW
        end

        ##
        # The unique identifier for the project.
        #
        # @return [String]
        #
        def project_id
          @grpc.name.split("/")[1]
        end

        ##
        # The unique identifier for the instance.
        #
        # @return [String]
        #
        def instance_id
          @grpc.name.split("/")[3]
        end

        ##
        # The unique identifier for the table.
        #
        # @return [String]
        #
        def name
          @grpc.name.split("/")[5]
        end
        alias table_id name

        ##
        # The full path for the table resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/table/<table_id>`.
        #
        # @return [String]
        #
        def path
          @grpc.name
        end

        ##
        # Reload table information.
        #
        # @param view [Symbol] Table view type.
        #   Default view type is `:SCHEMA_VIEW`
        #   Valid view types are:
        #
        #   * `:NAME_ONLY` - Only populates `name`
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        def reload! view: nil
          @view = view || :SCHEMA_VIEW
          @grpc = service.get_table instance_id, name, view: view
          self
        end

        ##
        # Map from cluster ID to per-cluster table state.
        # If it could not be determined whether or not the table has data in a
        # particular cluster (for example, if its zone is unavailable), then
        # there will be an entry for the cluster with UNKNOWN `replication_status`.
        # Views: `FULL`
        #
        # @return [Array<Google::Cloud::Bigtable::Table::ClusterState>]
        #
        def cluster_states
          check_view_and_load :REPLICATION_VIEW
          @grpc.cluster_states.map do |name, state_grpc|
            ClusterState.from_grpc state_grpc, name
          end
        end

        ##
        # Returns a frozen object containing the column families configured for
        # the table, mapped by column family name. Reloads the table if
        # necessary to retrieve the column families data, since it is only
        # available in a table with view type `SCHEMA_VIEW` or `FULL`.
        #
        # Also accepts a block for making modifications to the table's column
        # families. After the modifications are completed, the table will be
        # updated with the changes, and the updated column families will be
        # returned.
        #
        # @yield [column_families] A block for modifying the table's column
        #   families. Applies multiple column modifications. Performs a series
        #   of column family modifications on the specified table. Either all or
        #   none of the modifications will occur before this method returns, but
        #   data requests received prior to that point may see a table where
        #   only some modifications have taken effect.
        # @yieldparam [ColumnFamilyMap] column_families
        #   A mutable object containing the column families for the table,
        #   mapped by column family name. Any changes made to this object will
        #   be stored in API.
        #
        # @return [ColumnFamilyMap] A frozen object containing the
        #   column families for the table, mapped by column family name.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
        #
        #   table.column_families.each do |name, cf|
        #     puts name
        #     puts cf.gc_rule
        #   end
        #
        #   # Get a column family by name
        #   cf1 = table.column_families["cf1"]
        #
        # @example Modify the table's column families
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
        #
        #   table.column_families do |cfm|
        #     cfm.add "cf4", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #     cfm.add "cf5", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #
        #     rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
        #     rule_union = Google::Cloud::Bigtable::GcRule.union(rule_1, rule_2)
        #     cfm.update "cf2", gc_rule: rule_union
        #
        #     cfm.delete "cf3"
        #   end
        #
        #   puts table.column_families["cf3"] #=> nil
        #
        def column_families
          check_view_and_load :SCHEMA_VIEW

          if block_given?
            column_families = ColumnFamilyMap.from_grpc @grpc.column_families
            yield column_families
            modifications = column_families.modifications @grpc.column_families
            @grpc = service.modify_column_families instance_id, table_id, modifications if modifications.any?
          end

          ColumnFamilyMap.from_grpc(@grpc.column_families).freeze
        end

        ##
        # The granularity (e.g. `MILLIS`, `MICROS`) at which timestamps are stored in
        # this table. Timestamps not matching the granularity will be rejected.
        # If unspecified at creation time, the value will be set to `MILLIS`.
        # Views: `SCHEMA_VIEW`, `FULL`
        #
        # @return [Symbol]
        #
        def granularity
          check_view_and_load :SCHEMA_VIEW
          @grpc.granularity
        end

        ##
        # The table keeps data versioned at a granularity of 1 ms.
        #
        # @return [Boolean]
        #
        def granularity_millis?
          granularity == :MILLIS
        end

        ##
        # Permanently deletes the table from a instance.
        #
        # @return [Boolean] Returns `true` if the table was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
        #   table.delete
        #
        def delete
          ensure_service!
          service.delete_table instance_id, name
          true
        end

        ##
        # Checks to see if the table exists.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   if table.exists?
        #     p "Table exists."
        #   else
        #     p "Table does not exist"
        #   end
        #
        # @example Using Cloud Bigtable instance
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   if table.exists?
        #     p "Table exists."
        #   else
        #     p "Table does not exist"
        #   end
        #
        def exists?
          !service.get_table(instance_id, name, view: :NAME_ONLY).nil?
        rescue Google::Cloud::NotFoundError
          false
        end

        # @private
        # Creates a table.
        #
        # @param service [Google::Cloud::Bigtable::Service]
        # @param instance_id [String]
        # @param table_id [String]
        # @param column_families [ColumnFamilyMap]
        # @param granularity [Symbol]
        # @param initial_splits [Array<String>]
        # @yield [column_families] A block for adding column_families.
        # @yieldparam [ColumnFamilyMap]
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.create service, instance_id, table_id, column_families: nil, granularity: nil, initial_splits: nil
          if column_families
            # create an un-frozen and duplicate object
            column_families = ColumnFamilyMap.from_grpc column_families.to_grpc
          end
          column_families ||= ColumnFamilyMap.new

          yield column_families if block_given?

          table = Google::Bigtable::Admin::V2::Table.new({
            column_families: column_families.to_grpc_hash,
            granularity:     granularity
          }.delete_if { |_, v| v.nil? })

          grpc = service.create_table instance_id, table_id, table, initial_splits: initial_splits
          from_grpc grpc, service
        end

        ##
        # Generates a consistency token for a table. The token can be used in
        # CheckConsistency to check whether mutations to the table that finished
        # before this call started have been replicated. The tokens will be available
        # for 90 days.
        #
        # @return [String] Generated consistency token
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   table.generate_consistency_token # "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF"
        #
        def generate_consistency_token
          ensure_service!
          response = service.generate_consistency_token instance_id, name
          response.consistency_token
        end

        ##
        # Checks replication consistency based on a consistency token. Replication is
        # considered consistent if replication has caught up based on the conditions
        # specified in the token and the check request.
        # @param token [String] Consistency token
        # @return [Boolean] Replication is consistent or not.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   token = "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF"
        #
        #   if table.check_consistency(token)
        #     puts "Replication is consistent"
        #   end
        #
        def check_consistency token
          ensure_service!
          response = service.check_consistency instance_id, name, token
          response.consistent
        end

        ##
        # Wait for replication to check replication consistency.
        # Checks replication consistency by generating a consistency token and
        # making the `check_consistency` API call 5 times (by default).
        # If the response is consistent, returns true. Otherwise tries again
        # repeatedly until the timeout. If the check does not succeed by the
        # timeout, returns `false`.
        #
        # @param timeout [Integer]
        #   Timeout in seconds. Defaults value is 600 seconds.
        # @param check_interval [Integer]
        #   Consistency check interval in seconds. Default is 5 seconds.
        # @return [Boolean] Replication is consistent or not.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", perform_lookup: true)
        #
        #   if table.wait_for_replication
        #     puts "Replication done"
        #   end
        #
        #   # With custom timeout and interval
        #   if table.wait_for_replication(timeout: 300, check_interval: 10)
        #     puts "Replication done"
        #   end
        #
        def wait_for_replication timeout: 600, check_interval: 5
          raise InvalidArgumentError, "'check_interval' can not be greather then timeout" if check_interval > timeout
          token = generate_consistency_token
          status = false
          start_at = Time.now

          loop do
            status = check_consistency token

            break if status || (Time.now - start_at) >= timeout
            sleep check_interval
          end
          status
        end

        # @private
        # Gets the data client instance.
        #
        # @return [Google::Cloud::Bigtable::V2::BigtableClient]
        #
        def client
          service.client
        end

        ##
        # Deletes all rows.
        #
        # @param timeout [Integer] Call timeout in seconds
        #   Use in case of insufficient deadline for DropRowRange, then
        #   try again with a longer request deadline.
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #   table.delete_all_rows
        #
        #   # With timeout
        #   table.delete_all_rows(timeout: 120) # 120 seconds.
        #
        def delete_all_rows timeout: nil
          drop_row_range delete_all_data: true, timeout: timeout
        end

        ##
        # Deletes rows using row key prefix.
        #
        # @param prefix [String] Row key prefix (for example, "user")
        # @param timeout [Integer] Call timeout in seconds
        # @return [Boolean]
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   table.delete_rows_by_prefix("user-100")
        #
        #   # With timeout
        #   table.delete_rows_by_prefix("user-1", timeout: 120) # 120 seconds.
        #
        def delete_rows_by_prefix prefix, timeout: nil
          drop_row_range row_key_prefix: prefix, timeout: timeout
        end

        ##
        # Drops row range by row key prefix or deletes all.
        #
        # @param row_key_prefix [String] Row key prefix (for example, "user")
        # @param delete_all_data [Boolean]
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
        #
        #   # Delete rows using row key prefix.
        #   table.drop_row_range(row_key_prefix: "user-100")
        #
        #   # Delete all data With timeout
        #   table.drop_row_range(delete_all_data: true, timeout: 120) # 120 seconds.
        #
        def drop_row_range row_key_prefix: nil, delete_all_data: nil, timeout: nil
          ensure_service!
          service.drop_row_range(
            instance_id,
            name,
            row_key_prefix:             row_key_prefix,
            delete_all_data_from_table: delete_all_data,
            timeout:                    timeout
          )
          true
        end

        # @private
        # Creates a new Table instance from a Google::Bigtable::Admin::V2::Table.
        #
        # @param grpc [Google::Bigtable::Admin::V2::Table]
        # @param service [Google::Cloud::Bigtable::Service]
        # @param view [Symbol] View type.
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.from_grpc grpc, service, view: nil
          new grpc, service, view: view
        end

        # @private
        # Creates a new Table object from table path.
        #
        # @param path [String] Table path.
        #   Formatted table path
        #   +projects/<project>/instances/<instance>/tables/<table>+
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.from_path path, service
          grpc = Google::Bigtable::Admin::V2::Table.new name: path
          new grpc, service, view: :NAME_ONLY
        end

        protected

        # @private
        # Raises an error unless an active connection to the service is
        # available.
        #
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        FIELDS_BY_VIEW = {
          SCHEMA_VIEW:      ["granularity", "column_families"],
          REPLICATION_VIEW: ["cluster_states"],
          FULL:             ["granularity", "column_families", "cluster_states"]
        }.freeze

        # @private
        #
        # Checks and reloads table with expected view and sets fields.
        # @param view [Symbol] Expected view type.
        #
        def check_view_and_load view
          ensure_service!
          @loaded_views ||= Set.new [@view]

          return if @loaded_views.include?(view) || @loaded_views.include?(:FULL)

          grpc = service.get_table instance_id, table_id, view: view
          @loaded_views << view

          FIELDS_BY_VIEW[view].each do |field|
            case grpc[field]
            when Google::Protobuf::Map
              @grpc[field].clear
              grpc[field].each { |k, v| @grpc[field][k] = v }
            else
              @grpc[field] = grpc[field]
            end
          end
        end
      end
    end
  end
end
