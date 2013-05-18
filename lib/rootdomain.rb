class Rootdomain
  def self.matches?(request)
    case request.subdomain
    when 'www', '', nil
      true
    else
      false
    end
  end
end
