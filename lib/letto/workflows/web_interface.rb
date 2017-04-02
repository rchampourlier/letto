# frozen_string_literal: true
require_relative '../workflows'

module Letto
  module Workflows

    # WebInterface for workflows management
    module WebInterface

      # Sinatra helpers for the workflows routes
      module Helpers
        attr_reader :user

        def create_or_update_workflow(user:, params:)
          begin
            workflow_data = JSON.parse(params['workflow_data'])
            workflow = Workflows.build(data: workflow_data)
            id = params[:id]
            if id
              Persistence::WorkflowRepository.update_by_id(id: id, data: JSON.dump(workflow_data))
            else
              id = Persistence::WorkflowRepository.create(
                user_uuid: user[:id],
                data: JSON.dump(workflow_data)
              )
            end
            successful = true
          rescue Error => e
            err_message = "Invalid workflow: #{e.message}"
            data = JSON.pretty_generate(workflow_data)
          rescue JSON::ParserError => e
            err_message = "Invalid JSON: #{e.message}"
            data = params['data']
          end
          if successful
            flash[:success] = "Workflow \"#{workflow_data['name']}\" saved with id #{id}"
            redirect "/workflows/#{id}"
          else
            render_workflows(selected_data: data, flash_messages: { danger: err_message }, user_uuid: user[:id])
          end
        end

        def render_workflows(selected_data: nil, selected_id: nil, user_uuid:, flash_messages: {})
          flash_messages&.each { |k, v| flash.now[k] = v }
          @workflows = Persistence::WorkflowRepository.for_user_uuid(user_uuid)
          @selected_workflow_data = selected_data
          @selected_workflow_id = selected_id
          erb :workflows
        end

        def beautify_json(json)
          JSON.pretty_generate(JSON.parse(json))
        end
      end

      def self.registered(app)

        # INDEX, NEW
        app.get ''do
          render_workflows(user_uuid: user[:id])
        end

        # SHOW, EDIT
        app.get '/:id' do
          selected_workflow = Persistence::WorkflowRepository.for_id(params[:id])
          render_workflows(
            selected_data: beautify_json(selected_workflow[:data]),
            selected_id: selected_workflow[:id],
            user_uuid: user[:id]
          )
        end

        # CREATE
        app.post ''do
          create_or_update_workflow(user: user, params: params)
        end

        # UPDATE
        app.put '/:id' do
          create_or_update_workflow(user: user, params: params)
        end

        # DELETE
        app.delete '/:id' do
          id = params[:id]
          Persistence::WorkflowRepository.delete_by_id(id: id)
          redirect('/workflows')
        end
      end
    end
  end
end
