defmodule Bonfire.Web.Router do
  use Bonfire.Web.Routes
end

defmodule Bonfire.Web.Router.Reverse do
  import Voodoo, only: [def_reverse_router: 2]
  def_reverse_router(:path, for: Bonfire.Web.Router, filter: [module: Bonfire.Common.Extend, fun: :module_enabled?])
end
