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

  describe '#has_many_via_tags' do
    it 'works with multiple associations to the same class' do
      l = Lecture.new(title: 'foobar')
      student = User.create!(first_name: 'Some', last_name: 'Student')
      docent = User.create!(first_name: 'Some', last_name: 'Prof')
      l.student_tags << student.master_tag
      l.docent_tags << docent.master_tag
      l.save!
      l.reload
      expect(l.student_tags).to eq [student.master_tag]
      expect(l.docent_tags).to eq [docent.master_tag]
    end
  end

  describe '#dependent destroy' do
    it 'destroys the tag after the model is destroyed' do
      l = Lecture.create!(title: 'foobar')
      master_tag_id = l.master_tag.id
      expect(l.master_tag.present?).to eq true
      l.destroy!
      expect(Etikett::Tag.where(id: master_tag_id).count).to eq 0
    end
  end

  describe '#belongs_to_tag' do
    it 'creates a 1-x association via a tag' do
      a = Article.new(title: 'foobar')
      Article.master_tag do
        {sid: "#{self.product_no} #{self.title}"}
      end
      a.save!
      expect(a).to respond_to(:author_tag_mapping)
      expect(a).to respond_to(:author_tag)
      expect(a).to respond_to(:author)
      u = User.create!(first_name: 'Luke', last_name: 'Skywalker')
      a.author_tag = u.master_tag
      a.save!
      a.reload
      expect(a.author).to eq(u)
    end
  end
end
