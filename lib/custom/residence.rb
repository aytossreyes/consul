class Verification::Residence

  private

    # We are overwriting residency check, to avoid checking against the postal code
    # because the census from San Sebastián de los Reyes doesn't include postal code information
    def residency_valid?
      @census_api_response.valid? &&
        @census_api_response.date_of_birth == date_of_birth
    end

end
