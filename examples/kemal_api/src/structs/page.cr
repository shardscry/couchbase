require "../errors/request_error"

private alias RequestError = KemalAPI::Errors::RequestError

struct KemalAPI::Structs::Page
  getter number : Int32
  getter per_page : Int32

  def initialize(number : String? = nil, per_page : String? = nil)
    @number = number ? number.to_i? || 0 : 1
    @per_page = per_page ? per_page.to_i? || 0 : 20
    raise RequestError.new(400, "page must be a positive integer") unless @number > 0
    unless (1..100).includes?(@per_page)
      raise RequestError.new(400, "per_page must be an integer between 1 and 100")
    end
  end

  def offset : Int64
    (@number.to_i64 - 1) * @per_page
  end
end
