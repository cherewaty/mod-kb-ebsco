require 'rails_helper'

RSpec.describe "Packages", type: :request do
  let(:okapi_token) { ENV.fetch('TEST_OKAPI_TOKEN') }

  let(:headers) do
    {
      'X-Okapi-Url': 'https://okapi-sandbox.frontside.io',
      'X-Okapi-Tenant': 'fs',
      'X-Okapi-Token': okapi_token
    }
  end

  describe "searching for packages" do
    before do
      VCR.use_cassette("search-packages") do
        get '/eholdings/jsonapi/packages/?q=ebsco', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets a list of resources" do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(101)
    end
  end

  describe "getting a specific package" do
    before do
      VCR.use_cassette("get-packages-success") do
        get '/eholdings/jsonapi/packages/19-6581', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets the resource" do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('packages')
      expect(json.data.id).to eq('19-6581')
      expect(json.data.attributes).to include(
        'name',
        'contentType',
        'titleCount',
        'selectedCount',
        'customCoverage',
        'visibilityData',
        'isSelected',
        'vendorName'
      )
      expect(json.data.attributes.vendorId).to eq(19)
      expect(json.data.attributes.packageId).to eq(6581)
    end

    it "returns a human readable content type" do
      expect(json.data.attributes.contentType).to eq('Aggregated Full Text')
    end

    it "returns a valid visibility reason" do
      expect(json.data.attributes.visibilityData.reason).to eq('All titles in this package are hidden')
    end
  end

  describe "getting a package with customer resources" do
    before do
      VCR.use_cassette("get-packages-customer-resources") do
        get '/eholdings/jsonapi/packages/19-6581?include=customerResources', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "includes a list of customer resources" do
      expect(json.data.relationships.customerResources.data.length).to eq(25)
      expect(json.included.length).to eq(25)
    end

    it "returns the correct included type" do
      expect(json.included.first.type).to eq('customerResources')
    end
  end

  describe "getting a non-existing package" do
    before do
      VCR.use_cassette("get-packages-not-found") do
        get '/eholdings/jsonapi/packages/1', headers: headers
      end
    end

    it "returns a not found error" do
      expect(response).to have_http_status(404)
    end
  end
end