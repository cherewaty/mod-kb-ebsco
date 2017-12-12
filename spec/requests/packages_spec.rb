require 'rails_helper'

RSpec.describe "Packages", type: :request do

  describe "searching for packages" do
    before do
      VCR.use_cassette("search-packages") do
        get '/eholdings/jsonapi/packages/?q=ebsco', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets a list of resources" do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(111)
    end
  end

  describe "getting a specific package" do
    before do
      VCR.use_cassette("get-packages-success") do
        get '/eholdings/jsonapi/packages/19-6581', headers: okapi_headers
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

  describe "getting a package with included customer resources" do
    before do
      VCR.use_cassette("get-packages-customer-resources") do
        get '/eholdings/jsonapi/packages/19-6581?include=customerResources', headers: okapi_headers
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

    it "returns empty arrays for array attributes" do
      expect(json.included[8].attributes.contributors).to eq([])
      expect(json.included[8].attributes.subjects).to eq([])
    end
  end

  describe "getting a package with included vendor" do
    before do
      VCR.use_cassette("get-packages-vendor") do
        get '/eholdings/jsonapi/packages/19-6581?include=vendor', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "includes a vendor" do
      # NOTE: has_one relationships are serialized as singleton hashes
      # there might be a better way to handle this, but for now we
      # wrap the relation in an array
      expect([json.data.relationships.vendor.data].length).to eq(1)
      expect(json.included.length).to eq(1)
    end

    it "returns the correct included type" do
      expect(json.included.first.type).to eq('vendors')
    end
  end

  describe "updating a package" do
    let(:update_headers) do
      okapi_headers.merge(
        {
          'Content-Type': 'application/vnd.api+json'
        }
      )
    end

    describe "when the package is not already selected" do
      describe "selecting a package" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": true,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isnotselected-toggle-isselected") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isnotselected-toggle-isselected-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is now selected" do
            expect(json.data.attributes.isSelected).to be true
          end

          it "is not hidden" do
            expect(json.data.attributes.visibilityData.isHidden).to be false
          end
        end
      end

      describe "hiding a package should fail" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": false,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isnotselected-toggle-ishidden") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          # TODO: should return 5xx instead
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isnotselected-toggle-ishidden-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is not selected" do
            expect(json.data.attributes.isSelected).to be false
          end

          it "is still not hidden" do
            expect(json.data.attributes.visibilityData.isHidden).to be false
          end
        end
      end

      describe "adding custom coverage should fail" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": "2003-01-01",
                  "endCoverage": "2004-01-01"
                },
                "isSelected": false,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isnotselected-add-customcoverage") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          # TODO: should return 5xx instead
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isnotselected-add-customcoverage-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is not selected" do
            expect(json.data.attributes.isSelected).to be false
          end

          it "is still without custom coverage" do
            expect(json.data.attributes.customCoverage.beginCoverage).to be nil
            expect(json.data.attributes.customCoverage.endCoverage).to be nil
          end
        end
      end

      describe "combined update" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": "2003-01-01",
                  "endCoverage": "2004-01-01"
                },
                "isSelected": true,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isnotselected-combined-update") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isnotselected-combined-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is now selected" do
            expect(json.data.attributes.isSelected).to be true
          end

          it "is now hidden" do
            expect(json.data.attributes.visibilityData.isHidden).to be true
          end

          it "is populated with custom coverage" do
            expect(json.data.attributes.customCoverage.beginCoverage).to eq("2003-01-01")
            expect(json.data.attributes.customCoverage.endCoverage).to eq("2004-01-01")
          end
        end
      end
    end

    describe "when the package is already selected" do
      describe "deselecting a package" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": false,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isselected-toggle-isselected") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isselected-toggle-isselected-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is not selected" do
            expect(json.data.attributes.isSelected).to be false
          end

          it "is not hidden" do
            expect(json.data.attributes.visibilityData.isHidden).to be false
          end
        end
      end

      describe "hiding a package" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": true,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isselected-toggle-ishidden") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isselected-toggle-ishidden-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is still selected" do
            expect(json.data.attributes.isSelected).to be true
          end

          it "is now hidden" do
            expect(json.data.attributes.visibilityData.isHidden).to be true
          end
        end
      end

      describe "adding custom coverage" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": "2003-01-01",
                  "endCoverage": "2004-01-01"
                },
                "isSelected": true,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isselected-add-customcoverage") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isselected-add-customcoverage-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is still selected" do
            expect(json.data.attributes.isSelected).to be true
          end

          it "now has custom coverage" do
            expect(json.data.attributes.customCoverage.beginCoverage).to eq("2003-01-01")
            expect(json.data.attributes.customCoverage.endCoverage).to eq("2004-01-01")
          end
        end
      end

      describe "combined update" do
        let(:params) do
          {
            "data": {
              "type": "packages",
              "attributes": {
                "customCoverage": {
                  "beginCoverage": "2003-01-01",
                  "endCoverage": "2004-01-01"
                },
                "isSelected": false,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ""
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette("put-packages-isselected-combined-update") do
            put '/eholdings/jsonapi/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it "responds with no content" do
          expect(response).to have_http_status(204)
        end

        describe "viewing the updated package" do
          before do
            VCR.use_cassette("put-packages-isselected-combined-verify") do
              get '/eholdings/jsonapi/packages/19-6581',
                  headers: okapi_headers
            end
          end

          let!(:json) { Map JSON.parse response.body }

          it "is now unselected" do
            expect(json.data.attributes.isSelected).to be false
          end

          it "is not hidden" do
            expect(json.data.attributes.visibilityData.isHidden).to be false
          end

          it "is not populated with custom coverage" do
            expect(json.data.attributes.customCoverage.beginCoverage).to be nil
            expect(json.data.attributes.customCoverage.endCoverage).to be nil
          end
        end
      end
    end
  end

  describe "getting a non-existing package" do
    before do
      VCR.use_cassette("get-packages-not-found") do
        get '/eholdings/jsonapi/packages/1-1', headers: okapi_headers
      end
    end

    it "returns a not found error" do
      expect(response).to have_http_status(404)
    end
  end
end
