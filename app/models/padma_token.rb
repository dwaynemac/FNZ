class PadmaToken < ConsumerToken

  def current_institution
    institution_hash = self.simple_client.get("/api/schools/my")
    # TODO refactor creation of local Institution out of PadmaToken
    # TODO return Struct?
    institution = Institution.find_or_initialize_by_padma_id(institution_hash["id"])
    if institution.name.blank?
      institution.name = institution_hash["name"]
      unless institution.save
        institution = nil
      end
    end
    return institution
  end

end