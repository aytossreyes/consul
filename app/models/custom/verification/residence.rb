require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :residence

  def residence
    return if errors.any?

    unless residency_valid?
      errors.add(:residence, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end


  private

    # We are overwriting residency check, to avoid checking against the postal code
    # because the census from San Sebastián de los Reyes doesn't include postal code information
    def residency_valid?
      @census_api_response.valid? &&
        @census_api_response.date_of_birth == date_of_birth
    end

end
