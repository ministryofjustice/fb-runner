class SessionDataAdapter
  attr_reader :session

  def initialize(session)
    @session = session
  end

  def save(answers)
    if answers.present?
      session[:user_data] ||= {}

      answers.each do |field, answer|
        session[:user_data][field] = answer
      end
    end
  end

  def load_data
    session[:user_data] || {}
  end

  def delete(component_id)
    session[:user_data].delete(component_id)
    session[:user_data]
  end

  def delete_file(component_id, file_id)
    files = session[:user_data][component_id]
    session[:user_data][component_id] = files.reject { |f| f['uuid'] == file_id }
  end

  def save_progress
    uuid = SecureRandom.uuid
    OpenStruct.new(status: 200, body: { id: uuid })
  end

  def get_saved_progress(uuid)
    if uuid == 'notfound'
      return OpenStruct.new(status: 404, body: {})
    end

    if uuid == 'inactive'
      return OpenStruct.new(status: 422, body: {})
    end

    if uuid == 'attempted'
      return OpenStruct.new(status: 400, body: {})
    end

    if uuid == 'match'
      return OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"2369f3f3-8bdd-4581-a367-90e34f3aef17\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"some more text\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"27dc30c9-f7b8-4dec-973a-bd153f6797df\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}"))
    end

    OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"2369f3f3-8bdd-4581-a367-90e34f3aef17\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"some more text\",\"page_slug\":\"page-slug\",\"service_slug\":\"some-slug\",\"service_version\":\"27dc30c9-f7b8-4dec-973a-bd153f6797dg\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}"))
  end

  def increment_record_counter(_uuid)
    OpenStruct.new(status: 200)
  end

  def invalidate(_uuid)
    OpenStruct.new(status: 202)
  end
end
