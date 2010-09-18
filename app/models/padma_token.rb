class PadmaToken < ConsumerToken

  def current_school
    self.simple_client.get("/api/schools/my")
  end

  def school_students(options={})
    unless (page = options.delete(:page)).nil?
      page_param = "?page=#{page}"
      per_page = (per_page=options.delete(:per_page)).nil?? 30 : per_page
      page_param << "&per_page=#{per_page}"
    end

    self.simple_client.get("/api/schools/my/students#{page_param}")
  end

  def my_students(options={})
    unless (page = options.delete(:page)).nil?
      page_param = "?page=#{page}"
      per_page = (per_page=options.delete(:per_page)).nil?? 30 : per_page
      page_param << "&per_page=#{per_page}"
    end
    self.simple_client.get("/api/students#{page_param}")
  end

end