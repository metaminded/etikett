class TagSingleChooserInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    data = {
      class: Array(options[:class_names]).presence || options[:class_name],
      id: object.id,
      input_class: attribute_name,
      multiple: false,
      tag_chooser: true,
      href: Rails.application.routes.url_helpers.etikett_tags_path,
      new_tags_allowed: options[:new_tags_allowed] || false,
      real_object_id: reflection.present? && reflection.belongs_to?
    }
    if data[:real_object_id]
      input_html_options[:value] = object.public_send(reflection.name).try do |obj|
        master_tag = obj.master_tag
        [{id: obj.id, text: master_tag.name, locked: false, klass: master_tag.class.name.underscore.gsub(/\//, '_')}]
      end.to_json
    elsif object.is_a? Etikett::Tag
      input_html_options[:value] = [{id: object.id, text: object.name, klass: object.class.name.underscore.gsub(/\//, '_')}].to_json
    else
      input_html_options[:value] = object.public_send(attribute_name).try do |t|
        [{id: t.id, text: t.name, locked: false, klass: object.class.name.underscore.gsub(/\//, '_')}]
      end.to_json
    end
    # input_html_options[:multiple] = false
    input_html_options[:data] = data
    input_html_options[:class] = ''
    options[:wrapper] = :select2
    @builder.text_field(attribute_name, input_html_options)
  end
end
