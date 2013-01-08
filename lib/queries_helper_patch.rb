require_dependency 'queries_helper'

module SearchableProjects
  module QueriesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :retrieve_query, :searchable_projects
      end
    end

    module InstanceMethods

      def retrieve_query_with_searchable_projects(klass = Query)
        if klass.is_a? Query
          retrieve_query_without_searchable_projects
        else
          session_key = klass.name.underscore.to_sym
          if !params[:query_id].blank?
            cond = "project_id IS NULL"
            cond << " OR project_id = #{@project.id}" if @project
            @query = klass.find(params[:query_id], :conditions => cond)
            raise ::Unauthorized unless @query.visible?
            @query.project = @project
            session[session_key] = {:id => @query.id, :project_id => @query.project_id}
            sort_clear
          elsif api_request? || params[:set_filter] || session[session_key].nil? || session[session_key][:project_id] != (@project ? @project.id : nil)
            # Give it a name, required to be valid
            @query = klass.new(:name => "_")
            @query.project = @project
            build_query_from_params
            session[session_key] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
          else
            # retrieve from session
            @query = klass.find_by_id(session[session_key][:id]) if session[session_key][:id]
            @query ||= klass.new(:name => "_", :filters => session[session_key][:filters], :group_by => session[session_key][:group_by], :column_names => session[session_key][:column_names])
            @query.project = @project
          end
        end
      end

    end
  end
end
