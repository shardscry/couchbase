require "json"
require "./page"

struct KemalAPI::Structs::PageResult(T)
  include JSON::Serializable

  getter data : Array(T)
  getter page : Int32
  getter per_page : Int32
  getter total : Int64
  getter total_pages : Int64

  def initialize(@data : Array(T), pagination : Page, @total : Int64)
    @page = pagination.number
    @per_page = pagination.per_page
    @total_pages = (@total + @per_page - 1) // @per_page
  end
end
