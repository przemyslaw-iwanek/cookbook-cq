#
# Cookbook Name:: cq
# Provider:: osgi_bundle
#
# Copyright (C) 2015 Jakub Wadolowski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Provider
    class CqOsgiBundle < Chef::Provider
      include Cq::OsgiHelper

      # Chef 12.4.0 support
      provides :cq_osgi_bundle if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::CqOsgiBundle.new(
          new_resource.symbolic_name
        )

        # {
        #   "id": 476,
        #   "name": "peaberry - Dynamic services for Google-Guice",
        #   "fragment": false,
        #   "stateRaw": 32,
        #   "state": "Active",
        #   "version": "1.3.0",
        #   "symbolicName": "org.ops4j.peaberry",
        #   "category": ""
        # }
        @current_resource.info = bundle_info(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          new_resource.symbolic_name
        )

        Chef::Log.debug("Bundle info: #{current_resource.info}")

        # Stop processing if there's no such bundle
        Chef::Application.fatal!(
          "#{current_resource.symbolic_name} bundle doesn't exist!"
        ) unless current_resource.info
      end

      def stop_bundle
        resp = bundle_op(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          current_resource.info['id'],
          'stop'
        )

        Chef::Application.fatal!(
          "Expected stateRaw 4, but got #{resp.code} HTTP response and "\
          "#{resp.body} body"
        ) unless valid_bundle_op?(resp, 4)
      end

      def start_bundle
        resp = bundle_op(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          current_resource.info['id'],
          'start'
        )

        Chef::Application.fatal!(
          "Expected stateRaw 32, but got #{resp.code} HTTP response and "\
          "#{resp.body} body"
        ) unless valid_bundle_op?(resp, 32)
      end

      def action_stop
        if current_resource.info['state'] == 'Active'
          converge_by("Stop #{new_resource.symbolic_name} bundle") do
            stop_bundle
          end

          osgi_stability_healthcheck(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          new_resource.rescue_mode,
          new_resource.same_state_barrier,
          new_resource.error_state_barrier,
          new_resource.max_attempts,
          new_resource.sleep_time
        )
        elsif current_resource.info['state'] == 'Resolved'
          Chef::Log.info(
            "#{current_resource.symbolic_name} bundle is already stopped"
          )
        else
          Chef::Log.warn(
            "#{current_resource.symbolic_name} is in "\
            "#{current_resource.info['state']} state. Only bundles in Active"\
            'state can be stopped'
          )
        end
      end

      def action_start
        if current_resource.info['state'] == 'Resolved'
          converge_by("Start #{new_resource.symbolic_name} bundle") do
            start_bundle
          end

          osgi_stability_healthcheck(
            new_resource.instance,
            new_resource.username,
            new_resource.password,
            new_resource.rescue_mode,
            new_resource.same_state_barrier,
            new_resource.error_state_barrier,
            new_resource.max_attempts,
            new_resource.sleep_time
          )
        elsif current_resource.info['state'] == 'Active'
          Chef::Log.info(
            "#{current_resource.symbolic_name} bundle is already started"
          )
        else
          Chef::Log.warn(
            "#{current_resource.symbolic_name} is in "\
            "#{current_resource.info['state']} state. Only bundles in "\
            'Resolved state can be started'
          )
        end
      end
    end
  end
end