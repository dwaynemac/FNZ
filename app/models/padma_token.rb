class PadmaToken < ConsumerToken

  # returns school of OAuth user.
  def current_school
    self.simple_client.get("/api/schools/my")
  end

  # retuns OAuth user.
  def current_user
    self.simple_client.get("/api/users/me")
  end

  # returns all students of OAuth user's school
  def school_students(query={})
    self.simple_client.get("/api/schools/my/students?#{query.to_query}")
  end

  # returns all OAuth user's studentss  
  def my_students(query={})
    self.simple_client.get("/api/students?#{query.to_query}")
  end

  # OAuth user's school's people.
  def people(query={})
    response = self.simple_client.get("/api/people?#{query.to_query}")
    # TODO modularize, re-use
    if response["page"]
      return WillPaginate::Collection.create(response["page"],response["per_page"]) do |pager|
        pager.replace(response["people"])
        pager.total_entries = response["total_entries"]
      end
    else
      return response
    end
  end

  # OAuth user's school's people.
  def count_people(query={})
    self.simple_client.get("/api/people/count?#{query.to_query}")["count"]
  end

  def person(id,query={})
    self.simple_client.get("/api/people/#{id}?#{query.to_query}")
  end

end