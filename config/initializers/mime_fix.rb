#ticket https://rails.lighthouseapp.com/projects/8994/tickets/2784-private-method-split-called-for-mimetype0x226f618
module Mime 
  class Type
    def split(*args)
      to_s.split(*args)
    end
  end
end