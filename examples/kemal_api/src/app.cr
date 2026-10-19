require "./dependencies"
require "./routing"

@[ADI::Register(name: "app", public: true)]
class KemalAPI::App
  def initialize(@routing : KemalAPI::Routing)
  end

  def mount : Nil
    @routing.mount
  end
end
