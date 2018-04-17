# frozen_string_literal: true

class ResourcesController < ApplicationController
  attr_accessor :resource

  before_action :set_resource, only: %i[show update destroy]

  deserializable_resource :resource,
                          only: %i[create update],
                          class: DeserializableResource
  def create
    resource_create_params = resource_params.slice(
      :titleName,
      :pubType,
      :package_id
    )

    resource_validation =
      Validation::ResourceCreateParameters.new(resource_create_params)

    if resource_validation.valid?
      @resource = resources.create_resource(resource_create_params)
      render jsonapi: @resource
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  end

  def show
    render jsonapi: @resource,
           include: params[:include]
  end

  def update
    resource_validation =
      Validation::ResourceUpdateParameters.new(resource_params)

    if resource_validation.valid?
      @resource.update resource_params
      render jsonapi: @resource
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  end

  def destroy
    resource_validation =
      Validation::ResourceDestroyParameters.new(@resource.customerResourcesList)

    if resource_validation.valid?
      @resource.delete
    else
      render jsonapi_errors: resource_validation.errors,
             status: :bad_request
    end
  end

  private

  def set_resource
    @resource = resources.find resource_id
  end

  def resource_id
    vendor_id, package_id, title_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id, title_id: title_id }
  end

  def resources
    Resource.configure config
  end

  def resource_params
    # NOTE: deserialization happens before param parsing, so we
    # use the RMAPI property names here
    params
      .require(:resource)
      .permit(
        :titleName,
        :pubType,
        :isSelected,
        :coverageStatement,
        :isPeerReviewed,
        :publisherName,
        :edition,
        :description,
        :url,
        :package_id,
        visibilityData: [:isHidden],
        customCoverageList: [
          %i[beginCoverage endCoverage]
        ],
        customEmbargoPeriod: %i[
          embargoUnit
          embargoValue
        ]
      )
  end
end
