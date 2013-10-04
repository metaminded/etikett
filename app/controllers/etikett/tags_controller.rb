class Etikett::TagsController < ApplicationController
  def index
    if params.include? :query
      @etiketts = Etikett::Tag.where("name ILIKE '%#{params[:query]}%'").limit(10)
    elsif params.include?(:taggable_type) && params.include?(:taggable_id)
      @etiketts = Etikett::Tag.joins(:tag_objects).
        where("etikett_tag_objects.taggable_id IN (?) and etikett_tag_objects.taggable_type = ?",params[:taggable_id], CGI::unescape(params[:taggable_type])).
        group("etikett_tags.id").
        having("COUNT(etikett_tags.id) = ?", params[:taggable_id].count)
    else
      @etiketts = Etikett::Tag.all
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @tag = Etikett::Tag.create(name: params[:name], generated: false, nice: params[:name])
      params[:taggable_id].each do |taggable_id|
        Etikett::TagObject.create(tag: @tag,
                                  taggable_type: CGI::unescape(params[:taggable_type]),
                                  taggable_id: taggable_id)
      end
    end
      render json: (@tag.id  || {})
  end

  def update
    @tag = Etikett::Tag.find(params[:id])
    ActiveRecord::Base.transaction do
      params[:taggable_id].each do |taggable_id|
        Etikett::TagObject.find_or_create_by(tag: @tag,
          taggable_type: CGI::unescape(params[:taggable_type]),
          taggable_id: taggable_id)
      end
    end
    render json: @tag.id
  end

  def destroy
    to = Etikett::TagObject.where(tag_id: params[:id], taggable_id: params[:taggable_id],
      taggable_type: CGI::unescape(params[:taggable_type]))
    to.destroy_all
    render json: {}
  end
end
