class Etikett::TagsController < ApplicationController
  def index
    @etiketts = Etikett::Tag.fetch(params)
    if current_user.respond_to?(:allowed_to_use_tag?) && params[:skip_permission_check] != 'true'
      Array(@etiketts).select!{|tag| current_user.allowed_to_use_tag?(tag)}
    end
    respond_to do |format|
      format.json {
        render json: @etiketts.collect{|e| {
          id: params[:real_object_id] == 'true' ? e.prime_id : e.id,
          text: e.name,
          locked: e.is_prime_for?(params[:taggable_type], params[:taggable_id]),
          klass: e.class.name.underscore.gsub(/\//, '_'),
          meta: e.try(:prime).try(:etikett_meta_data, params[:real_object_id] == 'true')}
        }, root: false
      }
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @tag = Etikett::Tag.new(tag_params)
      @tag.save
      if params[:taggable_id]
        params[:taggable_id].each do |taggable_id|
          Etikett::TagMapping.create(tag: @tag,
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
        Etikett::TagMapping.find_or_create_by(tag: @tag,
          taggable_type: CGI::unescape(params[:taggable_type]),
          taggable_id: taggable_id)
      end
    end
    render json: @tag.id
  end

  def destroy
    to = Etikett::TagMapping.where(tag_id: params[:id], taggable_id: params[:taggable_id],
      taggable_type: CGI::unescape(params[:taggable_type]))
    to.destroy_all
    render json: {}
  end

  private
  def tag_params
    params.require(:tag).permit(:name)
  end
end
