# from http://allwaysbeginner.wordpress.com/2009/03/16/ruby-rails-beginner-try-active-youtube-activeyoutube/
module ActiveResource
# overrides the default ActiveResource Connection Class build_request_headers method because of this error:
# http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1053-removed-http-header-accept-by-default
  class Connection

    def build_request_headers(headers, http_method=nil)
      authorization_header.update(default_header).update(headers).update(http_format_header(http_method))
      authorization_header.update(default_header).update(headers)
    end

  end

end
