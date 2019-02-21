require "topological_inventory/openshift/operations/core/service_offering_retriever"

module TopologicalInventory
  module Openshift
    module Operations
      module Core
        RSpec.describe ServiceOfferingRetriever do
          let(:subject) { described_class.new(123) }

          describe "#process" do
            let(:url) { "http://localhost:3000/r/insights/platform/topological-inventory/v0.1/service_offerings/123" }
            let(:headers) { {"Content-Type" => "application/json"} }
            let(:dummy_response) { {"name" => "dummy"} }

            before do
              stub_request(:get, url).with(:headers => headers).to_return(:body => dummy_response.to_json, :headers => headers)
            end

            around do |e|
              url = ENV["TOPOLOGICAL_INVENTORY_URL"]
              ENV["TOPOLOGICAL_INVENTORY_URL"] = "http://localhost:3000"
              uri = URI.parse(ENV["TOPOLOGICAL_INVENTORY_URL"])
              TopologicalInventoryApiClient.configure do |config|
                config.scheme = uri.scheme || "http"
                config.host = "#{uri.host}:#{uri.port}"
              end

              e.run

              ENV["TOPOLOGICAL_INVENTORY_URL"] = url
            end

            it "returns the service offering response" do
              service_offering = subject.process
              expect(service_offering.class).to eq(TopologicalInventoryApiClient::ServiceOffering)
              expect(service_offering.name).to eq("dummy")
            end
          end
        end
      end
    end
  end
end
