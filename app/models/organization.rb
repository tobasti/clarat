# Monkeypatch clarat_base Organization
require ClaratBase::Engine.root.join('app', 'models', 'organization')

class Organization < ActiveRecord::Base
  # Frontend-only Methods

  def canonical_section
    section_filters.pluck(:identifier).first || SectionFilter::DEFAULT
  end

  def in_section? section
    section_filters.where(identifier: section).count > 0
  end

  # structured information to build a gmap marker for this orga
  def gmaps_info
    {
      title: name,
      address: location.address
    }
  end
end
