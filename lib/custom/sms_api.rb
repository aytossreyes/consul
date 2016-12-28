require 'open-uri'

class SMSApi
  attr_accessor :client

  def initialize
    @client = Savon.client(wsdl: url)
  end

  def url
    return "" unless end_point_available?
    open(Rails.application.secrets.sms_end_point).base_uri.to_s
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?

    response = client.call(:enviar_sms_simples, message: request(phone, code))
    success?(response)
  end

  def request(phone, code)
    {
      usuario: Rails.application.secrets.sms_username,
      movil: phone,
      texto: "Clave para verificarte: #{code}. Gobierno Abierto",
      refOrigen: nil,
      modo: 1
    }
  end

  def success?(response)
    response.body[:envio_sms_response][:envio_sms_return] == true
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response
    {:envio_sms_response=>{:envio_sms_return=>true, :@xmlns=>"http://ws.sms.ssreyes"}}
  end

end
