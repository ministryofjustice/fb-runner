# This monkeypatch can be removed when the interaction between or x-robots middleware and rails 7 is resolved
# At the time of upgrade, we end up calling session.enabled? when session is a hash, not an ActionDispatch::Request::Session
# This lets the middleware continue without throwing
class Hash
  def enabled?; end
end