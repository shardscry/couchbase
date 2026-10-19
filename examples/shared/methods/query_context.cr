require "../structs"

module CouchBaseExamples
  def self.query_context : CouchBase::Query::QueryContext
    CouchBase::Query::QueryContext.new(
      bucket: BUCKET,
      scope: QUERY_SCOPE,
    )
  end
end
