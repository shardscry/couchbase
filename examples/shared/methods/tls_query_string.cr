require "uri"
require "../structs"

module CouchBaseExamples
  private def self.tls_query_string(tls : Bool) : String
    parameters = [] of String
    parameters << "tls_verify=#{TLS_VERIFY}" if tls
    if tls_hostname = TLS_HOSTNAME
      parameters << "tls_hostname=#{URI.encode_www_form(tls_hostname)}"
    end
    parameters.empty? ? "" : "?#{parameters.join('&')}"
  end
end
