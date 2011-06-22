require 'uri'

Hash.class_eval {
  def to_query_string
    params = []
    self.each_pair do |k,v|
      params << "#{URI.escape(k.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}=#{URI.escape(v, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    end
    params.join("&")
  end
}