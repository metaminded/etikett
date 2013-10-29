class Etikett::TagsController < ApplicationController
  def index
    if params.include? :query
      @etiketts = Etikett::Tag.search(params)
    elsif params.include?(:taggable_type)
      if params[:taggable_id].present?
        @etiketts = Etikett::Tag.joins(:tag_objects).
          where("etikett_tag_objects.taggable_id IN (?) and etikett_tag_objects.taggable_type = ?",params[:taggable_id], CGI::unescape(params[:taggable_type])).
          group("etikett_tags.id").
          having("COUNT(etikett_tags.id) = ?", Array(params[:taggable_id]).count).
          order("generated desc, name asc")
        if params[:tag_type_id]
          @etiketts = @etiketts.joins(:tag_type).where('etikett_tag_types.id = ?', params[:tag_type_id])
        end
      else
        @etiketts = Etikett::Tag.none
      end
    else
      @etiketts = Etikett::Tag.all
    end
  end

  def create
    ActiveRecord::Base.transaction do
      # @tag = Etikett::Tag.new(name: params[:name], generated: false, nice: params[:name])
      # if(params[:category_id])
      #   @tag.tag_categories << Etikett::TagCategory.find(params[:category_id])
      # end
      @tag = Etikett::Tag.new(tag_params)
      @tag.save
      if params[:taggable_id]
        params[:taggable_id].each do |taggable_id|
          Etikett::TagObject.create(tag: @tag,
                                    taggable_type: CGI::unescape(params[:taggable_type]),
                                    taggable_id: taggable_id)
        end
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

  private
  def tag_params
    params.require(:tag).permit(:name, :tag_type_id)
  end
end
