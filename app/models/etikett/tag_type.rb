class Etikett::TagType < ActiveRecord::Base
  has_many :tags

  validates :name, uniqueness: { case_sensitive: false }

  def self.[](name)
    find_by(name: name)
  end
end
