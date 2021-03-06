# frozen_string_literal: true

class DeserializablePackage < JSONAPI::Deserializable::Resource
  attributes :allowKbToAddTitles,
             :contentType,
             :customCoverage,
             :packageToken,
             :isSelected,
             :visibilityData,
             :proxy,
             :name

  attribute :contentType do |value|
    content_types = {
      'Aggregated Full Text': 'AggregatedFullText',
      'Abstract and Index': 'AbstractAndIndex',
      'E-Book': 'EBook',
      'E-Journal': 'EJournal',
      'Print': 'Print',
      'Unknown': 'Unknown',
      'Online Reference': 'OnlineReference'
    }

    { contentType: content_types[value.to_sym] || 'Unknown' }
  end
end
