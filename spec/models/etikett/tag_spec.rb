require 'spec_helper'

describe Etikett::Tag do

  describe '#prime' do
    it "knows its prime" do
      u = User.create(first_name: 'Florian', last_name: 'Thomas')
      tag = Etikett::Tag.create!(name: 'test tag', prime: u)
      expect(tag.prime).to eq u
    end
  end

  describe '#is_prime_for?' do
    it "returns true if it's the prime of an object" do
      u = User.create(first_name: 'Florian', last_name: 'Thomas')
      tag = Etikett::Tag.create!(name: 'test tag', prime: u)
      expect(tag.is_prime_for?('User', u.id)).to be_truthy
    end

    it "return false if it's not the prime of an object" do
      u = User.create(first_name: 'Florian', last_name: 'Thomas')
      u2 = User.create(first_name: 'Chuck', last_name: 'Norris')
      tag = Etikett::Tag.create!(name: 'test tag', prime: u)
      expect(tag.is_prime_for?('User', u2.id)).to be_falsey
    end
  end
end
