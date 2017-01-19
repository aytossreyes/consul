require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  # This should be just `residence` but the UI relies on this error
  validate :postal_code_in_madrid
  validate :residence_in_madrid

  def residence_in_madrid
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_madrid, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  # We have the method but we never call it
  # In order to don't raise a unused i18n key error
  def postal_code_in_madrid
    if Rails.env.test?
      errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
    else
      return true
    end
  end

  private

    # We are overwriting residency check, to avoid checking against the postal code
    # because the census from San Sebastián de los Reyes doesn't include postal code information
    def residency_valid?
      if !Rails.env.test?
        @census_api_response.valid? &&
          @census_api_response.date_of_birth == date_of_birth
      else
        @census_api_response.valid? &&
          @census_api_response.postal_code == postal_code &&
          @census_api_response.date_of_birth == date_of_birth
      end
    end

    def valid_postal_code?
      postal_code =~ /^280/
    end
end
