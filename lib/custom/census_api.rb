class CensusApi

  def call(document_type, document_number)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant))
      return response if response.valid?
    end
    response
  end

  def get_document_number_variants(document_type, document_number)
    # Delete all non-alphanumerics
    document_number = document_number.to_s.gsub(/[^0-9A-Za-z]/i, '')
    variants = []

    if is_dni?(document_type)
      document_number, letter = split_letter_from(document_number)
      number_variants = get_number_variants_with_leading_zeroes_from(document_number)
      letter_variants = get_letter_variants(number_variants, letter)

      variants += number_variants
      variants += letter_variants
    else # if not a DNI, just use the document_number, with no variants
      variants << document_number
    end

    variants
  end

  class Response
    def initialize(body)
      @body = body
    end

    def valid?
      data[:nif].present?
    end

    def date_of_birth
      data[:fecha_nacimiento]
    end

    def postal_code
      data[:codigo_postal]
    end

    def district_code
      '1'
    end

    def gender
      data[:sexo] == "V" ? 'male' : 'female'
    end

    private

    def data
      @data ||= begin
                  if @body[:get_persona_consul_response] and @body[:get_persona_consul_response][:get_persona_consul_return]
                    @body[:get_persona_consul_response][:get_persona_consul_return]
                  end
                end
    end
  end

  private

  def get_response_body(document_type, document_number)
    if end_point_available?
      client.call(:get_persona_consul, message: request(document_type, document_number)).body
    else
      stubbed_response_body
    end
  end

  def client
    @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
  end

  def request(document_type, document_number)
    { nif: document_number }
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response_body
    {:get_persona_consul_response=>{:get_persona_consul_return=>{:apellido1=>nil, :apellido2=>nil, :codigo_postal=>nil, :fecha_nacimiento=>nil, :nif=>nil, :nombre=>nil, :sexo=>nil}, :@xmlns=>"http://ws.padron.ssreyes"}}
  end

  def is_dni?(document_type)
    document_type.to_s == "1"
  end

  def split_letter_from(document_number)
    letter = document_number.last
    if letter[/[A-Za-z]/] == letter
      document_number = document_number[0..-2]
    else
      letter = nil
    end
    return document_number, letter
  end

  # if the number has less digits than it should, pad with zeros to the left and add each variant to the list
  # For example, if the initial document_number is 1234, and digits=8, the result is
  # ['1234', '01234', '001234', '0001234']
  def get_number_variants_with_leading_zeroes_from(document_number, digits=8)
    document_number = document_number.to_s.last(digits) # Keep only the last x digits
    document_number = document_number.gsub(/^0+/, '')   # Removes leading zeros

    variants = []
    variants << document_number unless document_number.blank?
    while document_number.size < digits
      document_number = "0#{document_number}"
      variants << document_number
    end
    variants
  end

  # Generates uppercase and lowercase variants of a series of numbers, if the letter is present
  # If number_variants == ['1234', '01234'] & letter == 'A', the result is
  # ['1234a', '1234A', '01234a', '01234A']
  def get_letter_variants(number_variants, letter)
    variants = []
    if letter.present? then
      number_variants.each do |number|
        variants << number + letter.downcase << number + letter.upcase
      end
    end
    variants
  end
end
