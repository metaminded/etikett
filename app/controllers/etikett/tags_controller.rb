class Etikett::TagsController < ApplicationController
  def index
    if params.include? :query
      @etiketts = Etikett::Tag.where("name ILIKE '%#{params[:query]}%' AND generated = FALSE").limit(10)
    elsif params.include?(:taggable_type) && params.include?(:taggable_id)
      @etiketts = Etikett::Tag.joins(:tag_objects).where("etikett_tag_objects.taggable_id = ? and etikett_tag_objects.taggable_type = ?",params[:taggable_id], CGI::unescape(params[:taggable_type]))
    else
      @etiketts = Etikett::Tag.all
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @tag = Etikett::Tag.create(name: params[:name], generated: false, nice: params[:name])
      to = Etikett::TagObject.new(tag: @tag, taggable_type: CGI::unescape(params[:taggable_type]),
          taggable_id: params[:taggable_id])
      to.save
      render json: @tag.id
    end
  end

  def update
    @tag = Etikett::Tag.find(params[:id])
    to = Etikett::TagObject.new(tag: @tag, taggable_type: CGI::unescape(params[:taggable_type]),
          taggable_id: params[:taggable_id])
    to.save
    render json: @tag.id
  end

  def destroy
    to = Etikett::TagObject.find_by(tag_id: params[:id], taggable_id: params[:taggable_id],
      taggable_type: CGI::unescape(params[:taggable_type]))
    to.destroy
    render json: {}
  end
end
