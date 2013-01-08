class ProjectQuery < Query

  def initialize(attributes=nil, *args)
    super attributes
    self.filters = {} if !attributes || !attributes[:filter]
  end

  def self.available_columns
    [
        QueryColumn.new(:name, :sortable => "#{Project.table_name}.name"),
        QueryColumn.new(:parent),
        QueryColumn.new(:short_description),
        QueryColumn.new(:homepage, :sortable => "#{Project.table_name}.homepage"),
        QueryColumn.new(:is_public, :sortable => "#{Project.table_name}.is_public"),
        QueryColumn.new(:identifier, :sortable => "#{Project.table_name}.identifier"),
        QueryColumn.new(:start_date),
        QueryColumn.new(:due_date)
    ]
  end

  def sortable_columns
    {'id' => "#{Project.table_name}.id"}.merge(available_columns.inject({}) {|h, column|
      h[column.name.to_s] = column.sortable
      h
    })
  end

  def default_columns_names
    @default_columns_names ||= Setting.plugin_serchable_projects[:columns].map(&:to_sym)
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup

    @available_columns
  end

  def available_filters
    return @available_filters if @available_filters

    @available_filters = {
      "is_public" => { :type => :list, :order => 1, :values => [true, false] },
      "name" => { :type => :string, :order => 2 },
      "description" => { :type => :text, :order => 3 },
      "parent_id" => { :type => :list_subprojects, :order => 4, :values => Project.visible.where(:id => Project.visible.pluck("DISTINCT parent_id")).map { |p| [p.name, p.id.to_s] } }
    }

    @available_filters.each do |field, options|
      options[:name] ||= l("field_#{field}".gsub(/_id$/, ''))
    end
    @available_filters
  end


  def projects_count
    apply_filters(default_scope).count
  end

  def projects(options={})
    order_option = options[:order]
    order_option = nil if order_option.blank?
    scope = default_scope.limit(options[:limit]).offset(options[:offset]).order(order_option)

    scope = scope.where(options[:conditions]) if options[:conditions].present?
    scope = scope.includes(options[:include]) if options[:include].present?
    apply_filters(scope)
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def project_ids(options={})
    projects(options).pluck("#{Project.table_name}.id")
  end

  def apply_filters(scope)
    return scope unless valid?

    filters.each_key do |field|
      v = values_for(field).clone
      next unless v and !v.empty?
      operator = operator_for(field)
      scope = scope.where(sql_for_field(field, operator, v, Project.table_name, field))
    end
    scope
  end

  def default_scope
    Project.visible
  end


end