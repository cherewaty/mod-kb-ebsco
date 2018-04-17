# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Resources', type: :request do
  describe 'editing a custom title' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'changing the name' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "name": 'I have a great new title name'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-name') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has the new name' do
        expect(json.data.attributes.name).to eq('I have a great new title name')
      end
    end

    describe 'changing the publication type' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "publicationType": 'Book Series'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-pubtype') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has the new publication type' do
        expect(json.data.attributes.publicationType).to eq('Book Series')
      end
    end

    describe 'changing the coverage dates' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              'customCoverages': [
                {
                  'beginCoverage': '2003-01-01',
                  'endCoverage': '2004-01-01'
                }
              ],
              "isSelected": true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-coverage-dates') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'now has custom coverage' do
        expect(json.data.attributes.customCoverages[0].beginCoverage)
          .to eq('2003-01-01')
        expect(json.data.attributes.customCoverages[0].endCoverage)
          .to eq('2004-01-01')
      end
    end

    describe 'changing the visibility' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "visibilityData": {
                "isHidden": true,
                "reason": ''
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-visibility') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'is now hidden' do
        expect(json.data.attributes.visibilityData.isHidden).to be true
      end
    end

    describe 'changing the embargo period' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "customEmbargoPeriod": {
                "embargoUnit": 'Weeks',
                "embargoValue": 6
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-embargo-period') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has a custom embargo period' do
        expect(json.data.attributes.customEmbargoPeriod.embargoUnit)
          .to eq('Weeks')
        expect(json.data.attributes.customEmbargoPeriod.embargoValue)
          .to eq(6)
      end
    end

    describe 'changing the embargo period' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "coverageStatement": 'We have so much coverage.'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-coverage-statement') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has a coverage statement' do
        expect(json.data.attributes.coverageStatement)
          .to eq('We have so much coverage.')
      end
    end

    describe 'combined update' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "visibilityData": {
                "isHidden": true
              },
              "name": 'This is the best title ever',
              "isPeerReviewed": true,
              "publicationType": 'Newspaper',
              "publisherName": 'Frontside Newspapers',
              "edition": '5',
              "description": 'Something something something',
              "url": 'https://frontside.io',
              "customCoverages": [
                {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                }
              ],
              "coverageStatement": 'There are many years.',
              "customEmbargoPeriod": {
                "embargoUnit": 'Weeks',
                "embargoValue": 6
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-combined-update') do
          put '/eholdings/resources/123355-2739728-17053010',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has name' do
        expect(json.data.attributes.name).to eq('This is the best title ever')
      end

      it 'is now hidden' do
        expect(json.data.attributes.visibilityData.isHidden).to be true
      end

      it 'has peer review status' do
        expect(json.data.attributes.isPeerReviewed).to be true
      end

      it 'has publication type' do
        expect(json.data.attributes.publicationType).to eq('Newspaper')
      end

      it 'has publisher name' do
        expect(json.data.attributes.publisherName).to eq('Frontside Newspapers')
      end

      it 'has edition' do
        expect(json.data.attributes.edition).to eq('5')
      end

      it 'has description' do
        expect(json.data.attributes.description).to eq('Something something something')
      end

      it 'has url' do
        expect(json.data.attributes.url).to eq('https://frontside.io')
      end
    end
  end

  describe 'deleting a custom title' do
    describe 'deletes title if it is part of a custom package' do
      before do
        VCR.use_cassette('delete-custom-title') do
          delete '/eholdings/resources/123355-2843714-17070531',
                 headers: okapi_headers
        end
      end

      it 'gets a successful response' do
        expect(response).to have_http_status(204)
      end
    end

    describe 'trying to delete a deleted title results in error' do
      before do
        VCR.use_cassette('delete-deleted-title') do
          delete '/eholdings/resources/123355-2843714-17070531',
                 headers: okapi_headers
        end
      end

      it 'gets a not found response' do
        expect(response).to have_http_status(404)
      end
    end

    describe 'trying to delete a title not in a custom package' do
      before do
        VCR.use_cassette('delete-non-custom-title') do
          delete '/eholdings/resources/72-6057-1360002',
                 headers: okapi_headers
        end
      end

      it 'gets a bad request response' do
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'creating a custom title' do
    let(:create_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'with name and pubtype' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing',
              'publicationType' => 'Book',
              'packageId' => '2843712'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-name-pubtype') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      it 'has a list of attributes' do
        expect(attributes).to include(
          'contributors',
          'coverageStatement',
          'customCoverages',
          'customEmbargoPeriod',
          'description',
          'identifiers',
          'isPeerReviewed',
          'isSelected',
          'managedCoverages',
          'managedEmbargoPeriod',
          'name',
          'packageId',
          'packageName',
          'providerId',
          'providerName',
          'publicationType',
          'publisherName',
          'subjects',
          'titleId',
          'url',
          'vendorId',
          'vendorName',
          'visibilityData'
        )
      end
      it 'has the new name' do
        expect(json.data.attributes.name).to eq('New Custom Title Testing')
      end

      it 'has the new publication type' do
        expect(json.data.attributes.publicationType).to eq('Book')
      end
    end

    describe 'with an existing name' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing',
              'publicationType' => 'Book',
              'packageId' => '2843712'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-existing-name') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'responds with bad request' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eql('Custom Title with the provided name already exists')
      end
    end

    describe 'with missing name' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'publicationType' => 'Book',
              'packageId' => '2843712'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-missing-name') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid titleName')
      end
    end

    describe 'with a name that exceeds maximum size' do
      let(:largeName) { '0' * 401 }

      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => largeName,
              'publicationType' => 'Book',
              'packageId' => '2843712'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-name') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid titleName')
      end
    end

    describe 'with missing publication type' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing',
              'packageId' => '2843712'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-missing-pubtype') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid pubType')
      end
    end

    describe 'with missing package id' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing',
              'publicationType' => 'Book'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-missing-packageId') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid package_id')
      end
    end

    describe 'with a managed package id' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing',
              'publicationType' => 'Book',
              'packageId' => '2512592'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-managed-packageId') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eql('Custom Title can not be added to the provided package')
      end
    end
  end
end
