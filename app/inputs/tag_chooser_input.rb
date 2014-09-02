class TagChooserInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    allowed_classes = object.class.allowed_etikett_classes[reflection.name.to_sym].present? ? object.class.allowed_etikett_classes[reflection.name.to_sym] : reflection.class_name

    data = {
      class: allowed_classes,
      id: object.id,
      input_class: attribute_name,
      tag_chooser: true,
      multiple: true,
      href: Rails.application.routes.url_helpers.etikett_tags_path,
      new_tags_allowed: Array(allowed_classes) == ['Etikett::Tag']
    }
    input_html_options[:value] = object.public_send(reflection.name).map do |t|
      {id: t.id, text: t.name, locked: false, klass: t.class.name.underscore.gsub(/\//, '_')}
    end.to_json
    input_html_options[:multiple] = true
    input_html_options[:data] = data
    input_html_options[:class] = ''
    options[:wrapper] = :select2
    @builder.text_field(attribute_name, input_html_options)
  end
end
