class Component
  include ActiveModel::Validations

  # {"_id"=>"page.usn--text",
  #  "_type"=>"text",
  #  "errors"=>{"pattern"=>{"inline"=>"Your answer should be 7 numbers", "summary"=>"Your answer should be 7 numbers"}},
  #  "hint"=>"Issued with the original CRM14 eForm application, 7 numbers (for example, 2123456)",
  #  "label"=>"Unique submission number (USN)",
  #  "name"=>"usn",
  #  "validation"=>{"pattern"=>"^\\d{7}$", "required"=>false},
  #  "widthClassInput"=>"one-quarter",
  #  "value"=>""}

  attr_reader :id, :type, :label, :name, :value, :validation, :config

  def self.new_from_hash(hash, options)
    "Components::#{hash['_type'].camelcase}".constantize.new(hash, options)
  end

  def initialize(hash, options)
    @id = hash['_id']
    @type = hash['_type']
    @label = hash['label']
    @name = hash['name']
    @value = hash['value']
    @validation = hash['validation'] || {}

    @config = options[:config]

    add_validation_rules
  end

  private

  def http_method
    config[:http_method]
  end

  def post?
    config[:http_method] == :post
  end

  def add_validation_rules
    if validation['required']
      class_eval do
        validates_presence_of :value
      end
    end
  end
end
