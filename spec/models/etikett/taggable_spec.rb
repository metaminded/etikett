require 'spec_helper'

describe Etikett::Taggable do
  describe '#create_automated_tag' do
    it 'creates a prime tag for the saved object' do
      Article.master_tag do
        {sid: "#{self.product_no} #{self.title}"}
      end

      a = Article.create!(product_no: '123', title: 'Book')
      t = Etikett::Tag.last
      a.reload
      expect(t.prime).to eql a
      expect(Etikett::ArticleTag.count).to eq 1
      t = Etikett::Tag.find t.id
      expect(a.master_tag).to eql t
      expect(t.article).to eql a
    end
  end

  describe '#has_many_tags' do
    it 'defines two methods' do
      a = Article.new(title: 'foobar')
      Article.master_tag do
        {sid: "#{self.product_no} #{self.title}"}
      end
      a.save!
      expect(a).not_to respond_to(:user_tags)
      expect(a).not_to respond_to(:users)
      Article.has_many_via_tags(:users)
      a.reload
      u = User.create!(first_name: 'florian', last_name: 'thomas')
      a.user_tags << u.master_tag
      a.save
      expect(a.user_tags.first).to eql u.master_tag
      expect(a.users.first).to eql u
    end
  end
end