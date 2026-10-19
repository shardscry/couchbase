require "../structs"

module CouchBaseExamples
  def self.delete_query_users(
    kv : CouchBase::KV::Client,
    users : Array(Structs::User),
  ) : Nil
    users.each do |user|
      kv.delete(user.id) rescue nil
    end
  end
end
