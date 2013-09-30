class Etikett::TagCategory < ActiveRecord::Base
  belongs_to :parent_category, class_name: 'TagCategory', foreign_key: 'parent_category_id'
  has_and_belongs_to_many :tags


  def self.navigation
    path(self.root)
  end

  def self.path node
    x = {}
    if node.has_children?
      x[:children] = node.children.collect do |c|
        path(c)
      end.flatten
    end
    x[:name] = node.name
    x
  end

  def self.root
    find_by(parent_category_id: nil)
  end

  def has_children?
    self.class.where(parent_category: self).count > 0
  end

  def children
    self.class.where(parent_category: self)
  end
end
